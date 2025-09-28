---@diagnostic disable: missing-return
---@class BlightRewardTypesFile : Object
BlightRewardTypesFile = {}

---@return table<number, BlightRewardType>
function BlightRewardTypesFile:getBlightRewardTypes()
end

---@param address LuaInt64
---@return BlightRewardType?
function BlightRewardTypesFile:getBlightRewardTypeByAdr(address)
end

---@param index number
---@return BlightRewardType?
function BlightRewardTypesFile:getBlightRewardTypeByIndex(index)
end
