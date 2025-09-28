---@diagnostic disable: missing-return
---@class MapFragmentModsFile : Object
MapFragmentModsFile = {}

---@return table<number, MapFragmentMods>
function MapFragmentModsFile:getMapFragmentMods()
end

---@param address LuaInt64
---@return MapFragmentMods?
function MapFragmentModsFile:getMapFragmentModsByAdr(address)
end

---@param index number
---@return MapFragmentMods?
function MapFragmentModsFile:getMapFragmentModsByIndex(index)
end
