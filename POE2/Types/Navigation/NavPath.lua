---@diagnostic disable: missing-return
---@class NavPath
NavPath = {}

---@return NavPathWaypoint
function NavPath:getNextWaypoint_NoPop()
end

---@return NavPathWaypoint
function NavPath:getNextNextWaypoint_NoPop()
end

function NavPath:popNextWaypoint()
end

---@return NavPathWaypoint[]
function NavPath:getWaypoints()
end

---@return boolean
function NavPath:isDestinationReachable()
end

function NavPath:enableAutoRecalculate()
end

function NavPath:disableAutoRecalculate()
end

---@return number
function NavPath:getCurrentPolyPathLength()
end

---@return number
function NavPath:getCurrentVectorPathLength()
end

---@return Vector3
function NavPath:getDestination()
end

---@return number
function NavPath:getVectorPathDistanceLength()
end

---@param color? ImVec4
function NavPath:render(color)
end
