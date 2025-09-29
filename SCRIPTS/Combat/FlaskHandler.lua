local Class = require("CoreLib.Class")
local UI = require("CoreLib.UI")
local PulseCache = require("CoreLib.PulseCache")

local Conditions = require("PoE2Lib.Combat.Conditions")
local FlaskStats = require("PoE2Lib.Combat.FlaskStats")

--- FlaskHandler is an abstract handler that serves as a general API definition
--- for combat handlers. It has some default implementations, but the core of it
--- should be implemented by the combat handlers (`:canUse()` and `:use()`).
---
---@class PoE2Lib.Combat.FlaskHandler : Class
---@overload fun(config: PoE2Lib.Combat.FlaskHandler.Config): PoE2Lib.Combat.FlaskHandler
---@diagnostic disable-next-line: assign-type-mismatch
local FlaskHandler = Class()

--- This should be overridden by each handler and is used for display.
---@type string
FlaskHandler.shortName = 'Base'

--- This can be overridden by each handler to show a short informative
--- description to the user about the handler.
---@type string
FlaskHandler.description = [[]]

--- This function is called to generate a default handler for a flask. It does
--- not stop the handler from being used with a flask. This should be done with
--- `:canUse()` and `:use()`. This is not defined as a method, because it's a
--- property of the class.
---@param flask ItemActor
---@param name string Flask item name
---@param flaskType number EFlaskType
---@param localStats table<Stat, integer>
FlaskHandler.canHandle = function(flask, name, flaskType, localStats)
    return false
end

--- The combat handler config is a serializable table containing all the fields
--- necessary to construct a combat handler. Combat handlers are class
--- objects and not simple tables, and thus contain a lot of extra fields that
--- don't serialize cleanly.
---@class PoE2Lib.Combat.FlaskHandler.Config
FlaskHandler.config = { --
    --- The full class name of the handler, e.g. LifeFlaskHandler.
    ---@type string
    handlerName = "",
    ---@type 1|2|3|4|5
    slot = 1,
    ---@type string
    flaskName = "",
    --- Whether the handler is enabled.
    enabled = true,
    --- Contains handler specific settings. See FlaskHandler.settings for more
    --- info.
    ---@type table
    settings = {},
    ---@type PoE2Lib.Combat.Conditions.Config[]
    conditions = {},
}

--- Contains handler specific settings. The handler is responsible for drawing
--- the UI to change the settings with the method `:drawSettings()`.
---@type table
FlaskHandler.settings = {}

---@type PoE2Lib.Combat.Conditions.Config[]
FlaskHandler.conditions = {}

--- Last use tick
---@type number
FlaskHandler.lastUseTick = 0

--- Internal cooldown so actions can't happen too often. Value is time in ticks.
--- A value of 0 is effectively no cooldown.
---@type number
FlaskHandler.internalCooldown = 250

---@class PoE2Lib.Combat.FlaskHandler.SharedState
local SharedState = {
    FlaskInventory = PulseCache(function()
        return Infinity.PoE2.getGameStateController():getInGameState():getServerData().getPlayerInventoryByType(EInventoryType_Flask)
    end),
}

--- The settings paramater should be a settings table that the handler can use.
--- The handler will retain a reference to this table, so it cooperates with
--- MagLib.Core.Settings.
---
--- WARNING: This method cannot really be overridden, because there is too much
--- handling in here. There is a `:setup()` method for that which is called at
--- the end of `:init()`, which the handler may override for the same effect.
---@param config PoE2Lib.Combat.FlaskHandler.Config
function FlaskHandler:init(config)
    assert(type(config) == 'table', 'config is not a table')
    assert(type(config.settings) == 'table', 'config.settings is not a table')
    assert(type(config.conditions) == 'table', 'config.conditions is not a table')

    self.config = config
    self.slot = config.slot
    self.conditions = config.conditions

    -- Complete assigns any missing values from b to a. We do this because we
    -- want to retain the original settings table reference, because it's shared
    -- by the settings handler that handles storing it. We want to complete the
    -- settings because unexpected missing values on the settings can be
    -- problematic for the implementing handler.
    --
    -- This is different from table.merge, because we want to retain existing
    -- values on the table and not override them with the defaults.
    local function complete(a, b)
        for k, v in pairs(b) do
            -- Assign mismatched types, this ensures that we can't get
            -- errors on wrong types. This will also ensure that missing values
            -- are assigned, because if type(a[k]) is nil, then it cannot be
            -- equal to type(v) which can never be nil.
            if type(v) ~= type(a[k]) then
                a[k] = v
                -- If type(v) is a table, then type(a[k]) is also a table, given
                -- the previous condition.
            elseif type(v) == 'table' then
                complete(a[k], v)
            end
        end
        return a
    end

    -- Complete the settings table with the default settings.
    complete(config.settings, self.settings)
    -- Now we move the completed settings into self.settings, so it's accessible
    -- by the handler.
    self.settings = config.settings

    -- Define a metatable that will look up methods in the FlaskHandler class,
    -- but bind the child class instance when the methods are called.
    self._super_mt = setmetatable({}, {
        __index = function(_, k)
            if type(FlaskHandler[k]) == 'function' then
                return function(_, ...)
                    return FlaskHandler[k](self, ...)
                end
            else
                return FlaskHandler[k]
            end
        end,
    })

    self.caches = {
        item = PulseCache(function()
            local flaskInv = SharedState.FlaskInventory:getValue()
            if flaskInv == nil then
                return nil
            end

            return flaskInv:getInventoryItemByPos(Vector2(self.slot - 1, 0))
        end),
    }

    self:setup()
end

--- This method can be overridden by the handler to add additional logic to the
--- `:init()` method.
function FlaskHandler:setup()
end

--- Some magic that allows for `self:super():something()` calls by child classes
--- without mutating the child class, while still binding self to the child
--- class. This allows the child class to override a method, but still call the
--- original method through a short syntax.
---@return PoE2Lib.Combat.FlaskHandler
function FlaskHandler:super()
    return self._super_mt
end

--- This function can be overridden by implementations to 'bind' OnPulse without
--- having to register a callback. This is available in case an implementation
--- needs to check/update every pulse.
function FlaskHandler:onPulse()
end

--- Try to use the handler. Will check whether the handler can be used first.
---@param target WorldActor
---@return boolean used
function FlaskHandler:tryUse(target)
    if not self:canUse(target) then
        return false
    end
    self:use(target)
    return true
end

--- Get the title for the handler list. Can be overridden to display custom titles
--- to differentiate between handler instances.
---@return string
function FlaskHandler:getListTitle()
    local prefix = ""
    if self:getFlaskName() ~= self.config.flaskName then
        prefix = "ERROR! "
    end

    return ("%s[%d] %s (%s)"):format(prefix, self.config.slot, self.config.flaskName, self.shortName)
end

---@param key string Unique key for UI elements.
---@param target WorldActor? The target, which will be used for the debug views.
function FlaskHandler:draw(key, target)
    local description = self.description:gsub('%s+', ' '):gsub('^%s', '')
    if description ~= '' then
        ImGui.TextWrapped(description)
    end

    self:drawSettings(key)

    if ImGui.TreeNode("Conditions##combat_flask_handler_conditions_" .. key) then
        for i, config in ipairs(self.conditions) do
            if ImGui.Button("X##combat_flask_handler_conditions_remove_" .. key .. '_' .. i) then
                table.remove(self.conditions, i)
            end
            ImGui.SameLine()
            Conditions.Draw(key .. '_' .. i, config)
        end
        if ImGui.Button("Add condition##combat_flask_handler_conditions_add_" .. key) then
            table.insert(self.conditions, Conditions.NewConfig())
        end
        ImGui.TreePop()
    end

    if ImGui.TreeNode("Debug##combat_flask_handler_debug_view" .. key) then
        self:_drawDebug(target)
        ImGui.TreePop()
    end
end

--- Formats a duration in ticks to seconds with 3 decimals. (1.234s)
---@param duration number Duration in ticks
---@return string formatted
local function formatDuration(duration)
    return ("%.3fs"):format(duration / 1000)
end

--- Draws debug information for the skill handler. Additional debug information
--- can be added by overriding the `FlaskHandler:drawDebug()` method.
---@param target WorldActor?
function FlaskHandler:_drawDebug(target)
    local now = Infinity.Win32.GetTickCount()
    local flask = self:getFlask()

    local canUse, reason = self:canUse(target)
    ImGui.Text("Can Use: " .. tostring(canUse))
    ImGui.Text("Reason: " .. (reason or "None"))

    ImGui.Separator()
    ImGui.Text(("Cost: %d"):format(self:getCost()))
    ImGui.Text(("Charges: %d"):format(self:getCurrentCharges()))

    ImGui.Separator()
    ImGui.Text("Last Use: " .. (self.lastUseTick == 0 and 'Never' or formatDuration(now - self.lastUseTick) .. ' ago'))

    ImGui.Separator()
    -- ImGui.Text(("Item Class: %s"):format(flask and flask:getItemClass()))
    ImGui.Text(("Rarity: %s"):format(flask and flask:getRarity() or "Unknown"))

    self:drawDebug(target)
end

--- Overridable function to draw additional debug information.
---@param target WorldActor?
function FlaskHandler:drawDebug(target)
end

---@alias PoE2Lib.Combat.FlaskHandler.CanHandle fun(flask: ItemActor, name: string, flaskType: integer, localStats: table<Stat, integer>): boolean

--- This is for ease of use, so handlers can call this to get type information
--- for the parameters instead of having to document them if they were to set
--- the property directly.
---@param canHandle PoE2Lib.Combat.FlaskHandler.CanHandle
function FlaskHandler:setCanHandle(canHandle)
    self.canHandle = canHandle
end

--------------------------------------------------------------------------------
-- Utility functions
--
-- Provide ergonomic access to engine/API calls.
--------------------------------------------------------------------------------

---@return ItemActor? flask
function FlaskHandler:getFlask()
    return self.caches.item:getValue()
end

function FlaskHandler:getFlaskName()
    local flask = self:getFlask()
    if flask == nil then
        return '(No flask)'
    end

    -- CMods names
    local uniqueName = flask:getItemName()
    if uniqueName ~= "" then
        return uniqueName
    end

    -- Base item name
    return flask:getName()
end

---@param id number
---@return number value
function FlaskHandler:getLocalStat(id)
    local flask = self:getFlask()
    if flask == nil then
        return 0
    end

    for stat, value in pairs(flask:getStatsLocal()) do
        if stat.Id == id then
            return value
        end
    end

    return 0
end

--- Get the stat value by ID on the local player. Will return 0 if the value
--  cannot be found.
---@param id number
---@return number value
function FlaskHandler:getPlayerStat(id)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if not lPlayer then
        return 0
    end

    return lPlayer:getStatValue(id)
end

function FlaskHandler:getCurrentCharges()
    local flask = self:getFlask()
    if flask == nil then
        return 0
    end
    return flask:getCurrentCharges()
end

function FlaskHandler:getCost()
    local flask = self:getFlask()
    if flask == nil then
        return 0
    end

    local base = flask:getChargesPerUse()
    local localModifier = (1 + (self:getLocalStat(FlaskStats.LocalChargesUsed) / 100))
    local playerModifier = (1 + (self:getPlayerStat(FlaskStats.FlaskChargesUsed) / 100))
    if flask:getFlaskType() == EFlaskType_Mana then
        playerModifier = playerModifier + (self:getPlayerStat(FlaskStats.FlaskManaChargesUsed) / 100)
    end
    return math.floor(base * localModifier * playerModifier)
end

---@param name string
---@return boolean
function FlaskHandler:hasBuff(name)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    return lPlayer:hasBuff(name)
end

---@param name string
---@return Buff?
function FlaskHandler:getBuff(name)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    for _, buff in pairs(lPlayer:getBuffs()) do
        if buff:getKey() == name then
            return buff
        end
    end
    return nil
end

---@type table<string, number>
local LockedBuffUses = {}

---@param name string?
---@param duration integer?
function FlaskHandler:lockBuffUse(name, duration)
    if name ~= nil then
        LockedBuffUses[name] = math.max(Infinity.Win32.GetTickCount() + (duration or 200), LockedBuffUses[name] or 0)
    end
end

---@param name string
---@return boolean locked
function FlaskHandler:isBuffUseLocked(name)
    if name == nil then
        return false
    end
    return (LockedBuffUses[name] or 0) > Infinity.Win32.GetTickCount()
end

--------------------------------------------------------------------------------
-- Base checks
--
-- Implementations for common checks for handlers.
--------------------------------------------------------------------------------

---@param target WorldActor?
---@return boolean ok, string? reason
function FlaskHandler:checkConditions(target)
    for _, config in pairs(self.conditions) do
        if not Conditions.Check(config, target, self) then
            -- Strip % symbol because this causes rendering errors, due to fmt strings
            local reason = ("Condition failed: %s"):format((config.label):gsub("%%", ""))
            return false, reason
        end
    end
    return true, nil
end

function FlaskHandler:hasEnoughCharges()
    return self:getCurrentCharges() >= self:getCost()
end

---@class PoE2Lib.Combat.FlaskHandler.BaseCanUseChecks
local BaseCanUseChecks = { --
    --- Check if the flask is enabled.
    ---@type boolean?
    enabled = true,
    --- Check if the flask name still matches.
    ---@type boolean?
    flaskName = true,
    --- Check if the flask is of a usable type.
    --- @type boolean?
    flaskType = true,
    --- Check if the flask has enough charges.
    ---@type boolean?
    charges = true,
    --- Check the configured conditions on the skill.
    ---@type boolean?
    conditions = true,
    --- Check the internal cooldown
    ---@type boolean?
    internalCooldown = true,
}

--- Contains some base checks that are almost always relevant.
---
--- This is not complete enough to be put in `:canUse()` as the default
--- implementation. Putting it in a separate method will force the handlers to
--- define their own `:canUse()` methods that should be more complete.
---
--- Checks can be ignored by using the `checks` parameter. See the definition
--- `PoE2Lib.Combat.FlaskHandler.BaseCanUseChecks` for the contents. By
--- default all checks are enabled and are only ignored when explicitly disabled
--- with the value `false`. E.g.: `self:baseCanUse(target, { cooldown = false })`
---
--- This is slightly less ergonomic to use, but it prevents oopsies when we
--- forget to fill out `:canUse()`.
---
---@param target WorldActor?
---@param checks? PoE2Lib.Combat.FlaskHandler.BaseCanUseChecks
---@return boolean ok, string? reason
function FlaskHandler:baseCanUse(target, checks)
    if checks == nil then
        checks = {}
    end

    local flask = self:getFlask()
    if flask == nil then
        return false, "flask not found"
    end

    if checks.enabled ~= false then
        if not self.config.enabled then
            return false, "handler is disabled"
        end
    end

    if checks.flaskName ~= false then
        if self:getFlaskName() ~= self.config.flaskName then
            return false, "flask name mismatch"
        end
    end

    if checks.flaskType ~= false then
        local flaskType = flask:getFlaskType()
        if flaskType ~= EFlaskType_Life and flaskType ~= EFlaskType_Mana then
            return false, "not a usable flask type"
        end
    end

    if checks.conditions ~= false then
        local conditionsOk, conditionsReason = self:checkConditions(target)
        if not conditionsOk then
            return false, ("condition failed (%s)"):format(conditionsReason)
        end
    end

    if checks.charges ~= false then
        if not self:hasEnoughCharges() then
            return false, "not enough charges"
        end
    end

    if checks.internalCooldown ~= false then
        if (Infinity.Win32.GetTickCount() - self.lastUseTick) < self.internalCooldown then
            return false, 'internal cooldown'
        end
    end

    return true, nil
end

--------------------------------------------------------------------------------
-- Abstract methods
--
-- These are the key methods that may be overridden by handlers for
-- customisation.
--------------------------------------------------------------------------------

--- Check whether the skill can be used.
---@param target WorldActor?
---@return boolean ok, string? reason
function FlaskHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    return false, nil
end

--- Use the skill. Contains a default implementation for each target type. The
--- implementing handler can override this for custom logic.
---
--- The `location` parameter is optional. It will automatically be set to the
--- location of the target if the target is given. Otherwise it will use the
--- location of the player.
---
---@param target WorldActor?
---@param location? Vector3
function FlaskHandler:use(target, location)
    Infinity.PoE2.UseFlask(self.slot - 1)
    self:onUse()
end

function FlaskHandler:onUse()
    self.lastUseTick = Infinity.Win32.GetTickCount()
end

---@param target WorldActor?
function FlaskHandler:updateTarget(target)
end

--- This is used to signal that movement should be prevented. E.g. for
--- channelling skills to avoid interrupting it.
---@param target WorldActor?
---@return boolean shouldPrevent
function FlaskHandler:shouldPreventMovement(target)
    return false
end

--- Will draw the settings for the handler. A key can be provided to provide
--- uniqueness to the ImGui labels. The implementing handler should always use
--- this key.
---@param key string|''
function FlaskHandler:drawSettings(key)
end

return FlaskHandler
