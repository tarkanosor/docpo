local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

local STORM_LANCE_METAPATH = "Metadata/Effects/Spells/spear_overchargedspear/ground_spear"
local STORM_LANCE_PROJECTILE = "Metadata/Projectiles/OverchargedSpear"
local BEAM_EFFECT = "Metadata/Effects/BeamEffect"
local BEAM_AO = "Metadata/Effects/Spells/spear_overchargedspear/arc_beam.ao"

---@class PoE2Lib.Combat.SkillHandlers.StormLanceSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.StormLanceSkillHandler
local StormLanceSkillHandler = SkillHandler:extend()

StormLanceSkillHandler.shortName = "Storm Lance"

StormLanceSkillHandler.description = [[
    This is a handler for the Storm Lance skill.
]]

StormLanceSkillHandler.settings = { --
    range = 80,
    radius = 30,
    radiusAuto = true,
    useLimit = true,
    limit = 3,
    limitAuto = true,
    ignoreLimitWithFrenzyCharges = false,
    requireFrenzyCharges = true,
}

StormLanceSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "overcharged_spear"
end)

function StormLanceSkillHandler:setup()
    -- Replace old setting value with new settings that match the old behaviour
    if self.settings.spam then
        self.settings.useLimit = false
        self.settings.requireFrenzyCharges = false
    end
    self.settings.spam = nil
end

function StormLanceSkillHandler:onPulse()
    if self.settings.radiusAuto then
        -- The secondary one is the Frenzy Charged
        self.settings.radius = self:getStat(SkillStats.ActiveSkillSecondaryAoERadius)
    end
    if self.settings.limitAuto then
        self.settings.limit = self:getStat(SkillStats.NumberOfOverchargedSpearsAllowed)
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function StormLanceSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, true) then
        return false, "target out of range"
    end

    if self.settings.useLimit then
        if self:getExistingCount() >= self.settings.limit then
            if not self.settings.ignoreLimitWithFrenzyCharges or self:getFrenzyCharges() == 0 then
                return false, "too many existing spears"
            end
        end
    end

    if self.settings.requireFrenzyCharges and self:getFrenzyCharges() == 0 then
        return false, "no frenzy charges"
    end

    return true, nil
end

function StormLanceSkillHandler:getExistingCount()
    local count = 0
    for _, spear in pairs(Infinity.PoE2.getActorsByMetaPath(STORM_LANCE_METAPATH)) do
        if spear:isCurrentlyLiveObject() and spear:getCloseAttackableEnemyCount(self.settings.radius, false, false) > 0 and self:hasBeam(spear) then
            count = count + 1
        end
    end
    for _, projectile in pairs(Infinity.PoE2.getActorsByMetaPath(STORM_LANCE_PROJECTILE)) do
        if projectile:isCurrentlyLiveObject() then
            count = count + 1
        end
    end
    return count
end

---@param spear WorldActor
function StormLanceSkillHandler:hasBeam(spear)
    local loc = spear:getLocation()
    for _, beam in pairs(Infinity.PoE2.getActorsByMetaPath(BEAM_EFFECT)) do
        if beam:getAnimatedMetaPath() == BEAM_AO and beam:getLocation():getDistanceXY(loc) <= 10 then
            return true
        end
    end
    return false
end

---@return integer
function StormLanceSkillHandler:getFrenzyCharges()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "frenzy_charge" then
            return buff:getCharges()
        end
    end
    return 0
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function StormLanceSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, not not self.settings.canFly
end

---@param key string
function StormLanceSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##storm_lance_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

        UI.WithDisable(self.settings.radiusAuto, function()
            _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
        end)
        ImGui.SameLine()
        _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto Radius", "radiusAuto"), self.settings.radiusAuto)

        _, self.settings.useLimit = ImGui.Checkbox(label("Limit:", "useLimit"), self.settings.useLimit)
        UI.Tooltip("Limits the number of spears that can be active at once.")
        UI.WithDisable(not self.settings.useLimit, function()
            ImGui.SameLine()
            _, self.settings.limit = ImGui.InputInt(label("", "limit"), self.settings.limit)
            UI.Tooltip("The maximum number of spears that can be active at once.")

            UI.WithIndent(function()
                _, self.settings.ignoreLimitWithFrenzyCharges = ImGui.Checkbox(label("Ignore Limit with Frenzy Charges", "ignoreLimitWithFrenzyCharges"), self.settings.ignoreLimitWithFrenzyCharges)
                UI.Tooltip("If enabled, the limit will be ignored if you have Frenzy Charges.")
            end)
        end)

        _, self.settings.requireFrenzyCharges = ImGui.Checkbox(label("Require Frenzy Charges", "requireFrenzyCharges"), self.settings.requireFrenzyCharges)
        UI.Tooltip("If enabled, the skill will not be used if you don't have Frenzy Charges.")
    end)
end

return StormLanceSkillHandler
