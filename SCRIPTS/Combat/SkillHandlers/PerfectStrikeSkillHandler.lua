local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.PerfectStrikeSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.PerfectStrikeSkillHandler
local PerfectStrikeSkillHandler = SkillHandler:extend()

PerfectStrikeSkillHandler.shortName = "Perfect Strike"

PerfectStrikeSkillHandler.description = [[
    This is a skill handler for Perfect Strike.
]]

PerfectStrikeSkillHandler.settings = { --
    range = 30,
    perfectAnimationOffset = 0.75,
}

PerfectStrikeSkillHandler.handleNextExecute = false
PerfectStrikeSkillHandler.handleThisExecute = false

PerfectStrikeSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "perfect_strike"
end)

function PerfectStrikeSkillHandler:onUse()
    self.handleNextExecute = true
    self:super():onUse()
end

function PerfectStrikeSkillHandler:onSkillExecute()
    self.handleThisExecute = self.handleNextExecute
    self.handleNextExecute = false
    self:super():onSkillExecute()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function PerfectStrikeSkillHandler:canUse(target)
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
function PerfectStrikeSkillHandler:use(target, location)
    if not self:isCurrentAction() then
        self:super():use(target, location)
    end
end

---@return boolean
function PerfectStrikeSkillHandler:isChannelingSkill()
    return true
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function PerfectStrikeSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, false
end

---@param target WorldActor?
function PerfectStrikeSkillHandler:updateTarget(target)
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
function PerfectStrikeSkillHandler:shouldPreventMovement(target)
    return self:isCurrentAction() or (Infinity.Win32.GetTickCount() - self.lastUseTick) < 100
end

---@param key string
function PerfectStrikeSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##perfect_strike_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.perfectAnimationOffset = ImGui.InputFloat(label("Perfect Animation Offset", "perfectAnimationOffset"), self.settings.perfectAnimationOffset)
    ImGui.PopItemWidth()
end

return PerfectStrikeSkillHandler
