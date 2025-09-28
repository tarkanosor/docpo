---@diagnostic disable: missing-return
---@class BuffTemplatesFile : Object
BuffTemplatesFile = {}

---@return table<number, BuffTemplate>
function BuffTemplatesFile:getBuffTemplates()
end

---@param address LuaInt64
function BuffTemplatesFile:getBuffTemplateByAdr(address)
end

---@param index number
function BuffTemplatesFile:getTemplateBuffByIndex(index)
end
