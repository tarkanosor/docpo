---@diagnostic disable: missing-return
---@class BestiaryEncountersFile : Object
BestiaryEncountersFile = {}

---@return table<number, BestiaryEncounter>
function BestiaryEncountersFile:getBestiaryEncounters()
end

---@param address LuaInt64
---@return BestiaryEncounter?
function BestiaryEncountersFile:getBestiaryEncounterByAdr(address)
end

---@param index number
---@return BestiaryEncounter?
function BestiaryEncountersFile:getBestiaryEncounterByIndex(index)
end