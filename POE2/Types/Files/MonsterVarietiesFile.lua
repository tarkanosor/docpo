---@diagnostic disable: missing-return
---@class MonsterVarietiesFile : Object
MonsterVarietiesFile = {}

---@return table<number, MonsterVariety>
function MonsterVarietiesFile:getMonsterVarieties()
end

---@param address LuaInt64
---@return MonsterVariety?
function MonsterVarietiesFile:getMonsterVarietyByAdr(address)
end

---@param index number
---@return MonsterVariety?
function MonsterVarietiesFile:getMonsterVarietyByIndex(index)
end