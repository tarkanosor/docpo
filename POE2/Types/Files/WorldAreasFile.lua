---@diagnostic disable: missing-return
---@class WorldAreasFile : Object
WorldAreasFile = {}

---@return table<number, WorldArea>
function WorldAreasFile:getWorldAreas()
end

---@param address LuaInt64
---@return WorldArea?
function WorldAreasFile:getWorldAreaByAdr(address)
end

---@param id string
---@return WorldArea?
function WorldAreasFile:getWorldAreaById(id)
end

---@param name string
---@return WorldArea?
function WorldAreasFile:getWorldAreaByName(name)
end

-- TODO: Check param
---@param waypoint unknown
---@return table<number, WorldArea>
function WorldAreasFile:getWorldAreasWithWaypoint(waypoint)
end
