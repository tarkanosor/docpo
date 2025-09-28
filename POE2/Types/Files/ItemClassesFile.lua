---@diagnostic disable: missing-return
---@class ItemClassesFile : Object
ItemClassesFile = {}

---@return table<number, ItemClassData>
function ItemClassesFile:getItemClasses()
end

---@param address LuaInt64
---@return ItemClassData?
function ItemClassesFile:getItemClassDataByAdr(address)
end
