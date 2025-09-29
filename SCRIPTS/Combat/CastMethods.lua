local Vector = require("CoreLib.Vector")

---@class PoE2Lib.Combat.CastMethods
local CastMethods = {}

---@alias PoE2Lib.Combat.SkillHandler.CastMethod fun(handler: PoE2Lib.Combat.SkillHandler, target?: WorldActor, location?: Vector3)

CastMethods.Methods = {}

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.StartAction(handler, target, location)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if location == nil then
        location = (target or lPlayer):getLocation()
    end

    -- If the target is too far away, then use a location that is closer to the
    -- player. The game ignores actions that are farther than 120 units away.
    -- This is also a safety measure.
    local pLoc = lPlayer:getLocation()
    if pLoc:getDistanceXY(location) > 120 then
        location = Vector.round(Vector.resizeXY(pLoc, location, 115)) --[[@as Vector3]]
        target = nil
    end

    -- print("Starting Action: " .. handler.config.skillName)

    -- TODO: Enable third flag
    -- lPlayer:startAction(handler.skillId, (target and target:getActorId() or 0), location, handler:getActionFlag(), handler:getActionFlag2(), handler:getActionFlag3())
    lPlayer:startAction(handler.skillId, (target and target:getActorId() or 0), location, handler:getActionFlag(), handler:getActionFlag2())

    -- local rel = Vector.round(Vector.sub(location, Infinity.PoE2.getLocalPlayer():getLocation()))
    -- local packet = ByteBuffer(1)
    -- packet:putRShort(367)
    -- packet:put(1)
    -- packet:putRInt(handler.skillId)
    -- packet:putRShort(handler:getActionFlag())
    -- packet:put(0x00)
    -- packet:putRInt(rel.X)
    -- packet:putRInt(rel.Y)
    -- Infinity.Net.Send(packet)
end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.DoAction(handler, target, location)
    CastMethods.Methods.StartAction(handler, target, location)
    if not handler:isChannelingSkill() then
        CastMethods.StopMethod()
    end
end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.UpdateAction(handler, target, location)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    if location == nil then
        location = (target or lPlayer):getLocation()
    end

    -- If the target is too far away, then use a location that is closer to the
    -- player. The game ignores actions that are farther than 120 units away.
    -- This is also a safety measure.
    local pLoc = lPlayer:getLocation()
    if pLoc:getDistanceXY(location) > 120 then
        location = Vector.round(Vector.resizeXY(pLoc, location, 115)) --[[@as Vector3]]
    end

    lPlayer:updateAction(handler.skillId, location)
end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.StopAction(handler, target, location)
    Infinity.PoE2.getLocalPlayer():stopAction()
end

-- ---@param handler PoE2Lib.Combat.SkillHandler
-- ---@param target WorldActor?
-- ---@param location? Vector3
-- function CastMethods.Methods.StopCharging(handler, target, location)
--     local packet = ByteBuffer(1)
--     packet:putRShort(375)
--     packet:put(1)
--     packet:putRInt(handler.skillId)
--     packet:put(0)
--     Infinity.Net.Send(packet)
-- end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.UseInstantSkill(handler, target, location)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    -- lPlayer:useInstantAction(handler.skillId, (target and target:getActorId() or 0))
    -- Always use the local player as the target until we find situations where
    -- this is not the case.
    lPlayer:useInstantAction(handler.skillId, lPlayer:getActorId())
end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.UseAuraAction(handler, target, location)
    -- TODO: Check state param
    -- local lPlayer = Infinity.PoE2.getLocalPlayer()
    -- lPlayer:useAuraAction(handler.skillId, true)
end

---@param handler PoE2Lib.Combat.SkillHandler
---@param target WorldActor?
---@param location? Vector3
function CastMethods.Methods.StartActionCorpse(handler, target, location)
    local corpse = handler:getTargetableCorpse(target, location)
    if corpse ~= nil then
        CastMethods.Methods.DoAction(handler, corpse, corpse:getLocation())
    end
end

--- This method is used to stop the current action after starting it. By default
--- it just calls `WorldActor:stopAction()`. The game will continue the action
--- once started otherwise.
---@type fun()
CastMethods.StopMethod = function()
    Infinity.PoE2.getLocalPlayer():stopAction()
end

--- Overrides the method that is used to stop actions.
---@param stopMethod fun()
function CastMethods.SetStopMethod(stopMethod)
    CastMethods.StopMethod = stopMethod
end

--- Lookup table to get the name of a CastMethod
---@type table<PoE2Lib.Combat.SkillHandler.CastMethod, string>
CastMethods.NameByMethodMap = {}
for k, v in pairs(CastMethods.Methods) do
    CastMethods.NameByMethodMap[v] = k
end

CastMethods.ByActiveSkillId = { --
}

return CastMethods
