---@diagnostic disable: missing-return
---@class BestiaryEncounter : Object
---@field Index integer
BestiaryEncounter = {}

---@return string 
function BestiaryEncounter:getId()
end

---@return MonsterVariety?
function BestiaryEncounter:getMonsterVariety()
end

---@return MonsterPack?
function BestiaryEncounter:getMonsterPack()
end

---@return string 
function BestiaryEncounter:getMonsterSpawnerMetaPath()
end