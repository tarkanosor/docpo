---@diagnostic disable: missing-return
---@class HarvestCraftOptionsFile : Object
HarvestCraftOptionsFile = {}

---@return table<number, HarvestCraftOption>
function HarvestCraftOptionsFile:getHarvestCraftOptions()
end

---@param address LuaInt64
---@return GrantedEffectStatSetsPerLevel?
function HarvestCraftOptionsFile:getHarvestCraftOptionByAdr(address)
end

---@param index number
---@return GrantedEffectStatSetsPerLevel?
function HarvestCraftOptionsFile:getHarvestCraftOptionByIndex(index)
end
