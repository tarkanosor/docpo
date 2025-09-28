---@diagnostic disable: missing-return
---@class BlightTowersPerLevelFile : Object
BlightTowersPerLevelFile = {}

---@return table<number, BlightTowersPerLevel>
function BlightTowersPerLevelFile:getBlightTowersPerLevels()
end

---@param address LuaInt64
---@return BlightTowersPerLevel?
function BlightTowersPerLevelFile:getBlightTowersPerLevelByAdr(address)
end

---@param index number
---@return BlightTowersPerLevel?
function BlightTowersPerLevelFile:getBlightTowersPerLevelByIndex(index)
end
