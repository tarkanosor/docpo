local Class = require("CoreLib.Class")
local InstanceActorList = require("PoE2Lib.InstanceActorList")

---@class PoE2Lib.Combat.Evade.CustomPatterns : Class
local CustomEvadePatterns = Class()

---@alias PoE2Lib.Combat.CustomEvadePatterns.AddPolygon fun(isHighDanger: boolean, id: integer, duration: integer, points: Vector3[])
---@alias PoE2Lib.Combat.CustomEvadePatterns.ActorCallback fun(actor: WorldActor, addPolygon: PoE2Lib.Combat.CustomEvadePatterns.AddPolygon)

---@type table<string, PoE2Lib.Combat.CustomEvadePatterns.ActorCallback>
CustomEvadePatterns.aoMapping = {}

---@param aoPath string
---@param callback PoE2Lib.Combat.CustomEvadePatterns.ActorCallback
function CustomEvadePatterns:add(aoPath, callback)
    if self.aoMapping[aoPath] ~= nil then
        error("CustomEvadePatterns.Add: AO path already registered: " .. aoPath)
    end
    self.aoMapping[aoPath] = callback
end

--------------------------------------------------------------------------------
-- Processing
--------------------------------------------------------------------------------

---@private
---@type PoE2Lib.InstanceActorListTyped<PoE2Lib.Combat.CustomEvadePatterns.ActorCallback>
CustomEvadePatterns.actors = nil

---@param addPolygon PoE2Lib.Combat.CustomEvadePatterns.AddPolygon
function CustomEvadePatterns:process(addPolygon)
    if self.actors == nil then
        self.actors = InstanceActorList(nil, function(actor)
            if not actor:isHostile() then
                return nil
            end
            return self.aoMapping[actor:getAnimatedMetaPath()]
        end)
    end
    for actor, callback in self.actors:iter(false) do
        callback(actor, addPolygon)
    end
end

return CustomEvadePatterns
