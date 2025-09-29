local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.UnboundAvatarSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.UnboundAvatarSkillHandler
local UnboundAvatarSkillHandler = SkillHandler:extend()

UnboundAvatarSkillHandler.shortName = "Unbound Avatar"

UnboundAvatarSkillHandler.description = [[
    This is a skill handler for Unbound Avatar.
]]

UnboundAvatarSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "ailment_bearer"
end)

---@param target WorldActor?
---@return boolean ok, string? reason
function UnboundAvatarSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self:getUnboundFury() < 100 then
        return false, "not enough unbound fury"
    end

    return true, nil
end

function UnboundAvatarSkillHandler:getUnboundFury()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "ailment_bearer_activation_buff" then
            return buff:getCharges()
        end
    end
    return 0
end

---@param target WorldActor?
---@param location? Vector3
function UnboundAvatarSkillHandler:use(target, location)
    return self:super():use(Infinity.PoE2.getLocalPlayer(), nil)
end

return UnboundAvatarSkillHandler
