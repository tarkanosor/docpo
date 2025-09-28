---@diagnostic disable: missing-return
---@class Infinity.Navigation
Infinity.Navigation = {}

---@return number
function Infinity.Navigation.getRenderDistance()
end

---@param distance number
function Infinity.Navigation.setRenderDistance(distance)
end

---@param dst Vector3
---@param polyPathMaxSize integer?
---@param vectorPathMaxSize integer?
---@param distanceFromWall number? --NOT IMPLEMENTED
---@return NavPath
function Infinity.Navigation.getPath(dst, polyPathMaxSize, vectorPathMaxSize, distanceFromWall)
end

function Infinity.Navigation.loadDefaultNavMesh()
end

---@param name string
function Infinity.Navigation.loadNavMesh(name)
end

-- TODO: Check params
---@param a Vector3
---@param b Vector3
function Infinity.Navigation.addBoxObstacle(a, b)
end

function Infinity.Navigation.onTeleport()
end

-- TODO: Check params
---@param loc Vector3
---@param radius number
---@param height number
function Infinity.Navigation.addCylinderObstacle(loc, radius, height)
end

-- TODO: Add signature
function Infinity.Navigation.registerScriptUsage(...)
end
-- TODO: Add signature
function Infinity.Navigation.unregisterScriptUsage(...)
end

