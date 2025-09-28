---@diagnostic disable: missing-return
---@class BlightTowersFile : Object
BlightTowersFile = {}

---@return table<number, BlightTower>
function BlightTowersFile:getBlightTowers()
end

---@param address LuaInt64
---@return BlightTower?
function BlightTowersFile:getBlightTowerByAdr(address)
end

---@param index number
---@return BlightTower?
function BlightTowersFile:getBlightTowerByIndex(index)
end
