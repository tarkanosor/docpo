---@diagnostic disable: missing-return
---@return EssenceTypesFile
function FileController:getEssenceTypesFile()
end

---@class EssenceTypesFile : Object
EssenceTypesFile = {}

---@return table<number, EssenceType>
function EssenceTypesFile:getEssenceTypes()
end

---@param address LuaInt64
---@return EssenceType?
function EssenceTypesFile:getEssenceTypeByAdr(address)
end

---@param index number
---@return EssenceType?
function EssenceTypesFile:getEssenceTypeByIndex(index)
end
