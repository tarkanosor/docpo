local Navigator = Infinity.PoE2.getNavigator()
local Vector = require("CoreLib.Vector")
local Render = require("CoreLib.Render")
local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

local COLLISION_RADIUS = 4

--- The maximum distance between a possible travel location and a waypoint to
--- raycast between. The farther the distance, the more likely it is that there
--- will be an obstruction between the two points. This value reduces the number
--- of necessary raycasts.
local RAYCAST_DISTANCE_LIMIT = 100

local TARGET_IGNORE_TIME = 3000

--- This is sort of a special handler for travel skills. It doesn't implement
--- `:use()` like normal, but defines a `:travel()` method to use it to travel
--- to a location instead.
---
--- This is intentionally different from the normal API implementation, so this
--- skill handler can be included (perhaps accidentally by the user) without it
--- interfering in normal CombatManager usage, since it isn't actionable when
--- using the normal API.
---
---@class PoE2Lib.Combat.SkillHandlers.PalmTravelSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.PalmTravelSkillHandler
local PalmTravelSkillHandler = SkillHandler:extend()

PalmTravelSkillHandler.shortName = "Palm Travel"

PalmTravelSkillHandler.description = [[
    This skill handler is for palm skills and will only use the skill at mobs
    to travel.
]]

PalmTravelSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return false
end)

---@class PoE2Lib.Combat.SkillHandlers.PalmTravelSkillHandler.Settings
PalmTravelSkillHandler.settings = { --
    minRange = 30,
    maxRange = 65,
    ---@type boolean
    canFly = false,
}

---@type integer?
PalmTravelSkillHandler.lastActorId = nil

---@type table<integer, integer>
PalmTravelSkillHandler.lastTargetTimes = {}

---@param target? Actor
---@return boolean ok, string? reason
function PalmTravelSkillHandler:canUse(target)
    return false, "PalmTravelSkillHandler does not use the :canUse() method"
end

--- Overridden so the default implementation cannot be used.
---@param target? Actor
---@param location? Vector3
function PalmTravelSkillHandler:use(target, location)
end

--- Returns the travel skills currently travelable range.
---@return number travelableDistance Maximum traveable distance
---@return boolean canBeShorter Whether travel distance may be shorter than the max range
function PalmTravelSkillHandler:getCurrentPossibleTravelRange()
    return self.settings.maxRange, true
end

---@param locations Vector3[]
---@param costs number[]
---@return WorldActor? mob, Vector3? location, number cost
function PalmTravelSkillHandler:getBestLocationAlongPath(locations, costs)
    local now = Infinity.Win32.GetTickCount()
    local origin = Infinity.PoE2.getLocalPlayer():getLocation()
    local best, bestLoc, cost = nil, nil, (costs[1] or math.huge) + origin:getDistanceXY(locations[1] or origin)
    for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
        if (now - (self.lastTargetTimes[mob:getActorId()] or 0) > TARGET_IGNORE_TIME) then
            local mobLoc = mob:getLocation()
            local distance = origin:getDistanceXY(mobLoc)
            if distance >= self.settings.minRange and distance <= self.settings.maxRange and Navigator:getApproximateDistanceToCellFromPlayer(mob:getLocation(), self.settings.maxRange) <= self.settings.maxRange and not self:isObstructed(origin, mobLoc) then
                -- local arrivalLoc = Vector.as3(Vector.round(Vector.sub(mobLoc, Vector.mult(Vector.rVec(origin, mobLoc), mob:getObjectSize() + COLLISION_RADIUS))))
                -- if not CombatUtils.ConservativeRaycast(arrivalLoc, mobLoc, false, COLLISION_RADIUS) then
                local c = self:checkDirection(origin, mobLoc, locations, costs)
                if c < cost then
                    best, bestLoc, cost = mob, mobLoc, c
                end
                -- end
            end
        end
    end

    return best, bestLoc, cost
end

---@return boolean
function PalmTravelSkillHandler:needsPathfinding()
    return true
end

---@param origin Vector3
---@param direction Vector3
---@param locations Vector3[]
---@param costs number[]
---@return number cost
function PalmTravelSkillHandler:checkDirection(origin, direction, locations, costs)
    local cost = math.huge
    for i = 1, #locations do
        local start, finish = locations[i - 1] or origin, locations[i]
        local dist, optimal = Vector.GetPointSegmentDistance(direction, start, finish)
        if dist < RAYCAST_DISTANCE_LIMIT then
            local c = costs[i] + dist + optimal:getDistanceXY(finish)
            if c < cost and not CombatUtils.Raycast(optimal, direction, false) then
                cost = c
            end
        end
    end

    return cost
end

---@param destination Vector3
---@return boolean obstructed
function PalmTravelSkillHandler:isObstructed(origin, destination)
    -- Check collision with terrain
    -- if CombatUtils.ConservativeRaycast(origin, destination, self.settings.canFly, COLLISION_RADIUS) then
    if CombatUtils.Raycast(origin, destination, self.settings.canFly) then
        return true
    end

    if not self.settings.canFly then
        -- Check for collidable actors
        for _, actor in pairs(Infinity.PoE2.getActors()) do
            if self:isObstruction(actor, origin, destination, COLLISION_RADIUS) then
                return true
            end
        end
    end

    return false
end

---@param actor WorldActor
---@param from Vector3
---@param to Vector3
---@param radius number
---@return boolean
function PalmTravelSkillHandler:isObstruction(actor, from, to, radius)
    -- Ignore monsters because travel skills pass through them
    if actor:hasActorType(EActorType_Monster) or actor:hasActorType(EActorType_Player) then
        return false
    end

    if not actor:isCollidable() then
        return false
    end

    local size = actor:getObjectSize()
    local p = actor:getLocation()
    local dist, _ = Vector.DistanceToSegment(p, from, to)
    return dist <= (size + radius)
end

function PalmTravelSkillHandler:onSkillExecute()
    local now = Infinity.Win32.GetTickCount()
    if self.lastActorId ~= nil then
        self.lastTargetTimes[self.lastActorId] = now
    end

    for actorId, time in pairs(self.lastTargetTimes) do
        if now - time > TARGET_IGNORE_TIME then
            self.lastTargetTimes[actorId] = nil
        end
    end

    self:super():onSkillExecute()
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
---@return boolean
function PalmTravelSkillHandler:travel(destination, locations, costs)
    if not self:baseCanUse(nil) then
        return false
    end

    if self:isCurrentAction() then
        return false
    end

    local best, bestLoc, cost = self:getBestLocationAlongPath(locations, costs)
    if best == nil then
        return false
    end

    self.lastActorId = best:getActorId()
    self:super():use(best, nil)
    return true
end

---@param key string
function PalmTravelSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##travel_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.minRange = ImGui.InputInt(label("Min Range", "min_range") .. key, self.settings.minRange)
    _, self.settings.maxRange = ImGui.InputInt(label("Max Range", "max_range") .. key, self.settings.maxRange)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly") .. key, self.settings.canFly)

    ImGui.PopItemWidth()
end

return PalmTravelSkillHandler
