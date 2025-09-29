local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.FollowerBlinkSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.FollowerBlinkSkillHandler
local FollowerBlinkSkillHandler = SkillHandler:extend()

FollowerBlinkSkillHandler.shortName = "Follower Blink"

FollowerBlinkSkillHandler.description = [[
    This is a handler to for Follower to spam Blink on the leader. This should
    only be used if you're insane enough to use Blink Autobomber on a follower.
]]

FollowerBlinkSkillHandler.settings = { --
    range = 50,
    canFly = true,
    leaderName = "",
}

FollowerBlinkSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return false
end)

---@param target WorldActor?
---@return boolean ok, string? reason
function FollowerBlinkSkillHandler:canUse(target)
    local leader = self:getLeader()
    if leader == nil then
        return false, "leader not found"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(leader, self.settings.range, true, self.settings.canFly) then
        return false, "leader out of range"
    end

    return true, nil
end

function FollowerBlinkSkillHandler:use(target, location)
    local leader = self:getLeader()
    if leader == nil then
        return
    end

    local player = Infinity.PoE2.getLocalPlayer()
    player:setDodgeRollState(true)
    self:super():use(nil, leader:getLocation())
    player:setDodgeRollState(false)
end

---@return WorldActor? leader
function FollowerBlinkSkillHandler:getLeader()
    for _, player in pairs(Infinity.PoE2.getActorsByType(EActorType_Player)) do
        if player:getPlayerName() == self.settings.leaderName then
            return player
        end
    end
    return nil
end

---@param key string
function FollowerBlinkSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##follower_blink_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.leaderName = ImGui.InputText(label("Leader Name", "leaderName"), self.settings.leaderName)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    ImGui.PopItemWidth()
end

return FollowerBlinkSkillHandler
