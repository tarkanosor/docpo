---@diagnostic disable: missing-return
---@class MonsterPacksFile : Object
MonsterPacksFile = {}

---@return table<number, MonsterPack>
function MonsterPacksFile:getMonsterPacks()
end

---@param address LuaInt64
---@return MonsterPack?
function MonsterPacksFile:getMonsterPackByAdr(address)
end

---@param index number
---@return MonsterPack?
function MonsterPacksFile:getMonsterPackByIndex(index)
end