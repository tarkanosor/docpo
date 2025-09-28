---@diagnostic disable: missing-return
---@class ModTypesFile : Object
ModTypesFile = {}

---@return table<number, ModType>
function ModTypesFile:getModTypes()
end

---@param address LuaInt64
---@return ModType?
function ModTypesFile:getModTypeByAdr(address)
end

---@param index number
---@return ModType?
function ModTypesFile:getModTypeByIndex(index)
end
