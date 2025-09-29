local Class = require("CoreLib.Class")
local Conditions = require("PoE2Lib.Combat.Conditions")

--- CombatAddon is an abstract addon that serves as a general API definition
--- for combat addons. It has some default implementations, but the core of it
--- should be implemented by the combat addons (`:canUse()` and `:use()`).
---
---@class PoE2Lib.Combat.CombatAddon : Class
---@overload fun(config: PoE2Lib.Combat.CombatAddon.Config): PoE2Lib.Combat.CombatAddon
---@diagnostic disable-next-line: assign-type-mismatch
local CombatAddon = Class()

--- This should be overridden by each addon and is used for display.
---@type string
CombatAddon.shortName = 'Base'

--- This can be overridden by each addon to show a short informative
--- description to the user about the addon.
---@type string
CombatAddon.description = [[]]

--- The combat addon config is a serializable table containing all the fields
--- necessary to construct a combat addon. Combat addons are class
--- objects and not simple tables, and thus contain a lot of extra fields that
--- don't serialize cleanly.
---@class PoE2Lib.Combat.CombatAddon.Config
CombatAddon.config = { --
    --- The full class name of the addon, e.g. WeaponSwapCombatAddon.
    ---@type string
    addonName = "",
    --- Whether the addon is enabled.
    enabled = true,
    --- Contains addon specific settings. See CombatAddon.settings for more
    --- info.
    ---@type table
    settings = {},
    ---@type PoE2Lib.Combat.Conditions.Config[]
    conditions = {},
}

--- Contains addon specific settings. The addon is responsible for drawing
--- the UI to change the settings with the method `:drawSettings()`.
---@type table
CombatAddon.settings = {}

---@type PoE2Lib.Combat.Conditions.Config[]
CombatAddon.conditions = {}

--- Last use tick
---@type number
CombatAddon.lastUseTick = 0

--- Internal cooldown so actions can't happen too often. Value is time in ticks.
--- A value of 0 is effectively no cooldown.
---@type number
CombatAddon.internalCooldown = 0

--- The settings paramater should be a settings table that the addon can use.
--- The addon will retain a reference to this table, so it cooperates with
--- MagLib.Core.Settings.
---
--- WARNING: This method cannot really be overridden, because there is too much
--- handling in here. There is a `:setup()` method for that which is called at
--- the end of `:init()`, which the addon may override for the same effect.
---@param config PoE2Lib.Combat.CombatAddon.Config
function CombatAddon:init(config)
    assert(type(config) == 'table', 'config is not a table')
    assert(type(config.settings) == 'table', 'config.settings is not a table')
    assert(type(config.conditions) == 'table', 'config.conditions is not a table')

    self.config = config
    self.conditions = config.conditions

    -- Complete assigns any missing values from b to a. We do this because we
    -- want to retain the original settings table reference, because it's shared
    -- by the settings addon that handles storing it. We want to complete the
    -- settings because unexpected missing values on the settings can be
    -- problematic for the implementing addon.
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
    -- by the addon.
    self.settings = config.settings

    -- Define a metatable that will look up methods in the CombatAddon class,
    -- but bind the child class instance when the methods are called.
    self._super_mt = setmetatable({}, {
        __index = function(_, k)
            if type(CombatAddon[k]) == 'function' then
                return function(_, ...)
                    return CombatAddon[k](self, ...)
                end
            else
                return CombatAddon[k]
            end
        end,
    })

    self:setup()
end

--- This method can be overridden by the addon to add additional logic to the
--- `:init()` method.
function CombatAddon:setup()
end

--- Some magic that allows for `self:super():something()` calls by child classes
--- without mutating the child class, while still binding self to the child
--- class. This allows the child class to override a method, but still call the
--- original method through a short syntax.
---@return PoE2Lib.Combat.CombatAddon
function CombatAddon:super()
    return self._super_mt
end

--- This function can be overridden by implementations to 'bind' OnPulse without
--- having to register a callback. This is available in case an implementation
--- needs to check/update every pulse.
function CombatAddon:onPulse()
end

--- Try to use the addon. Will check whether the addon can be used first.
---@param target WorldActor
---@return boolean used
function CombatAddon:tryUse(target)
    if not self:canUse(target) then
        return false
    end
    self:use(target)
    return true
end

--- Get the title for the addon list. Can be overridden to display custom titles
--- to differentiate between addon instances.
---@return string
function CombatAddon:getListTitle()
    return self.shortName
end

---@param key string Unique key for UI elements.
---@param target WorldActor? The target, which will be used for the debug views.
function CombatAddon:draw(key, target)
    local description = self.description:gsub('%s+', ' '):gsub('^%s', '')
    if description ~= '' then
        ImGui.TextWrapped(description)
    end

    self:drawSettings(key)

    if ImGui.TreeNode("Conditions##combat_addon_conditions_" .. key) then
        for i, config in ipairs(self.conditions) do
            if ImGui.Button("X##combat_addon_conditions_remove_" .. key .. '_' .. i) then
                table.remove(self.conditions, i)
            end
            ImGui.SameLine()
            Conditions.Draw(key .. '_' .. i, config)
        end
        if ImGui.Button("Add condition##combat_addon_conditions_add_" .. key) then
            table.insert(self.conditions, Conditions.NewConfig())
        end
        ImGui.TreePop()
    end

    if ImGui.TreeNode("Debug##combat_addon_debug_view" .. key) then
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

--- Draws debug information for the skill addon. Additional debug information
--- can be added by overriding the `CombatAddon:drawDebug()` method.
---@param target WorldActor?
function CombatAddon:_drawDebug(target)
    local now = Infinity.Win32.GetTickCount()

    local canUse, reason = self:canUse(target)
    ImGui.Text("Can Use: " .. tostring(canUse))
    ImGui.Text("Reason: " .. (reason or "None"))

    ImGui.Separator()
    ImGui.Text("Last Use: " .. (self.lastUseTick == 0 and 'Never' or formatDuration(now - self.lastUseTick) .. ' ago'))
    ImGui.Text("Internal CD: " .. (now > (self.lastUseTick + self.internalCooldown) and 'Ready' or formatDuration(self.lastUseTick + self.internalCooldown - now) .. ' left'))

    self:drawDebug(target)
end

--- Overridable function to draw additional debug information.
---@param target WorldActor?
function CombatAddon:drawDebug(target)
end

--------------------------------------------------------------------------------
-- Utility functions
--
-- Provide ergonomic access to engine/API calls.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Base checks
--
-- Implementations for common checks for addons.
--------------------------------------------------------------------------------

---@param target WorldActor?
---@return boolean ok, string? reason
function CombatAddon:checkConditions(target)
    for _, config in pairs(self.conditions) do
        if not Conditions.Check(config, target, self) then
            -- Strip % symbol because this causes rendering errors, due to fmt strings
            local reason = ("Condition failed: %s"):format((config.label):gsub("%%", ""))
            return false, reason
        end
    end
    return true, nil
end

---@class PoE2Lib.Combat.CombatAddon.BaseCanUseChecks
local BaseCanUseChecks = { --
    --- Check if the skill is enabled.
    ---@type boolean?
    enabled = true,
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
--- implementation. Putting it in a separate method will force the addons to
--- define their own `:canUse()` methods that should be more complete.
---
--- Checks can be ignored by using the `checks` parameter. See the definition
--- `PoE2Lib.Combat.CombatAddon.BaseCanUseChecks` for the contents. By
--- default all checks are enabled and are only ignored when explicitly disabled
--- with the value `false`. E.g.: `self:baseCanUse(target, { conditions = false })`
---
--- This is slightly less ergonomic to use, but it prevents oopsies when we
--- forget to fill out `:canUse()`.
---
---@param target WorldActor?
---@param checks? PoE2Lib.Combat.CombatAddon.BaseCanUseChecks
---@return boolean ok, string? reason
function CombatAddon:baseCanUse(target, checks)
    if checks == nil then
        checks = {}
    end

    if checks.enabled ~= false then
        if not self.config.enabled then
            return false, "addon is disabled"
        end
    end

    if checks.conditions ~= false then
        local conditionsOk, conditionsReason = self:checkConditions(target)
        if not conditionsOk then
            return false, ("condition failed (%s)"):format(conditionsReason)
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
-- Cooldown management
--
-- Cooldowns can be a little more complex, so here is a separate section for it
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Usage methods
--
-- These are methods to use skills. Various skills tend to use different packets
-- to cast them.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Abstract methods
--
-- These are the key methods that may be overridden by addons for
-- customisation.
--------------------------------------------------------------------------------

--- Check whether the skill can be used.
---@param target WorldActor?
---@return boolean ok, string? reason
function CombatAddon:canUse(target)
    return false, nil
end

--- Use the skill. Contains a default implementation for each target type. The
--- implementing addon can override this for custom logic.
---
--- The `location` parameter is optional. It will automatically be set to the
--- location of the target if the target is given. Otherwise it will use the
--- location of the player.
---
---@param target WorldActor?
---@param location? Vector3
function CombatAddon:use(target, location)
    self:onUse()
end

function CombatAddon:onUse()
    self.lastUseTick = Infinity.Win32.GetTickCount()
end

---@param target WorldActor?
function CombatAddon:updateTarget(target)
end

--- This is used to signal that movement should be prevented. E.g. for
--- channelling skills to avoid interrupting it.
---@param target WorldActor?
---@return boolean shouldPrevent
function CombatAddon:shouldPreventMovement(target)
    return false
end

--- Will draw the settings for the addon. A key can be provided to provide
--- uniqueness to the ImGui labels. The implementing addon should always use
--- this key.
---@param key string|''
function CombatAddon:drawSettings(key)
end

---@return string
function CombatAddon:getDisplayedName()
    return self.config.addonName
end

return CombatAddon
