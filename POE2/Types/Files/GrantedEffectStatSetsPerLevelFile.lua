---@diagnostic disable: missing-return
---@class GrantedEffectStatSetsPerLevelFile : Object
GrantedEffectStatSetsPerLevelFile = {}

---@return table<number, GrantedEffectStatSetsPerLevel>
function GrantedEffectStatSetsPerLevelFile:getGrantedEffectStatSetsPerLevels()
end

---@param address LuaInt64
---@return GrantedEffectStatSetsPerLevel?
function GrantedEffectStatSetsPerLevelFile:getGrantedEffectStatSetsPerLevelByAdr(address)
end

---@param index number
---@return GrantedEffectStatSetsPerLevel?
function GrantedEffectStatSetsPerLevelFile:getGrantedEffectStatSetsPerLevelByIndex(index)
end
