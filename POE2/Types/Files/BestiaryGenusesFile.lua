---@diagnostic disable: missing-return
---@class BestiaryGenusesFile : Object
BestiaryGenusesFile = {}

---@return table<number, BestiaryGenus>
function BestiaryGenusesFile:getBestiaryGenuses()
end

---@param address LuaInt64 
---@return BestiaryGenus?
function BestiaryGenusesFile:getBestiaryGenusByAdr(address)
end

---@param index number
---@return BestiaryGenus?
function BestiaryGenusesFile:getBestiaryGenusByIndex(index)
end