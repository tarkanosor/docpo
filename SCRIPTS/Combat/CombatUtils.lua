local Vector = require("CoreLib.Vector")

---@class PoE2Lib.Combat.CombatUtils
local CombatUtils = {}

---@param skill SkillWrapper
---@return string?
function CombatUtils.GetSkillDisplayedName(skill)
    local gepl = skill:getGrantedEffectsPerLevel()
    local ge = gepl and gepl:getGrantedEffect()
    local as = ge and ge:getActiveSkill()
    local displayedName = as and as:getDisplayedName()
    if displayedName ~= nil and displayedName ~= "" then
        return displayedName
    end
    return as and as:getId()
end

---@param skill SkillWrapper
---@return string?
function CombatUtils.GetActiveSkillID(skill)
    local gepl = skill:getGrantedEffectsPerLevel()
    local ge = gepl and gepl:getGrantedEffect()
    local as = ge and ge:getActiveSkill()
    return as and as:getId()
end

---@param skill SkillWrapper?
---@return string
function CombatUtils.GetFullSkillTitle(skill)
    local id = skill and skill:getSkillIdentifier() or 0
    local name = skill and CombatUtils.GetSkillDisplayedName(skill) or "(Unknown)"
    return ("[%X] <%s> %s"):format(id, (bit.band(id, 1) == 0 and "I" or "II"), name)
end

---@return integer?
function CombatUtils.GetCurrentActionId()
    local action = Infinity.PoE2.getLocalPlayer():getCurrentAction()
    local skill = action and action:getSkill()
    local id = skill and skill:getSkillIdentifier()
    return id
end

---@param from Vector2|Vector3
---@param to Vector2|Vector3
---@param canFly boolean
---@param radius number
---@return boolean, Vector3?
function CombatUtils.CollidableRaycast(from, to, canFly, radius)
    local collision, location = CombatUtils.Raycast(from, to, canFly)
    if collision then
        return true, location
    end

    for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_Collidable)) do
        local size = actor:getObjectSize()
        local loc = actor:getLocation()
        local dist, optimal = Vector.GetPointSegmentDistance(loc, from, to)
        if dist <= (size + radius) then
            return true, optimal
        end
    end

    return false, nil
end

---@param from Vector2|Vector3
---@param to Vector2|Vector3
---@param canFly boolean
---@return boolean, Vector3?
function CombatUtils.Raycast(from, to, canFly)
    local layer = 1
    if not canFly then
        layer = 0
    end

    local collision, x, y = Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getWorldData():raycast(from.X, from.Y, to.X, to.Y, layer)
    return collision, (collision and Vector3(x, y, 0) or nil)
end

---@param from Vector2|Vector3
---@param to Vector2|Vector3
---@param canFly boolean
---@param objectSize number
---@return boolean, Vector3?
function CombatUtils.ConservativeRaycast(from, to, canFly, objectSize)
    local layer = 1
    if not canFly then
        layer = 0
    end

    local collision, x, y = Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getWorldData():conservativeRaycast(from.X, from.Y, to.X, to.Y, layer, objectSize)
    return collision, (collision and Vector3(x, y, 0) or nil)
end

return CombatUtils
