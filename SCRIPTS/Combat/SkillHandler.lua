local Class = require("CoreLib.Class")
local PulseCache = require("CoreLib.PulseCache")
local UI = require("CoreLib.UI")
local Math = require("CoreLib.Math")
local Vector = require("CoreLib.Vector")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local Conditions = require("PoE2Lib.Combat.Conditions")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

local StatsFile = Infinity.PoE2.getFileController():getStatsFile()

--- The action update interval. This matches the interval that the game uses.
local UPDATE_ACTION_INTERVAL = 75

--- SkillHandler is an abstract handler that serves as a general API definition
--- for skill handlers. It has some default implementations, but the core of it
--- should be implemented by the skill handlers (`:canUse()` and `:use()`).
---
---@class PoE2Lib.Combat.SkillHandler : Class
---@overload fun(config: PoE2Lib.Combat.SkillHandler.Config.Partial): PoE2Lib.Combat.SkillHandler
---@diagnostic disable-next-line: assign-type-mismatch
local SkillHandler = Class()

--- This should be overridden by each handler and is used for display.
---@type string
SkillHandler.shortName = 'Base'

--- This can be overridden by each handler to show a short informative
--- description to the user about the handler.
---@type string
SkillHandler.description = [[]]

--- This function is called to generate a default handler for a skill. It does
--- not stop the handler from being used with a skill. This should be done with
--- `:canUse()` and `:use()`. This is not defined as a method, because it's a
--- property of the class.
---@param skill SkillWrapper
---@param stats SkillStatWrapper
---@param name string Displayed name
---@param grantedEffectsPerLevel GrantedEffectsPerLevel
---@param grantedEffect GrantedEffect
---@param activeSkill ActiveSkill
---@param activeSkillId string
SkillHandler.canHandle = function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return false
end

--- The skill handler config is a serializable table containing all the fields
--- necessary to construct a skill handler. Skill handlers are class
--- objects and not simple tables, and thus contain a lot of extra fields that
--- don't serialize cleanly.
---@class PoE2Lib.Combat.SkillHandler.Config
--- The full class name of the handler, e.g. AuraSkillHandler.
---@field handlerName string
---@field skillId integer
--- The skill name is stored when setting the skill. This way we can check
--- whether the skill gem has moved or not, and then prompt the user to
--- select the correct skill ID again.
---@field skillName string
--- Whether the handler is enabled.
---@field enabled boolean
--- Contains handler specific settings. See SkillHandler.settings for more
--- info.
---@field settings table
---@field conditions PoE2Lib.Combat.Conditions.Config[]
---@field forceChannelling boolean
---@field doubleUsePreventionEnabled boolean
---@field doubleUsePreventionDuration number
SkillHandler.config = { --
    handlerName = "",
    skillId = 0,
    skillName = "",
    enabled = true,
    settings = {},
    conditions = {},
    forceChannelling = false,
    targetTempestBell = false,
    doubleUsePreventionEnabled = false,
    doubleUsePreventionDuration = 0,
}

---@class(partial) PoE2Lib.Combat.SkillHandler.Config.Partial : PoE2Lib.Combat.SkillHandler.Config
---@field handlerName string
---@field skillId number
---@field skillName string

---@type number
SkillHandler.skillId = 0

--- Contains handler specific settings. The handler is responsible for drawing
--- the UI to change the settings with the method `:drawSettings()`.
---@type table
SkillHandler.settings = {}

---@type PoE2Lib.Combat.Conditions.Config[]
SkillHandler.conditions = {}

---@type PulseCache
SkillHandler.cachedSkillObject = nil

--- Last use tick
---@type number
SkillHandler.lastUseTick = 0

--- Last executed tick
---@type number
SkillHandler.lastExecuteTick = 0

--- Previous last executed tick
---@type number
SkillHandler.prevExecuteTick = 0

---@type number
SkillHandler.lastUpdateActionLocation = 0

---@type number
SkillHandler.lastStopAction = 0

---@type boolean
SkillHandler.nextActionInitiatedByThis = false

---@type boolean
SkillHandler.thisActionInitiatedByThis = false

--- Used to cache the targetable corpse. Contains the last corpse actor. This is
--- bound to the skill handler instead of global, because different handlers
--- might have different search parameters.
---@type WorldActor?
SkillHandler.lastTargetableCorpseActor = nil

--- Used to cache the targetable corpse. Contains the last update tick.
---@type number
SkillHandler.lastTargetableCorpseFrame = 0

---@class PoE2Lib.Combat.SkillHandler.SharedState
local SharedState = { --
    --- Skill usage locks out subsequent skill uses until the animation would
    --- have expired. Skill animations can be cancelled by moving, but the
    --- lockout cannot expire faster than that. This prevents the player from
    --- spamming skills faster than the animation would allow by cancelling it.
    LastSkillExpiration = 0,
    ---@type PoE2Lib.Combat.SkillHandler?
    LastSkillExpirationHandler = nil,

    CurrentAction = PulseCache(function()
        return Infinity.PoE2.getLocalPlayer():getCurrentAction()
    end),

    CurrentActionSkillId = PulseCache(function()
        local currentAction = SkillHandler.SharedState.CurrentAction:getValue()
        if not currentAction then
            return nil
        end

        local skill = currentAction:getSkill()
        if not skill then
            return nil
        end

        return skill:getSkillIdentifier()
    end),

    TempestBells = PulseCache(function()
        return Infinity.PoE2.getActorsByMetaPath("Metadata/Effects/Spells/monk_bell/tempest_bell")
    end),
    HasTempestBell = PulseCache(function()
        for _, skill in pairs(Infinity.PoE2.getLocalPlayer():getActiveSkills()) do
            if CombatUtils.GetActiveSkillID(skill) == "tempest_bell" then
                return true
            end
        end
        return false
    end),
    FrostWalls = PulseCache(function()
        return Infinity.PoE2.getActorsByMetaPath("Metadata/MiscellaneousObjects/FrostWall/FrostWall")
    end),
    HasFrostWall = PulseCache(function()
        for _, skill in pairs(Infinity.PoE2.getLocalPlayer():getActiveSkills()) do
            if CombatUtils.GetActiveSkillID(skill) == "frost_wall_new" then
                return true
            end
        end
        return false
    end),
    IsMounted = PulseCache(function()
        -- TODO: Improve detection, see also SummonRhoaMountSkillHandler.
        for _, actor in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
            if actor:getAnimatedMetaPath() == "Metadata/Monsters/Mounts/Rhoa/RhoaMountPlayerSummoned.ao" then
                if actor:isAlive() and not actor:isTargetable() then
                    return true
                end
            end
        end
        return false
    end),
}
SkillHandler.SharedState = SharedState

-- TODO: Maybe add descriptions on each handler to describe it to the user.

--- Creates a version of the SkillHandler specifically for one real skill object
--- in the game.
---
--- The settings paramater should be a settings table that the handler can use.
--- The handler will retain a reference to this table, so it cooperates with
--- MagLib.Core.Settings.
---
--- WARNING: This method cannot really be overridden, because there is too much
--- handling in here. There is a `:setup()` method for that which is called at
--- the end of `:init()`, which the handler may override for the same effect.
---@param config PoE2Lib.Combat.SkillHandler.Config.Partial
function SkillHandler:init(config)
    assert(type(config) == "table", "config is not a table")
    assert(config.handlerName ~= nil and config.handlerName ~= "", "invalid handlerName")
    assert(config.skillId ~= nil and config.skillId ~= 0, "invalid skillId")
    assert(config.skillName ~= nil and config.skillName ~= "", "invalid skillName")

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
            -- If type(v) is a table, then type(a[k]) is also a table, given
            -- the previous condition.
            if type(v) == 'table' then
                -- If a[k] is nil, then we create a new table for it, such that
                -- it won't use the same reference as b[k].
                if a[k] == nil then
                    a[k] = {}
                end
                complete(a[k], v)
                -- Assign mismatched types, this ensures that we can't get
                -- errors on wrong types. This will also ensure that missing values
                -- are assigned, because if type(a[k]) is nil, then it cannot be
                -- equal to type(v) which can never be nil.
            elseif type(v) ~= type(a[k]) then
                a[k] = v
            end
        end
        return a
    end

    ------------------
    -- Init config
    ------------------

    -- Complete the config with the default config in case there are missing entries.
    complete(config, SkillHandler.config)

    ------------------
    -- Copy the config
    ------------------

    self.config = config
    self.conditions = config.conditions
    self.skillId = config.skillId

    -- Complete the settings table with the default settings.
    complete(config.settings, self.settings)
    -- Now we move the completed settings into self.settings, so it's accessible
    -- by the handler.
    self.settings = config.settings

    ------------------
    -- Init properties
    ------------------

    self.cachedSkillObject = PulseCache(function()
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return nil
        end
        return lPlayer:getActiveSkill(self.skillId)
    end)

    -- Define a metatable that will look up methods in the SkillHandler class,
    -- but bind the child class instance when the methods are called.
    self._super_mt = setmetatable({}, {
        __index = function(_, k)
            if type(SkillHandler[k]) == 'function' then
                return function(_, ...)
                    return SkillHandler[k](self, ...)
                end
            else
                return SkillHandler[k]
            end
        end,
    })

    self:setup()
end

---@param skillId integer
function SkillHandler:Simple(skillId)
    local SkillHandlers = require("PoE2Lib.Combat.SkillHandlers")
    return self({
        handlerName = SkillHandlers.NameOf(self) or "(Unknown)",
        skillId = skillId,
        skillName = CombatUtils.GetSkillDisplayedName(Infinity.PoE2.getLocalPlayer():getActiveSkill(skillId)) or "(Unknown)",
    })
end

--- This method can be overridden by the handler to add additional logic to the
--- `:init()` method.
function SkillHandler:setup()
end

--- Some magic that allows for `self:super():something()` calls by child classes
--- without mutating the child class, while still binding self to the child
--- class. This allows the child class to override a method, but still call the
--- original method through a short syntax.
---@return PoE2Lib.Combat.SkillHandler
function SkillHandler:super()
    return self._super_mt
end

--- This function can be overridden by implementations to 'bind' OnPulse without
--- having to register a callback. This is available in case an implementation
--- needs to check/update every pulse.
function SkillHandler:onPulse()
end

--- This function can be overridden by implementations to 'bind' OnRenderD2D
--- without having to register a callback. This is available in case an
--- implementation needs to draw on the screen.
function SkillHandler:onRenderD2D()
end

function SkillHandler:onSkillExecute()
    local now = Infinity.Win32.GetTickCount()
    self.prevExecuteTick = self.lastExecuteTick
    self.lastExecuteTick = now

    self.thisActionInitiatedByThis = self.thisActionInitiatedByThis or self.nextActionInitiatedByThis
    self.nextActionInitiatedByThis = false

    self:startCooldown(self.lastUseTick)

    -- Triggered skills do not start animations.
    if not self:hasStat(SkillStats.IsTriggered) then
        self:startAnimation(self.lastUseTick)
    end
end

function SkillHandler:onSkillEnd()
    self.thisActionInitiatedByThis = false
end

--- Try to use the skill. Will check whether the skill can be used first.
---@param target WorldActor
---@return boolean used
function SkillHandler:tryUse(target)
    if not self:canUse(target) then
        return false
    end
    self:use(target)
    return true
end

---@param key string Unique key for UI elements.
---@param target WorldActor? The target, which will be used for the debug views.
function SkillHandler:draw(key, target)
    local description = self.description:gsub('%s+', ' '):gsub('^%s', '')
    if description ~= '' then
        ImGui.TextWrapped(description)
    end

    self:drawSettings(key)

    if SharedState.HasTempestBell:getValue() then
        _, self.config.targetTempestBell = ImGui.Checkbox("Target Tempest Bell##skill_handler_target_tempest_bell_" .. key, self.config.targetTempestBell or false)
    end

    if not self:hasStat(SkillStats.IsChannelled) then
        _, self.config.forceChannelling = ImGui.Checkbox("Force channelling##skill_handler_force_channelling_" .. key, self.config.forceChannelling or false)
    end

    if ImGui.TreeNode("Conditions##skill_handler_conditions_" .. key) then
        -- Add a note so users don't think conditions are required.
        ImGui.TextWrapped('Conditions are built into the handlers and are not required. But conditions can be used to set for example specific bossing skills.')
        for i, config in ipairs(self.conditions) do
            if ImGui.Button("X##skill_handler_conditions_remove_" .. key .. '_' .. i) then
                table.remove(self.conditions, i)
            end
            ImGui.SameLine()
            Conditions.Draw(key .. '_' .. i, config)
        end
        if ImGui.Button("Add condition##skill_handler_conditions_add_" .. key) then
            table.insert(self.conditions, Conditions.NewConfig())
        end
        ImGui.TreePop()
    end

    if ImGui.TreeNode("Debug##skill_handler_debug_view" .. key) then
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
--- can be added by overriding the `SkillHandler:drawDebug()` method.
---@param target WorldActor?
function SkillHandler:_drawDebug(target)
    local now = Infinity.Win32.GetTickCount()
    local skill = self:getSkillObject()

    ImGui.Text(("Displayed Name: %s"):format(self:getDisplayedName()))
    ImGui.Text(("Active Skill ID: %s"):format(self:getActiveSkillId()))

    ImGui.Separator()
    local canUse, reason = self:canUse(target)
    ImGui.Text("Can Use: " .. tostring(canUse))
    ImGui.Text("Reason: " .. (reason or "None"))

    ImGui.Separator()
    local costOk, costReason = self:checkCost()
    ImGui.Text("Cost Check: " .. tostring(costOk))
    ImGui.Text("Cost Type: " .. (costReason or "None"))

    ImGui.Separator()
    local associatedBuffs = self:getAssociatedBuffs()
    ImGui.Text(("Associated Buffs: %d"):format(#associatedBuffs))
    for _, buff in pairs(associatedBuffs) do
        ImGui.BulletText(("[%s] %s: %d"):format(buff:getKey(), buff:getDisplayName(), buff:getCharges()))
    end

    ImGui.Separator()
    ImGui.Text("Last Use: " .. (self.lastUseTick == 0 and 'Never' or formatDuration(now - self.lastUseTick) .. ' ago'))
    ImGui.Text("Last Execute: " .. (self.lastExecuteTick == 0 and 'Never' or formatDuration(now - self.lastExecuteTick) .. ' ago'))
    ImGui.Text("Execute - Use: " .. formatDuration(self.lastUseTick - self.lastExecuteTick))

    do
        local deltaTick = self.lastExecuteTick - self.prevExecuteTick
        local limit = self:calculateAnimationDuration()
        ImGui.Text(("Last Execute Delta: %d ticks"):format(deltaTick))
        UI.Tooltip("The delta between the last two skill executes.")
        ImGui.Text(("Delta Optimum Diff: %d ticks"):format(limit - deltaTick))
        UI.Tooltip("The difference between the delta and the optimum limit; the animation duration. (limit - delta)")
    end

    ImGui.Separator()
    ImGui.Text("Charges: " .. tostring(skill and skill:getCharges()))
    ImGui.Text("Max Charges: " .. tostring(skill and skill:getMaxCharges()))
    ImGui.Text("Combo Count: " .. tostring(self:getComboCount()))

    ImGui.Separator()
    ImGui.Text("Animation Duration: " .. formatDuration(self:calculateAnimationDuration()))
    ImGui.Text("Current Animation: " .. (now > self.animationExpiration and 'Ready' or formatDuration(self.animationExpiration - now)))
    ImGui.Text("Current Animation CD: " .. (now > self.cooldownExpiration and 'Ready' or formatDuration(self.cooldownExpiration - now)))
    ImGui.Text("Should Prevent Movement: " .. (self:shouldPreventMovement(target) and 'Yes' or 'No'))
    ImGui.Text("Is In Animation: " .. (self:isInAnimation(now) and 'Yes' or 'No'))

    ImGui.Separator()
    ImGui.Text("Cast Method: " .. tostring(CastMethods.NameByMethodMap[self:getCastMethod() or '']))
    ImGui.Text("Stage: " .. tostring(skill and skill:getSkillUseStage() or nil))
    ImGui.Text("Is Current Action: " .. tostring(self:isCurrentAction()))
    ImGui.Text("Is Channeling Skill: " .. tostring(self:isChannelingSkill()))

    ImGui.Separator()
    if ImGui.TreeNode("Stats") then
        local statWrapper = self:getSkillStatWrapper()
        if statWrapper ~= nil then
            ImGui.Columns(3)
            for statId, statValue in pairs(statWrapper:getStats()) do
                local stat = StatsFile:getById(statId)
                ImGui.Text(tostring(statId))
                ImGui.NextColumn()
                ImGui.Text(stat and stat:getKey() or 'Unknown')
                ImGui.NextColumn()
                ImGui.Text(tostring(statValue))
                ImGui.NextColumn()
            end
            ImGui.Columns(1)
        end
        ImGui.TreePop()
    end

    ImGui.Separator()
    _, self.config.doubleUsePreventionEnabled = ImGui.Checkbox(("Double Use Prevention:##doubleUsePreventionEnabled_%s"):format(self), self.config.doubleUsePreventionEnabled or false)
    ImGui.SameLine()
    UI.WithDisable(not self.config.doubleUsePreventionEnabled, function()
        _, self.config.doubleUsePreventionDuration = ImGui.SliderInt(("ms##doubleUsePreventionDuration_%s"):format(self), self.config.doubleUsePreventionDuration or 0, 0, 1000)
    end)

    self:drawDebug(target)
end

--- Overridable function to draw additional debug information.
---@param target WorldActor?
function SkillHandler:drawDebug(target)
end

---@alias PoE2Lib.Combat.SkillHandler.CanHandle fun(skill: SkillWrapper, stats: SkillStatWrapper, name: string, grantedEffectsPerLevel: GrantedEffectsPerLevel, grantedEffect: GrantedEffect, activeSkill: ActiveSkill, activeSkillId: string): boolean

--- This is for ease of use, so handlers can call this to get type information
--- for the parameters instead of having to document them if they were to set
--- the property directly.
---@param canHandle PoE2Lib.Combat.SkillHandler.CanHandle
function SkillHandler:setCanHandle(canHandle)
    self.canHandle = canHandle
end

--------------------------------------------------------------------------------
-- Utility functions
--
-- Provide ergonomic access to engine/API calls.
--------------------------------------------------------------------------------

--- Get the skill object by the internal skill id.
---@return SkillWrapper?
function SkillHandler:getSkillObject()
    return self.cachedSkillObject:getValue()
end

---@return GrantedEffectsPerLevel?
function SkillHandler:getGrantedEffectsPerLevel()
    local skill = self:getSkillObject()
    if skill == nil then
        return nil
    end
    return skill:getGrantedEffectsPerLevel()
end

---@return GrantedEffect?
function SkillHandler:getGrantedEffect()
    local grantedEffectsPerLevel = self:getGrantedEffectsPerLevel()
    if grantedEffectsPerLevel == nil then
        return nil
    end
    return grantedEffectsPerLevel:getGrantedEffect()
end

---@return ActiveSkill?
function SkillHandler:getActiveSkill()
    local grantedEffect = self:getGrantedEffect()
    if grantedEffect == nil then
        return nil
    end
    return grantedEffect:getActiveSkill()
end

---@return string | '(Unknown)'
function SkillHandler:getDisplayedName()
    -- local activeSkill = self:getActiveSkill()
    -- if activeSkill == nil then
    --     return '(Unknown)'
    -- end
    -- return activeSkill:getDisplayedName()
    local skill = self:getSkillObject()
    return skill and CombatUtils.GetSkillDisplayedName(skill) or '(Unknown)'
end

function SkillHandler:getFullSkillTitle()
    return ("[%X] <%s> %s"):format(self.skillId, (self:getWeaponSlot() == 1 and "I" or "II"), self.config.skillName)
end

---@return string | 'unknown'
function SkillHandler:getActiveSkillId()
    local activeSkill = self:getActiveSkill()
    if activeSkill == nil then
        return 'unknown'
    end
    return activeSkill:getId()
end

---@return 1 | 2
function SkillHandler:getWeaponSlot()
    return bit.band(self.skillId, 0x1) == 0 and 1 or 2
end

---@return boolean
function SkillHandler:isAuraActive()
    if self:getWeaponSlot() == 1 then
        return self:getSkillObject():isUsedWithWeaponSet1()
    else
        return self:getSkillObject():isUsedWithWeaponSet2()
    end
end

---@return integer
function SkillHandler:countUsedWithWeapon()
    if self:getWeaponSlot() == 1 then
        return self:getSkillObject():countUsedWithWeaponSet1()
    else
        return self:getSkillObject():countUsedWithWeaponSet2()
    end
end

---@return SkillStatWrapper?
function SkillHandler:getSkillStatWrapper()
    local skill = self:getSkillObject()
    if skill == nil then
        return nil
    end
    return skill:getSkillStatWrapper()
end

---@param id number
---@return boolean
function SkillHandler:hasStat(id)
    local statWrapper = self:getSkillStatWrapper()
    if statWrapper == nil then
        return false
    end
    return statWrapper:hasStat(id)
end

--- Get a stat value by ID. Will return 0 if the value cannot be found.
---@param id number?
---@return number
function SkillHandler:getStat(id)
    if id == nil then
        return 0
    end

    local statWrapper = self:getSkillStatWrapper()
    if statWrapper == nil then
        return 0
    end
    return statWrapper:getStats()[id] or 0
end

--- Get the stat value by ID on the local player. Will return 0 if the value
--  cannot be found.
---@param id number
---@return number value
function SkillHandler:getPlayerStat(id)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if not lPlayer then
        return 0
    end
    return lPlayer:getStatValue(id)
end

--- Creates a local map so we don't have to iterate for each target type. This
--- is so we can try each target type in an order as we might prefer one target
--- type over another. This also provides a cleaner syntax to check for a type.
function SkillHandler:mapTargetTypes()
    local activeSkill = self:getActiveSkill()
    if activeSkill == nil then
        return {}
    end

    local map = {}
    for _, targetType in pairs(activeSkill:getActiveSkillTargetTypes()) do
        map[targetType] = true
    end
    return map
end

---@return boolean
function SkillHandler:hasTargetType(targetType)
    return self:mapTargetTypes()[targetType] or false
end

---@param activeSkillType number EActiveSkillType
function SkillHandler:hasActiveSkillType(activeSkillType)
    local activeSkill = self:getActiveSkill()
    if activeSkill == nil then
        return false
    end

    for _, skillType in pairs(activeSkill:getActiveSkillTypes()) do
        if skillType == activeSkillType then
            return true
        end
    end

    return false
end

---@return Buff[]
function SkillHandler:getAssociatedBuffs()
    local skill = self:getSkillObject()
    if skill == nil then
        return {}
    end

    local buffs = {}
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getAssociatedSkillId() == self.skillId then
            table.insert(buffs, buff)
        end
    end
    return buffs
end

local IgnoredAssociatedBuffNames = { --
    -- Arcane Surge Support
    arcane_surge_mana_spent = true,
    -- Lifetap Support
    lifetap_life_spent = true,
    -- Unleash Support
    anticipation = true,
    -- Inspiration Support
    remove_righteous_charges_mana_spent = true,
}

---@return boolean active, string? buffName
function SkillHandler:isAssociatedBuffActive()
    for _, buff in pairs(self:getAssociatedBuffs()) do
        -- Check for secondary buffs from support gems
        local name = buff:getKey()
        if not IgnoredAssociatedBuffNames[name] then
            return true, name
        end
    end

    return false, nil
end

-- ---@return WorldActor[]
-- function SkillHandler:getDeployedObjects()
-- end

---@return boolean isChanneling
function SkillHandler:isChannelingSkill()
    return self:hasStat(SkillStats.IsChannelled) or self.config.forceChannelling
end

---@return boolean isCurrentAction
function SkillHandler:isCurrentAction()
    return SharedState.CurrentActionSkillId:getValue() == self.skillId
end

---@return number rage
function SkillHandler:getRage()
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if not lPlayer then
        return 0
    end

    for _, buff in pairs(lPlayer:getBuffs()) do
        if buff:getKey() == 'rage' then
            return buff:getCharges()
        end
    end

    return 0
end

---@return integer
function SkillHandler:getComboCount()
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if not lPlayer then
        return 0
    end

    for _, comboFinisherSkillWrapper in pairs(lPlayer:getComboFinisherSkillWrappers()) do
        if comboFinisherSkillWrapper:getSkillWrapper():getSkillIdentifier() == self.skillId then
            return comboFinisherSkillWrapper:getComboCount()
        end
    end

    return 0
end

--------------------------------------------------------------------------------
-- Base checks
--
-- Implementations for common checks for handlers
--------------------------------------------------------------------------------

--- Checks the cost of the skill. This is a generic method available for use by
--- implementations and is not used by default.
---@return boolean ok, string? reason
function SkillHandler:checkCost()
    local skill = self:getSkillObject()
    if skill == nil then
        return false, "skill not found by internal ID"
    end

    local lPlayer = Infinity.PoE2.getLocalPlayer()

    if self:hasStat(SkillStats.RageCost) then
        if self:getRage() < self:getStat(SkillStats.RageCost) then
            return false, "rage cost"
        end
    end

    -- Flat mana cost
    if self:hasStat(SkillStats.ManaCost) then
        local current = lPlayer:getMp()

        -- Check for Eldritch Battery
        if lPlayer:getStatValue(SkillStats.EldritchBattery) > 0 then
            current = current + lPlayer:getEs()
        end

        if current < skill:getCost() then
            if self:getStat(SkillStats.UsableWithoutManaCostWhileSurrounded) >= 1 and self:getPlayerStat(SkillStats.IsSurrounded) >= 1 then
                return true, nil
            end
            return false, "flat mana cost"
        end
        return true, nil
    end

    -- Flat life cost
    if self:hasStat(SkillStats.LifeCost) then
        return lPlayer:getHp() > self:getStat(SkillStats.LifeCost), "flat life cost"
    end

    -- Flat ES cost
    if self:hasStat(SkillStats.ESCost) then
        return lPlayer:getEs() > self:getStat(SkillStats.ESCost), "flat ES cost"
    end

    -- Spirit Reservation
    if self:hasStat(SkillStats.SpiritReservation) then
        return lPlayer:getSpirit() >= self:getStat(SkillStats.SpiritReservation), "spirit reservation"
    end

    return true, nil
end

---@param target WorldActor|Vector3 Actor or grid location.
---@param range number Range in grid location units.
---@param checkLineOfSight? boolean
---@param isFlyable? boolean
---@return boolean
function SkillHandler:isInRange(target, range, checkLineOfSight, isFlyable)
    if checkLineOfSight == nil then
        checkLineOfSight = true
    end

    if isFlyable == nil then
        isFlyable = true
    end

    -- If the target is an actor then we 'cast' the target Actor to a location
    -- Vector3.
    local objectSize = 0
    if target.getLocation then
        ---@cast target WorldActor
        objectSize = target:getObjectSize()
        target = target:getLocation()
    end
    ---@cast target Vector3

    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()
    if range + objectSize < pLoc:getDistanceXY(target) then
        return false
    end

    if checkLineOfSight then
        -- Adjust the target location to include object size for offmesh targets
        -- if the skill is not flyable
        local adjusted = isFlyable and target or Vector.resizeXY(target, pLoc, objectSize)
        if not lPlayer:hasLineOfSightTo(adjusted, isFlyable) then
            return false
        end
    end

    return true
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function SkillHandler:getCurrentMaxSkillDistance()
    return 0, false
end

---@param target WorldActor?
---@return boolean ok, string? reason
function SkillHandler:checkConditions(target)
    for _, config in pairs(self.conditions) do
        if not Conditions.Check(config, target, self) then
            -- Strip % symbol because this causes rendering errors, due to fmt strings
            local reason = ("Condition failed: %s"):format((config.label):gsub("%%", ""))
            return false, reason
        end
    end
    return true, nil
end

---@class PoE2Lib.Combat.SkillHandler.BaseCanUseChecks
local BaseCanUseChecks = { --
    --- Check if the skill is enabled.
    ---@type boolean?
    enabled = true,
    --- Check the animation expiration in SharedState.
    ---@type boolean?
    sharedAnimationExpiration = true,
    --- Check if the skill can be used with the current weapon
    ---@type boolean?
    canBeUsedwithWeapon = true,
    --- Check if the displayed name still matches.
    ---@type boolean?
    displayedName = true,
    --- Check if the user has enough resources (mana/life) to cast the skill.
    ---@type boolean?
    cost = true,
    --- Check if the skill has charges.
    ---@type boolean?
    charges = true,
    --- Check if the skill is on cooldown.
    ---@type boolean?
    cooldown = true,
    --- Check the configured conditions on the skill.
    ---@type boolean?
    conditions = true,
    --- Check if there is a targetable corpse if applicable.
    ---@type boolean?
    targetableCorpse = true,
    --- Check if the skill is a triggered skill
    ---@type boolean?
    isTriggered = true,
    --- Check if the game forces walking
    ---@type boolean?
    enforcedWalking = true,
    --- Check if the skill can be used while mounted
    ---@type boolean?
    canUseWhileMounted = true,
    --- Check if the player is in town
    ---@type boolean?
    isInTown = true,
    --- Check if the player has the required combo count to use the skill
    ---@type boolean?
    comboCount = true,
}

--- Contains some base checks that are almost always relevant.
---
--- This is not complete enough to be put in `:canUse()` as the default
--- implementation. Putting it in a separate method will force the handlers to
--- define their own `:canUse()` methods that should be more complete.
---
--- Checks can be ignored by using the `checks` parameter. See the definition
--- `PoE2Lib.Combat.SkillHandler.BaseCanUseChecks` for the contents. By
--- default all checks are enabled and are only ignored when explicitly disabled
--- with the value `false`. E.g.: `self:baseCanUse(target, { cooldown = false })`
---
--- This is slightly less ergonomic to use, but it prevents oopsies when we
--- forget to fill out `:canUse()`.
---
---@param target WorldActor?
---@param checks? PoE2Lib.Combat.SkillHandler.BaseCanUseChecks
---@return boolean ok, string? reason
function SkillHandler:baseCanUse(target, checks)
    if checks == nil then
        checks = {}
    end

    local skill = self:getSkillObject()
    if skill == nil then
        return false, "cannot find skill by ID"
    end

    if checks.enabled ~= false then
        if not self.config.enabled then
            return false, "skill is disabled"
        end
    end

    if checks.sharedAnimationExpiration ~= false then
        if SharedState.LastSkillExpiration > Infinity.Win32.GetTickCount() and (SharedState.LastSkillExpirationHandler ~= nil and SharedState.LastSkillExpirationHandler:isCurrentAction()) then
            return false, "shared animation expiration"
        end
    end

    local name = self:getDisplayedName()
    if checks.displayedName ~= false then
        if name ~= self.config.skillName then
            return false, "current skill name does not match config skill name"
        end
    end

    if checks.canBeUsedwithWeapon ~= false then
        if not self:getSkillObject():canBeUsedWithWeapon() then
            return false, "skill cannot be used with current weapons"
        end
    end

    if checks.cost ~= false then
        local costOk, costReason = self:checkCost()
        if not costOk then
            return false, costReason
        end
    end

    if checks.charges ~= false then
        if skill:getMaxCharges() > 0 and skill:getCharges() <= 0 then
            return false, "not enough charges"
        end
    end

    if checks.conditions ~= false then
        local conditionsOk, conditionsReason = self:checkConditions(target)
        if not conditionsOk then
            return false, ("condition failed (%s)"):format(conditionsReason)
        end
    end

    if checks.targetableCorpse ~= false then
        if self:getCastMethod() == CastMethods.Methods.StartActionCorpse then
            if self:getTargetableCorpse(target, nil) == nil then
                return false, "no targetable corpses"
            end
        end
    end

    if checks.isTriggered ~= false then
        if self:hasStat(SkillStats.IsTriggered) then
            return false, "skill is triggered"
        end
    end

    if checks.enforcedWalking ~= false then
        if SharedState.CurrentActionSkillId:getValue() == 0x40000000 and self:getPlayerStat(SkillStats.EnforcedWalkingSpeed) ~= 0 then
            return false, "enforced walking"
        end
    end

    if checks.canUseWhileMounted ~= false then
        if SharedState.IsMounted:getValue() and not self:hasStat(SkillStats.CanPerformSkillWhileMounted) then
            return false, "skill cannot be used while mounted"
        end
    end

    if checks.isInTown ~= false then
        if self:getPlayerStat(SkillStats.IsInTown) >= 1 then
            return false, "in town"
        end
    end

    if checks.comboCount ~= false then
        local requiredComboStack = self:getStat(SkillStats.RequiredComboStack)
        if requiredComboStack > 0 then
            if self:getComboCount() < requiredComboStack then
                return false, "not enough combo count"
            end
        end
    end

    return true, nil
end

--------------------------------------------------------------------------------
-- Travel
--------------------------------------------------------------------------------

---@return boolean
function SkillHandler:needsPathfinding()
    return false
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
---@return boolean success
function SkillHandler:travel(destination, locations, costs)
    return false
end

--------------------------------------------------------------------------------
-- Cooldown management
--
-- Cooldowns can be a little more complex, so here is a separate section for it
--------------------------------------------------------------------------------

--- Contains the expiration tick for the cooldown.
---@type number
SkillHandler.cooldownExpiration = 0

--- Contains the expiration tick for the animation.
---@type number
SkillHandler.animationExpiration = 0

---@param tick? number The tick to check the cooldown at. Defaults to now.
---@return boolean
function SkillHandler:isOnCooldown(tick)
    return (tick or Infinity.Win32.GetTickCount()) < self.cooldownExpiration
end

---@param now integer Current tick
---@param duration? number If omitted, will be calculated from skill properties
function SkillHandler:startCooldown(now, duration)
    self.cooldownExpiration = now + (duration or self:calculateCooldown())
end

---@param now integer
function SkillHandler:startAnimation(now)
    local animation = self:calculateAnimationDuration()
    if now + animation > SharedState.LastSkillExpiration then
        SharedState.LastSkillExpiration = now + animation
        SharedState.LastSkillExpirationHandler = self
    end
    self.animationExpiration = now + animation
end

function SkillHandler:calculateCooldown()
    local skill = self:getSkillObject()
    if skill == nil then
        return 0
    end

    local animation = self:calculateAnimationDuration()
    if animation > 0 then
        return animation
    end

    return 0
end

--- Calculate the expected duration of the animation from the attack/cast rate.
---@return number
function SkillHandler:calculateAnimationDuration()
    local duration = math.max(self:getStat(SkillStats.AttackDuration), self:getStat(SkillStats.CastDuration))
    if duration > 0 then
        return duration
    end

    return 0
end

--- Checks whether the skill is currently in animation and therefore not
--- cancellable based on the duration of the animation and the configured
--- 'bite point'.
---@param tick? number The tick count, defaults to the current tick
---@return boolean
function SkillHandler:isInAnimation(tick)
    return self.animationExpiration >= (tick or Infinity.Win32.GetTickCount())
end

--------------------------------------------------------------------------------
-- Usage methods
--
-- These are methods to use skills. Various skills tend to use different packets
-- to cast them.
--------------------------------------------------------------------------------

--- Get the cast method for the current skill.
---@return PoE2Lib.Combat.SkillHandler.CastMethod?
function SkillHandler:getCastMethod()
    local asid = self:getActiveSkillId()
    if asid and CastMethods.ByActiveSkillId[asid] then
        return CastMethods.ByActiveSkillId[asid]
    end

    -- Direct Minions uses a different packet that's not currently implemented.
    if asid == "generic_minion_command" then
        return nil
    end

    if self:hasStat(SkillStats.IsPersistent) then
        return CastMethods.Methods.UseAuraAction
    end

    if self:hasStat(SkillStats.IsInstant) then
        return CastMethods.Methods.UseInstantSkill
    end

    if self:hasTargetType(EActiveSkillTargetType_Corpse) then
        return CastMethods.Methods.StartActionCorpse
    end

    return CastMethods.Methods.DoAction
end

--- Known action flags for the DoAction and Interact packets.
local ActionFlags = { --
    --- No flag
    None = 0x0000,
    Unknown0400 = 0x0400,
    --- Signals that the skill should be used without moving.
    AttackWithoutMoving = 0x0001,
}
SkillHandler.ActionFlags = ActionFlags

--- Get the action flag for the skill usage and will be used in the DoAction
--- packet. The flag is a bitwise combination of values. See
--- `SkillHandler.ActionFlags` for known flags.
---
---@return integer flag
function SkillHandler:getActionFlag()
    return ActionFlags.Unknown0400 + ActionFlags.AttackWithoutMoving
end

--- Get the secondary action flag for the skill usage and will be used in the
--- DoAction packet.
---
---@return integer flag
function SkillHandler:getActionFlag2()
    return 0x00
end

--- Get the tertiary action flag for the skill usage and will be used in the
--- DoAction packet.
---
---@return integer flag
function SkillHandler:getActionFlag3()
    return 0xFF
end

---@param target WorldActor?
---@param location? Vector3
---@return WorldActor? corpse
function SkillHandler:getTargetableCorpse(target, location)
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastTargetableCorpseFrame then
        self.lastTargetableCorpseActor = self:getTargetableCorpseUncached(target, location)
        self.lastTargetableCorpseFrame = now
    end

    return self.lastTargetableCorpseActor
end

---@param target WorldActor?
---@param location? Vector3
---@return WorldActor? corpse
function SkillHandler:getTargetableCorpseUncached(target, location)
    location = location or (target and target:getLocation()) or Infinity.PoE2.getLocalPlayer():getLocation()
    local player = Infinity.PoE2.getLocalPlayer()
    local playerRadius = self:getTargetableCorpsePlayerRange()
    local targetRadius = self:getTargetableCorpseTargetRadius()
    local _, canFly = self:getCurrentMaxSkillDistance()
    for _, corpse in pairs(Infinity.PoE2.getUseableCorpses()) do
        if  corpse:getDistanceToPlayer() <= playerRadius                 --
        and corpse:getLocation():getDistanceXY(location) <= targetRadius --
        and player:hasLineOfSightTo(corpse:getLocation(), canFly ~= false) then
            return corpse
        end
    end

    return nil
end

--- Get the range around the player in which to search for corpses to target.
--- This is to limit the corpses to a specific range around the player, such
--- that corpses that are too far away from the player, are not targeted.
---@return number
function SkillHandler:getTargetableCorpsePlayerRange()
    return 80
end

--- Get the radius around the target in which to search for corpses to target.
--- This is for skills that have an effect in a limited radius around the
--- corpse, such as the explosion of Detonate Dead.
---@return number
function SkillHandler:getTargetableCorpseTargetRadius()
    return math.huge
end

--- Overridable method to filter corpse targeting.
---@param actor WorldActor
---@return boolean
function SkillHandler:isTargetableCorpse(actor)
    return true
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
function SkillHandler:canUse(target)
    return false, nil
end

---@param target WorldActor?
---@param location? Vector3
---@return WorldActor? target, Vector3? location
function SkillHandler:overrideTarget(target, location)
    if self.config.targetTempestBell and SharedState.HasTempestBell:getValue() then
        for _, tempestBell in pairs(SharedState.TempestBells:getValue()) do
            local tLoc = location or (target and target:getLocation())
            if tLoc then
                local bellLoc = tempestBell:getLocation()
                -- The default radius is 1.8m
                local radius = (tempestBell:getObjectSize() + 18)
                local range, canFly = self:getCurrentMaxSkillDistance()
                if self:isInRange(bellLoc, range, true, canFly) and bellLoc:getDistanceXY(tLoc) <= radius then
                    -- Can't return the bell itself, because the game ignores skills that target the bell
                    return nil, bellLoc
                end
            end
        end
    end

    return target, location
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
function SkillHandler:use(target, location)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if lPlayer == nil then
        return
    end

    local castMethod = self:getCastMethod()
    if castMethod == nil then
        -- error(('No skill usage implemented for this skill: [%s] %s'):format(self.skillId, self:getDisplayedName()))
        return
    end

    if  self.config.doubleUsePreventionEnabled
    and self.lastExecuteTick < self.lastUseTick
    and (Infinity.Win32.GetTickCount() - self.lastUseTick) < self.config.doubleUsePreventionDuration
    then
        return
    end

    target, location = self:overrideTarget(target, location)

    castMethod(self, target, location)
    self:onUse()
end

function SkillHandler:updateActionLocation(target, location)
    local now = Infinity.Win32.GetTickCount()
    if now > self.lastUpdateActionLocation + UPDATE_ACTION_INTERVAL then
        CastMethods.Methods.UpdateAction(self, target, location)
        self.lastUpdateActionLocation = now
    end
end

function SkillHandler:stopAction()
    local now = Infinity.Win32.GetTickCount()
    if now > self.lastStopAction + UPDATE_ACTION_INTERVAL and self.lastExecuteTick > self.lastStopAction then
        CastMethods.StopMethod()
        self.lastStopAction = now
    end
end

function SkillHandler:stopAttacking()
    if self.thisActionInitiatedByThis and self:isCurrentAction() and self:isChannelingSkill() then
        self:stopAction()
    end
end

function SkillHandler:stopTravel()
end

function SkillHandler:onUse()
    local now = Infinity.Win32.GetTickCount()
    self.lastUseTick = now
    self.nextActionInitiatedByThis = true
end

---@param target WorldActor?
function SkillHandler:updateTarget(target)
    if self.thisActionInitiatedByThis and self:isCurrentAction() and self:isChannelingSkill() then
        if target then
            self:updateActionLocation(target, nil)
        else
            self:stopAction()
        end
    end
end

--- This is used to signal that movement should be prevented. E.g. for
--- channelling skills to avoid interrupting it.
---@param target WorldActor?
---@return boolean shouldPrevent
function SkillHandler:shouldPreventMovement(target)
    return self.thisActionInitiatedByThis and self:isCurrentAction() and self:isChannelingSkill()
end

--- Try to move to a destination. This is used for skills to provide their own
--- movement instead of the default movement.
---@param destination Vector3
---@return boolean success
function SkillHandler:tryMove(destination)
    return false
end

--- Will draw the settings for the handler. A key can be provided to provide
--- uniqueness to the ImGui labels. The implementing handler should always use
--- this key.
---@param key string|''
function SkillHandler:drawSettings(key)
end

return SkillHandler
