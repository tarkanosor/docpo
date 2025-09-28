---@diagnostic disable: missing-return
---@class BestiaryCapturableMonster : Object
---@field Id integer
BestiaryCapturableMonster = {}

---@return MonsterVariety   ?
function BestiaryCapturableMonster:getMonsterVariety()
end

---@return BestiaryGroup?
function BestiaryCapturableMonster:getBestiaryGroup()
end

---@return BestiaryEncounter?
function BestiaryCapturableMonster:getBestiaryEncounter()
end

---@return BestiaryGenus?
function BestiaryCapturableMonster:getBestiaryGenus()
end

---@return string 
function BestiaryCapturableMonster:get2DArt()
end

---@return integer
function BestiaryCapturableMonster:getCapturedAmount()
end