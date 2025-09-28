---@diagnostic disable: missing-return
---@class MonsterVariety : Object
---@field Id integer
MonsterVariety = {}

---@return string
function MonsterVariety:getMetaPath()
end

---@return string
function MonsterVariety:getBaseMonsterMetaPath()
end

---@return integer
function MonsterVariety:getObjectSize()
end

---@return integer 
function MonsterVariety:getMinAttackCellDistance()
end

---@return integer 
function MonsterVariety:getMaxAttackCellDistance()
end

---@return integer
function MonsterVariety:getModsCount()
end

---@return Mod[]
function MonsterVariety:getMods()
end

---@return string 
function MonsterVariety:getName()
end

---@return ItemClassData[]
function MonsterVariety:getItemClasses()
end