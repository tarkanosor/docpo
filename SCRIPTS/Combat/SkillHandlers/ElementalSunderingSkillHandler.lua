local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local RakeSkillHandler = require("PoE2Lib.Combat.SkillHandlers.RakeSkillHandler")

local NORMAL_COMBO = (3 - 1)

---@class PoE2Lib.Combat.SkillHandlers.ElementalSunderingSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.ElementalSunderingSkillHandler
local ElementalSunderingSkillHandler = SkillHandler:extend()

ElementalSunderingSkillHandler.shortName = "Elemental Sundering"

ElementalSunderingSkillHandler.description = [[
    This is a handler for the Elemental Sundering skill.
]]

ElementalSunderingSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "extract_elements"
end)

ElementalSunderingSkillHandler.settings = { --
    radius = 50,
    radiusAuto = true,
    explosionRadius = 16,
    explosionRadiusAuto = true,
    minAilments = 5,
}

function ElementalSunderingSkillHandler:onPulse()
    if self.settings.radiusAuto then
        self.radius = self:getStat(SkillStats.ActiveSkillAoERadius)
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function ElementalSunderingSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self.settings.minAilments > self:getAilmentCount() then
        return false, "not enough ailments"
    end

    return true, nil
end

function ElementalSunderingSkillHandler:getAilmentCount()
    local totalCount = 0
    for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_Monster)) do
        if actor:getDistanceToPlayer() <= self.settings.radius then
            local count = 0
            if actor:hasBuff("shocked") then
                count = count + 1
            end
            if actor:hasBuff("burning") then
                count = count + 1
            end
            if actor:hasBuff("frozen") then
                count = count + 1
            end

            if count > 0 and actor:getCloseAttackableEnemyCount(self.settings.explosionRadius, false, false) > 0 then
                totalCount = totalCount + count
            end
        end
    end
    return totalCount
end

---@param key string
function ElementalSunderingSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##elemental_sundering_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        UI.WithDisable(self.settings.radiusAuto, function()
            _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
        end)
        ImGui.SameLine()
        _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto", "radius_auto"), self.settings.radiusAuto)

        _, self.settings.explosionRadius = ImGui.InputInt(label("Explosion Radius", "explosion_radius"), self.settings.explosionRadius)

        _, self.settings.minAilments = ImGui.InputInt(label("Min Ailments", "min_ailments"), self.settings.minAilments, 1, 1000)
    end)
end

return ElementalSunderingSkillHandler
