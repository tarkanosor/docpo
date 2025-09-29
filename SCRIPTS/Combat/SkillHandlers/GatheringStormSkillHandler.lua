local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.GatheringStormSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.GatheringStormSkillHandler
local GatheringStormSkillHandler = SkillHandler:extend()

GatheringStormSkillHandler.shortName = "Gathering Sorm"

GatheringStormSkillHandler.description = [[
    This is a skill handler for Gathering Storm.
]]

GatheringStormSkillHandler.settings = { --
    range = 30,
    perfectAnimationOffset = 0.55,
}

GatheringStormSkillHandler.handleNextExecute = false
GatheringStormSkillHandler.handleThisExecute = false

GatheringStormSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "gathering_storm"
end)

function GatheringStormSkillHandler:onUse()
    self.handleNextExecute = true
    self:super():onUse()
end

function GatheringStormSkillHandler:onSkillExecute()
    self.handleThisExecute = self.handleNextExecute
    self.handleNextExecute = false
    self:super():onSkillExecute()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function GatheringStormSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, false) then
        return false, "target out of range"
    end

    return true, nil
end

---@param target WorldActor?
---@param location? Vector3
function GatheringStormSkillHandler:use(target, location)
    if not self:isCurrentAction() then
        self:super():use(target, location)
    end
end

---@return boolean
function GatheringStormSkillHandler:isChannelingSkill()
    return true
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function GatheringStormSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, false
end

---@param target WorldActor?
function GatheringStormSkillHandler:updateTarget(target)
    if not self.handleThisExecute or not self:isCurrentAction() then
        return
    end

    if target == nil then
        CastMethods.Methods.StopAction(self, target, nil)
        self.handleThisExecute = false
        return
    end

    local perfectTiming = self:getStat(SkillStats.AttackDuration) * self.settings.perfectAnimationOffset
    local channelDuration = (1000 * SkillHandler.SharedState.CurrentAction:getValue():getChannelDuration())
    if channelDuration > perfectTiming then
        CastMethods.Methods.StopAction(self, target, nil)
        self.handleThisExecute = false
        return
    end

    self:updateActionLocation(target, nil)
end

---@param target WorldActor?
function GatheringStormSkillHandler:shouldPreventMovement(target)
    return self:isCurrentAction() or (Infinity.Win32.GetTickCount() - self.lastUseTick) < 100
end

---@param key string
function GatheringStormSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##gathering_storm_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.perfectAnimationOffset = ImGui.InputFloat(label("Perfect Animation Offset", "perfectAnimationOffset"), self.settings.perfectAnimationOffset)
    ImGui.PopItemWidth()
end

return GatheringStormSkillHandler
