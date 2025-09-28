---@diagnostic disable: missing-return
---@class BaseItemTypesFile : Object
BaseItemTypesFile = {}

---@return table<number, BaseItemTypeData>
function BaseItemTypesFile:getBaseItemTypes()
end

---@param address LuaInt64
function BaseItemTypesFile:getBaseItemTypeDataByAdr(address)
end

---@param metaHash number
function BaseItemTypesFile:getBaseItemTypeDataByMetaHash(metaHash)
end
