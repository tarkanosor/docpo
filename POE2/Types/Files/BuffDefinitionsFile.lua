---@diagnostic disable: missing-return
---@class BuffDefinitionsFile : Object
BuffDefinitionsFile = {}

---@return table<number, BuffDefinition>
function BuffDefinitionsFile:getBuffDefinitions()
end

---@param address LuaInt64
function BuffDefinitionsFile:getBuffDefinitionByAdr(address)
end

---@param index number
function BuffDefinitionsFile:getBuffDefinitionByIndex(index)
end
