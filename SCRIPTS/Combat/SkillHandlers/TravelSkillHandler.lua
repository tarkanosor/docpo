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

--- This is sort of a special handler for travel skills. It doesn't implement
--- `:use()` like normal, but defines a `:travel()` method to use it to travel
--- to a location instead.
---
--- This is intentionally different from the normal API implementation, so this
--- skill handler can be included (perhaps accidentally by the user) without it
--- interfering in normal CombatManager usage, since it isn't actionable when
--- using the normal API.
---
---@class PoE2Lib.Combat.SkillHandlers.TravelSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TravelSkillHandler
local TravelSkillHandler = SkillHandler:extend()

TravelSkillHandler.shortName = "Travel"

TravelSkillHandler.description = [[
    Use this handler to set your travel skill.
]]

TravelSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    -- return stats:hasStat(SkillStats.IsTravelSkill)
    -- return asid == "blink"
    return false
end)

---@class PoE2Lib.Combat.SkillHandlers.TravelSkillHandler.Settings
TravelSkillHandler.settings = { --
    usePathfinding = true,
    onPathOnly = false,
    maxRange = 70,
    minRange = 30,
    minGain = 10,
    canBeShorter = true,
    notNearEnemies = false,
    notNearEnemiesRange = 0,
    ---@type boolean
    canFly = false,
}

TravelSkillHandler.debugRender = false

---@param target? Actor
---@return boolean ok, string? reason
function TravelSkillHandler:canUse(target)
    return false, "TravelSkillHandler does not use the :canUse() method"
end

--- Overridden so the default implementation cannot be used.
---@param target? Actor
---@param location? Vector3
function TravelSkillHandler:use(target, location)
end

--- Returns the travel skills currently travelable range.
---@return number travelableDistance Maximum traveable distance
---@return boolean canBeShorter Whether travel distance may be shorter than the max range
function TravelSkillHandler:getCurrentPossibleTravelRange()
    return self.settings.maxRange, self.settings.canBeShorter
end

---@param destination Vector3
---@return Vector3? travelDestination
function TravelSkillHandler:getTravelPosition(destination)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()
    local distance = pLoc:getDistanceXY(destination)
    local travelDistance = -1
    if self.settings.canBeShorter and distance > self.settings.minRange then
        travelDistance = math.min(distance, self.settings.maxRange)
    elseif distance >= self.settings.maxRange then
        travelDistance = self.settings.maxRange
    else
        return nil
    end

    local rVec = Vector.rVec(pLoc, destination)
    local travelDestination = Vector.add(pLoc, Vector.modifyLength(rVec, travelDistance))
    travelDestination.X = math.floor(travelDestination.X)
    travelDestination.Y = math.floor(travelDestination.Y)

    ---@cast travelDestination Vector3
    return travelDestination
end

---@param locations Vector3[]
---@param costs number[]
---@return Vector3? location, number cost
function TravelSkillHandler:getBestLocationAlongPath(locations, costs)
    if not self:baseCanUse(nil) then
        return nil, math.huge
    end

    if self.settings.notNearEnemies then
        for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            if mob:getDistanceToPlayer() < self.settings.notNearEnemiesRange then
                return nil, math.huge
            end
        end
    end

    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local origin = lPlayer:getLocation()
    local maxRange = self.settings.maxRange
    local minRange = self.settings.canBeShorter and self.settings.minRange or maxRange - 10
    -- We give a slight bit of room in case canBeShorter is false, to give the calculations a bit of leeway.

    -- Check if we can go directly to the final destination
    local destination = locations[#locations]
    if destination == nil then
        return nil, math.huge
    end

    local distance = origin:getDistanceXY(destination)
    if distance >= minRange and distance <= maxRange and lPlayer:hasLineOfSightTo(destination, self.settings.canFly) and (self.settings.canFly or not self:isObstructed(destination)) then
        return destination, 0
    end

    local best, cost = nil, math.huge
    for angle = 0, 360, 10 do
        local x = origin.X + maxRange * math.cos(angle / (180 / math.pi))
        local y = origin.Y + maxRange * math.sin(angle / (180 / math.pi))
        local direction = Vector.round(Vector3(x, y, origin.Z)) --[[@as Vector3]]
        local loc, c = self:checkDirection(origin, direction, locations, costs, minRange)
        if loc and c < cost then
            best = loc
            cost = c
        end
    end

    return best, cost
end

---@return boolean
function TravelSkillHandler:needsPathfinding()
    return self.settings.usePathfinding
end

---@param origin Vector3
---@param direction Vector3
---@param locations Vector3[]
---@param costs number[]
---@param minRange number
---@return Vector3? best, number cost
function TravelSkillHandler:checkDirection(origin, direction, locations, costs, minRange)
    local _, collision = CombatUtils.ConservativeRaycast(origin, direction, self.settings.canFly, COLLISION_RADIUS)
    local loc = collision or direction
    -- if origin:getDistanceXY(loc) < minRange then
    --     return nil, math.huge
    -- end

    if not self.settings.canFly and self:isObstructed(loc) then
        return nil, math.huge
    end

    local best, cost = nil, math.huge
    for i, l in ipairs(locations) do
        local dist, optimal = math.huge, loc
        if not self.settings.canBeShorter then
            dist, optimal = loc:getDistanceXY(l), loc
        else
            dist, optimal = Vector.GetPointSegmentDistance(l, origin, loc)
            if origin:getDistanceXY(optimal) < minRange then
                optimal = Vector.round(Vector.resizeXY(origin, optimal, minRange)) --[[@as Vector3]]
                dist = optimal:getDistanceXY(l)
            end
        end
        -- Always check the first waypoint, because it may be far away due to
        -- line of sight waypoint popping.
        if dist <= RAYCAST_DISTANCE_LIMIT or i == 1 then
            local c = costs[i] + dist
            if c < cost and not CombatUtils.Raycast(optimal, l, false) then
                best = optimal
                cost = c
            end
        end
    end

    return best, cost
end

---@param destination Vector3
---@return boolean obstructed
function TravelSkillHandler:isObstructed(destination)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()

    -- Check collision with terrain
    if CombatUtils.ConservativeRaycast(pLoc, destination, self.settings.canFly, COLLISION_RADIUS) then
        return true
    end

    if not self.settings.canFly then
        -- Check for collidable actors
        for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_Collidable)) do
            if self:isObstruction(actor, pLoc, destination, COLLISION_RADIUS) then
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
function TravelSkillHandler:isObstruction(actor, from, to, radius)
    local size = actor:getObjectSize()
    local p = actor:getLocation()
    local dist, _ = Vector.DistanceToSegment(p, from, to)
    return dist <= (size + radius)
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
---@return boolean
function TravelSkillHandler:travel(destination, locations, costs)
    if not self:baseCanUse(nil) then
        return false
    end

    if self:getActiveSkillId() == "blink" then
        local hasReservation = false
        for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
            if buff:getKey() == "blink_reservation" and buff:getAssociatedSkillId() == (self.skillId - 0x1000) then
                hasReservation = true
                break
            end
        end
        if not hasReservation then
            return false
        end
    end

    if self.settings.notNearEnemies then
        for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            if mob:getDistanceToPlayer() < self.settings.notNearEnemiesRange then
                return false
            end
        end
    end

    if self.settings.usePathfinding then
        if self.settings.onPathOnly then
            local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
            for i = #locations, 1, -1 do
                local wp = locations[i]
                if self:isInRange(wp, self.settings.maxRange, true, self.settings.canFly) and wp:getDistanceXY(pLoc) >= self.settings.minRange then
                    self:super():use(nil, wp)
                    return true
                end
            end
            return false
        end

        local best, cost = self:getBestLocationAlongPath(locations, costs)
        if best == nil then
            return false
        end

        local first = locations[1]
        if first ~= nil then
            local gain = costs[1] + Infinity.PoE2.getLocalPlayer():getLocation():getDistanceXY(first) - cost
            if gain < self.settings.minGain then
                return false
            end
        end

        self:super():use(nil, best)
        return true
    else
        local travelDestination = self:getTravelPosition(destination)
        if travelDestination == nil then
            return false
        end

        if self:isObstructed(travelDestination) then
            return false
        end
        self:super():use(nil, travelDestination)
        return true
    end
end

---@param key string
function TravelSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##travel_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.usePathfinding = ImGui.Checkbox(label("Use Pathfinding", "usePathfinding") .. key, self.settings.usePathfinding)
    UI.WithDisable(not self.settings.usePathfinding, function()
        UI.WithIndent(function()
            _, self.settings.onPathOnly = ImGui.Checkbox(label("On Path Only", "onPathOnly") .. key, self.settings.onPathOnly)
            UI.Tooltip("Will not divert from the path to find the best possible travel position.")
        end)
    end)

    _, self.settings.maxRange = ImGui.InputInt(label("Max Range", "range") .. key, self.settings.maxRange)
    _, self.settings.canBeShorter = ImGui.Checkbox(label("Can Be Shorter", "canBeShorter") .. key, self.settings.canBeShorter)
    UI.WithDisable(not self.settings.canBeShorter, function()
        ImGui.SameLine()
        _, self.settings.minRange = ImGui.InputInt(label("Min Range", "minRange") .. key, self.settings.minRange)
    end)

    _, self.settings.minGain = ImGui.InputInt(label("Min Gain", "minGain") .. key, self.settings.minGain)

    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly") .. key, self.settings.canFly)

    _, self.settings.notNearEnemies = ImGui.Checkbox(label("Don't Use Near Enemies Within", "notNearEnemies") .. key, self.settings.notNearEnemies)
    UI.WithDisable(not self.settings.notNearEnemies, function()
        ImGui.SameLine()
        _, self.settings.notNearEnemiesRange = ImGui.InputInt(label("Range", "notNearEnemiesinRange") .. key, self.settings.notNearEnemiesRange)
    end)

    ImGui.PopItemWidth()
end

---@param target Actor?
function TravelSkillHandler:drawDebug(target)
    _, self.debugRender = ImGui.Checkbox("Debug Render##travel_skill_handler_debug_render", self.debugRender)
end

function TravelSkillHandler:onRenderD2D()
    if not self.debugRender then
        return
    end

    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pWorldPos = lPlayer:getWorld()
    local pLoc = lPlayer:getLocation()
    local mousePos = Infinity.PoE2.getGameStateController():getInGameState():getCursorWorldPos()
    local mouseLoc = Infinity.PoE2.WorldTransform.WorldToLocation(mousePos)

    Render.DrawWorldLine(pWorldPos, mousePos, "FFFF0000", 2)

    -- Terrain collision
    local collided, collision = CombatUtils.ConservativeRaycast(pLoc, mouseLoc, false, 1)
    if collided and collision then
        Render.DrawWorldCircle(Infinity.PoE2.WorldTransform.LocationToWorld(Vector2(collision.X, collision.Y)), 10, "FFFF0000", 3, false)
    end

    -- Object collisions
    for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_Collidable)) do
        local worldPos = actor:getWorld()
        local size = actor:getObjectSize()

        Render.DrawWorldCircle(worldPos, size * 10.87, "FFFFFFFF", 2, false)
        if not self.settings.canFly and self:isObstruction(actor, pLoc, mouseLoc, COLLISION_RADIUS) then
            Render.DrawWorldCircle(worldPos, (size + COLLISION_RADIUS) * 10.87, "FFFF0000", 2, false)
        else
            Render.DrawWorldCircle(worldPos, (size + COLLISION_RADIUS) * 10.87, "FFFFFF00", 2, false)
        end
    end
end

return TravelSkillHandler
