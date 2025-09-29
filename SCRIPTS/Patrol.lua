local Class = require("CoreLib.Class")
---@class PoE2Lib.Patrol : Class
local Patrol = Class()

---@param location Vector3 The location to patrol around.
---@param radius number The radius to patrol around the location.
function Patrol:init(location, radius)
    self.location = location
    self.nextLocation = location
    self.lastNextLocationSetTime = 0
    self.radius = radius
end

local PATROL_ANGLE_STEP = 10
local PATROL_RADIUS_STEP = 10
local PATROL_LOCATION_TIMEOUT = 5000

---@return Vector3
function Patrol:getNextLocation()
    local navigator = Infinity.PoE2.getNavigator()
    -- Do we have to get a new location?
    if self.location:getDistanceXY(self.nextLocation) < 10 or
    Infinity.Win32.GetTickCount() - self.lastNextLocationSetTime > PATROL_LOCATION_TIMEOUT or not self.nextLocation or not navigator:isLocationReachable(self.nextLocation, 0) then
        local possibleLocations = {}

        -- Let's find a new random location within the radius
        for i = 1, 360, PATROL_ANGLE_STEP do
            local angle = i * PATROL_ANGLE_STEP
            for r = 0, self.radius, PATROL_RADIUS_STEP do
                local x = math.floor(self.location.X + r * math.cos(angle))
                local y = math.floor(self.location.Y + r * math.sin(angle))
                local newLocation = Vector3(x, y, 0)
                if navigator:isLocationReachable(newLocation, 0) then
                    table.insert(possibleLocations, newLocation)
                end
            end
        end

        if #possibleLocations > 0 then
            self.nextLocation = possibleLocations[math.random(1, #possibleLocations)]
        end

        if #possibleLocations == 0 then
            self.nextLocation = self.location
        end

        self.lastNextLocationSetTime = Infinity.Win32.GetTickCount()
    end

    return self.nextLocation
end

return Patrol
