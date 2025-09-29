local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.SnipeSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.SnipeSkillHandler
local SnipeSkillHandler = SkillHandler:extend()

SnipeSkillHandler.shortName = "Snipe"

SnipeSkillHandler.description = [[
    This is a skill handler for Snipe.
]]

SnipeSkillHandler.settings = { --
    range = 80,
    perfectAnimationOffset = 1.05,
}

SnipeSkillHandler.handleNextExecute = false
SnipeSkillHandler.handleThisExecute = false

SnipeSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "channelled_snipe"
end)

function SnipeSkillHandler:onUse()
    self.handleNextExecute = true
    self:super():onUse()
end

function SnipeSkillHandler:onSkillExecute()
    self.handleThisExecute = self.handleNextExecute
    self.handleNextExecute = false
    self:super():onSkillExecute()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function SnipeSkillHandler:canUse(target)
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

    return true, nil
end

---@param target WorldActor?
---@param location? Vector3
function SnipeSkillHandler:use(target, location)
    if not self:isCurrentAction() then
        self:super():use(target, location)
    end
end

---@return boolean
function SnipeSkillHandler:isChannelingSkill()
    return true
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function SnipeSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@param target WorldActor?
function SnipeSkillHandler:updateTarget(target)
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
function SnipeSkillHandler:shouldPreventMovement(target)
    return self:isCurrentAction() or (Infinity.Win32.GetTickCount() - self.lastUseTick) < 100
end

---@param key string
function SnipeSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##snipe_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.perfectAnimationOffset = ImGui.InputFloat(label("Perfect Animation Offset", "perfectAnimationOffset"), self.settings.perfectAnimationOffset)
    ImGui.PopItemWidth()
end

return SnipeSkillHandler
