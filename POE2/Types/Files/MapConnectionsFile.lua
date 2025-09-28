---@diagnostic disable: missing-return
---@class MapConnectionsFile : Object
MapConnectionsFile = {}

---@return table<number, MapConnection>
function MapConnectionsFile:getMapConnection()
end

---@param address LuaInt64
---@return MapConnection?
function MapConnectionsFile:getMapConnectionByAdr(address)
end

---@param index number
---@return MapConnection?
function MapConnectionsFile:getMapConnectionByIndex(index)
end
