local Vector = require("CoreLib.Vector")
local Settings = require("CoreLib.Settings")
local Events = require("CoreLib.Events")
local UI = require("CoreLib.UI")
local Color = require("CoreLib.Color")


local Navigator = {}

local lastMoved = 0
local MIN_INTERVAL = 30

Navigator.WaypointArrivedDistance = 10
Navigator.DestinationArrivedDistance = 10

---@param destinationLocation Vector3
---@param moveInterval number? if no number is provided then caller has to handle the movement interval
function Navigator.MoveTo(destinationLocation, moveInterval)
    Navigator.SetDestination(destinationLocation)

    if Navigator.Arrived then
        return
    end

    local nextWaypointLoc = Navigator.GetNextWaypoint()
    if not nextWaypointLoc then
        return
    end

    local localPlayer = Infinity.PoE2.getLocalPlayer()
    if not localPlayer then
        return
    end

    local localPlayerDestination = localPlayer:getDestination()
    if localPlayerDestination:getDistanceXY(nextWaypointLoc) < 3 then
        return
    end

    local time = Infinity.Win32.GetPerformanceCounter()

    if moveInterval and time - lastMoved < moveInterval then
        return
    end

    if time - lastMoved < MIN_INTERVAL then
        print("ERROR: MoveTo called way too soon!")
        return
    end

    lastMoved = time
    localPlayer:moveTo(nextWaypointLoc, 0x0000, 0x3)
end

-- CoreLib/Navigator.lua
-- This module handles navigation logic, including pathfinding, waypoint management, and rendering navigation paths.



--- @class CoreLib.Navigator
local Navigator = {}

-- ########################################################################
-- SETTINGS
-- ########################################################################

---@class NavigatorSettings
---@field DrawPath boolean
---@field RenderLineToDestination boolean
---@field AllowAggressiveShortcutTaking boolean

Navigator.Settings = {
    DrawPath = true,
    RenderLineToDestination = true,
}
Settings.AddSettingsToHandler("PoE2Lib_Navigation", Navigator.Settings)

Navigator.WaypointArrivedDistance = 10
Navigator.DestinationArrivedDistance = 10

-- ########################################################################
-- PAUSE/RESUME FUNCTIONALITY
-- ########################################################################

---@type boolean
Navigator.Paused = false

--- Pauses the navigator.
function Navigator.Pause()
    Navigator.Paused = true
end

--- Resumes the navigator.
function Navigator.Resume()
    Navigator.Paused = false
end

-- ########################################################################
-- NAVIGATION STATE
-- ########################################################################

---@type Vector3?
---@private
Navigator.Destination = nil

---@type boolean
Navigator.Arrived = false

---@type Vector3[]
Navigator.CurrentPath = nil

---@type boolean
Navigator.DestinationReachable = true

---@type Vector3?
---@private
Navigator.NextWaypoint = nil

-- ########################################################################
-- RESET FUNCTIONALITY
-- ########################################################################

--- Resets the navigator state.
function Navigator.Reset()
    Navigator.Destination = nil
    Navigator.Arrived = false

    Navigator.CurrentPath = nil
    Navigator.DestinationReachable = true
    Navigator.NextWaypoint = nil
    print("Navigator state has been reset.")
end

-- ########################################################################
-- WAYPOINT MANAGEMENT
-- ########################################################################

local function isWaypointSkipable(waypoint, nextWaypoint)
    return false
end

--- Retrieves the next valid waypoint from the current path.
---@return Vector3? waypoint
local function getNextWaypoint()
    if not Navigator.CurrentPath then
        return nil
    end

    -- Pop waypoints that have been arrived at
    local waypoint = Navigator.CurrentPath[1]
    local playerLoc = Infinity.PoE2.getLocalPlayer():getLocation()

    if waypoint then
        local distToDest = waypoint:getDistanceXY(Navigator.Destination)

        while true do
            local nextWaypoint = Navigator.CurrentPath[1]
            if not nextWaypoint then
                break
            end

            if nextWaypoint:getDistanceXY(playerLoc) > Navigator.WaypointArrivedDistance then
                break
            end

            if distToDest < Navigator.DestinationArrivedDistance then
                break
            end

            table.remove(Navigator.CurrentPath, 1)
            waypoint = Navigator.CurrentPath[1]
        end
    end

    return waypoint
end

---@return Vector3? waypoint Next waypoint world position.
function Navigator.GetNextWaypoint()
    return Navigator.NextWaypoint
end

-- ########################################################################
-- DESTINATION SETTING
-- ########################################################################

--- Sets a new navigation destination.
---@param destination Vector3 Destination world position.
function Navigator.SetDestination(destination)
    if Navigator.CurrentPath == nil or --
    Navigator.Arrived or               --
    Navigator.Destination == nil or    --
    (not Vector.equal(Navigator.Destination, destination)) then
        Navigator.Reset()
        Navigator.Destination = destination
        Navigator.Arrived = false

        local navigator = Infinity.PoE2.getNavigator()
        if not navigator:isLocationReachable(destination, 10) then
            Navigator.DestinationReachable = false
            print("ERROR: Destination is not reachable.")
            return
        end

        local playerLoc = Infinity.PoE2.getLocalPlayer():getLocation()
        Navigator.CurrentPath = navigator:getPath(playerLoc.X, playerLoc.Y, Navigator.Destination.X, Navigator.Destination.Y)

        if not Navigator.CurrentPath or #Navigator.CurrentPath == 0 then
            Navigator.DestinationReachable = false
            print("ERROR: Failed to retrieve path to destination.")
        end

        Navigator.OnPulse_End()
        print("New destination set.")
    end
end

---@return Vector3? destination Destination world position.
function Navigator.GetDestination()
    return Navigator.Destination
end

-- ########################################################################
-- PULSE HANDLER
-- ########################################################################

--- Handler for the end of each pulse to update navigation state.
---@private
function Navigator.OnPulse_End()
    if Navigator.Destination == nil or Navigator.Paused or Navigator.Arrived then
        return
    end

    if not Navigator.DestinationReachable then
        return
    end

    if not Navigator.CurrentPath then
        print("ERROR: Detected nil path! Attempting to recreate path object.")
        local tempDestination = Navigator.Destination
        if tempDestination == nil then
            print("ERROR: Destination is nil! Cannot recreate path object.")
            return
        end

        Navigator.Reset()
        Navigator.SetDestination(tempDestination)
        return
    end

    local playerLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    local distanceToDestination = Navigator.Destination:getDistanceXY(playerLoc)

    -- Initial arrival check
    if distanceToDestination < Navigator.DestinationArrivedDistance then
        Navigator.Arrived = true
        return
    end

    local waypoint = getNextWaypoint()
    if not waypoint then
        print("ERROR: Waypoint is nil. This should not happen.")
        Navigator.DestinationReachable = false
        return
    end

    Navigator.NextWaypoint = waypoint
end

Events.OnPulse:register(function(data)
    Navigator.OnPulse_End()
end)

-- ########################################################################
-- RENDERING
-- ########################################################################

--- Renders the navigation path and lines to destination.
---@private
function Navigator.OnRenderD2D()
    if Navigator.Arrived then
        return
    end

    if Navigator.Settings.DrawPath and Navigator.CurrentPath then
        local current = Infinity.PoE2.getLocalPlayer():getLocation()
        for i = 1, #Navigator.CurrentPath do
            local next = Navigator.CurrentPath[i]
            if next then
                local currentWorldPos = Infinity.PoE2.WorldTransform.LocationToWorld(current)
                local nextWorldPos = Infinity.PoE2.WorldTransform.LocationToWorld(next)
                Infinity.Rendering.DrawWorldLine(
                    currentWorldPos,
                    nextWorldPos,
                    Color.Red,
                    2
                )
                current = next
            end
        end
    end

    if Navigator.Settings.DrawPath and Navigator.NextWaypoint then
        local playerWorldPos = Infinity.PoE2.getLocalPlayer():getWorld()
        local waypointWorldPos = Infinity.PoE2.WorldTransform.LocationToWorld(Navigator.NextWaypoint)

        Infinity.Rendering.DrawWorldLine(playerWorldPos, waypointWorldPos, Color.Blue, 4)
    end

    if Navigator.Settings.RenderLineToDestination and Navigator.Destination then
        local playerWorldPos = Infinity.PoE2.getLocalPlayer():getWorld()
        local destWorldPos = Infinity.PoE2.WorldTransform.LocationToWorld(Navigator.Destination)
        Infinity.Rendering.DrawWorldLine(playerWorldPos, destWorldPos, Color.Green, 4)
    end
end

Events.OnRenderD2D:register(function()
    Navigator.OnRenderD2D()
end)

-- ########################################################################
-- SETTINGS UI
-- ########################################################################

--- Draws the navigator settings UI.
function Navigator.DrawSettings()
    Navigator.Settings.DrawPath = UI.Checkbox(
        "Draw Path",
        Navigator.Settings.DrawPath
    )

    Navigator.Settings.RenderLineToDestination = UI.Checkbox(
        "Render Line to Destination",
        Navigator.Settings.RenderLineToDestination
    )
end

return Navigator
