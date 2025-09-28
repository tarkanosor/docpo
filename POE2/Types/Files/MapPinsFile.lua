---@diagnostic disable: missing-return
---@class MapPinsFile : Object
MapPinsFile = {}

---@return table<number, MapPin>
function MapPinsFile:getMapPins()
end

---@param address LuaInt64
---@return MapPin?
function MapPinsFile:getMapPinByAdr(address)
end

---@param index number
---@return MapPin?
function MapPinsFile:getMapPinByIndex(index)
end
