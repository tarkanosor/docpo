---@diagnostic disable: missing-return
---@class EssencesFile : Object
EssencesFile = {}

---@return table<number, Essence>
function EssencesFile:getEssences()
end

---@param address LuaInt64
---@return Essence?
function EssencesFile:getEssenceByAdr(address)
end

---@param index number
---@return Essence?
function EssencesFile:getEssenceByIndex(index)
end
