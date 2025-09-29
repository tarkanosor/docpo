local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

local CULL_THRESHOLDS = { --
    [ERarity_White] = 30,
    [ERarity_Magic] = 20,
    [ERarity_Rare] = 10,
    [ERarity_Unique] = 5,
}

---@class PoE2Lib.Combat.SkillHandlers.KillingPalmSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.KillingPalmSkillHandler
local KillingPalmSkillHandler = SkillHandler:extend()

KillingPalmSkillHandler.shortName = "Killing Palm"

KillingPalmSkillHandler.description = [[
    This is special skill handler for the Killing Palm skill.
]]

KillingPalmSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "killing_palm"
end)

KillingPalmSkillHandler.settings = { --
    range = 65,
    canFly = false,
    castOnTarget = true,
    onlyCull = true,
    improvedTargeting = true,
}

---@type WorldActor?
KillingPalmSkillHandler.cachedTarget = nil
KillingPalmSkillHandler.cachedTargetTick = 0

---@param target WorldActor?
---@return boolean ok, string? reason
function KillingPalmSkillHandler:canUse(target)
    if self.settings.improvedTargeting then
        target = self:getImprovedTarget(target)
    end

    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return false, "target out of range"
    end

    if self.settings.onlyCull and not self:isCullable(target) then
        return false, "target not cullable"
    end

    return true, nil
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function KillingPalmSkillHandler:getCurrentMaxSkillDistance()
    if self.settings.range == nil then
        return 0, true
    end

    return self.settings.range, self.settings.canFly
end

---@param target WorldActor?
function KillingPalmSkillHandler:getImprovedTarget(target)
    if target ~= nil and self:isCullable(target) and self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return target
    end

    local now = Infinity.Win32.GetTickCount()
    if now ~= self.cachedTargetTick then
        local bestTarget, bestDistance, bestCullable = nil, math.huge, false
        for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            if self:isInRange(mob, self.settings.range, true, self.settings.canFly) and mob:getHp() > 1 then
                local distance = mob:getDistanceToPlayer()
                local cullable = self:isCullable(mob)
                if (cullable and not self.settings.onlyCull) and ((cullable and not bestCullable) or distance < bestDistance) then
                    bestTarget, bestDistance, bestCullable = mob, distance, cullable
                end
            end
        end
        self.cachedTarget = bestTarget
        self.cachedTargetTick = now
    end
    return self.cachedTarget
end

---@param target WorldActor
function KillingPalmSkillHandler:isCullable(target)
    local threshold = CULL_THRESHOLDS[target:getRarity()] or 0
    return threshold >= target:getHpPercentage()
end

---@param target WorldActor?
---@param location? Vector3
function KillingPalmSkillHandler:use(target, location)
    if self.settings.improvedTargeting then
        target = self:getImprovedTarget(target)
    end
    self:super():use(target, location)
end

---@param target WorldActor?
function KillingPalmSkillHandler:shouldPreventMovement(target)
    if self:super():shouldPreventMovement(target) then
        return target ~= nil and self:isInRange(target, self.settings.range, true, self.settings.canFly)
    end

    return false
end

---@param key string
function KillingPalmSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##killing_palm_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    _, self.settings.onlyCull = ImGui.Checkbox(label("Only Cull", "onlyCull"), self.settings.onlyCull)
    _, self.settings.improvedTargeting = ImGui.Checkbox(label("Improved Targeting", "improvedTargeting"), self.settings.improvedTargeting)
    ImGui.PopItemWidth()
end

return KillingPalmSkillHandler
