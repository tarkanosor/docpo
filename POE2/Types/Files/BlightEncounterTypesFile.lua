---@diagnostic disable: missing-return
---@class BlightEncounterTypesFile : Object
BlightEncounterTypesFile = {}

---@return table<number, BlightEncounterType>
function BlightEncounterTypesFile:getBlightEncounterTypes()
end

---@param address LuaInt64
---@return BlightEncounterType?
function BlightEncounterTypesFile:getBlightEncounterTypeByAdr(address)
end

---@param index number
---@return BlightEncounterType?
function BlightEncounterTypesFile:getBlightEncounterTypeByIndex(index)
end
