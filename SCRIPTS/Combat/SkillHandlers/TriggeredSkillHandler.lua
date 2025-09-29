local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.TriggeredSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TriggeredSkillHandler
local TriggeredSkillHandler = SkillHandler:extend()

TriggeredSkillHandler.shortName = "Triggered"

TriggeredSkillHandler.description = [[
    Triggered skills cannot be used. This handler does nothing.
]]

---@param target WorldActor?
---@return boolean ok, string? reason
function TriggeredSkillHandler:canUse(target)
    return false, "triggered skills cannot be used"
end

--- Overridden so the default implementation cannot be used.
---@param target WorldActor?
---@param location? Vector3
function TriggeredSkillHandler:use(target, location)
end

return TriggeredSkillHandler
