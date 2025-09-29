local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.DebugSpamSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.DebugSpamSkillHandler
local DebugSpamSkillHandler = SkillHandler:extend()

DebugSpamSkillHandler.shortName = '[DEBUG] Spam'

DebugSpamSkillHandler.description = [[
    This is a handler for debugging and has no additional logic. It will try to
    spam the skill solely on the base SkillHandler conditions.
]]

DebugSpamSkillHandler:setCanHandle(function(skill, stats, name, _, _, _)
    return false
end)

---@param target WorldActor?
---@return boolean ok, string? reason
function DebugSpamSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    return true, nil
end

---@param target WorldActor?
---@param location? Vector3
function DebugSpamSkillHandler:use(target, location)
    local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    local tLoc = target and target:getLocation()
    if tLoc and tLoc:getDistanceXY(pLoc) < 80 then
        return self:super():use(target, tLoc)
    end

    if location and pLoc:getDistanceXY(location) < 80 then
        return self:super():use(nil, location)
    end

    return self:super():use(nil, pLoc)
end

return DebugSpamSkillHandler
