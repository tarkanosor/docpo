---@diagnostic disable: missing-return
---@class GrantedEffectsPerLevelsFile : Object
GrantedEffectsPerLevelsFile = {}

---@return table<number, GrantedEffectsPerLevel>
function GrantedEffectsPerLevelsFile:getGrantedEffectsPerLevels()
end

---@param address LuaInt64
---@return GrantedEffectsPerLevel?
function GrantedEffectsPerLevelsFile:getGrantedEffectsPerLevelByAdr(address)
end

---@param index number
---@return GrantedEffectsPerLevel?
function GrantedEffectsPerLevelsFile:getGrantedEffectsPerLevelByIndex(index)
end
