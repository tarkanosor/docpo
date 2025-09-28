---@diagnostic disable: missing-return
---@class GrantedEffectsPerLevel : Object
GrantedEffectsPerLevel = {}

---@return number
function GrantedEffectsPerLevel:getLevel()
end

---@return GrantedEffect?
function GrantedEffectsPerLevel:getGrantedEffect()
end

---@return table<number, Stat>
function GrantedEffectsPerLevel:getStats()
end

---@param index number 0-indexed?
---@return number
function GrantedEffectsPerLevel:getStatsValue(index)
end

---@return table<number, number>
function GrantedEffectsPerLevel:getStatsValues()
end

---@return table<number, EffectivenessCostConstant>
function GrantedEffectsPerLevel:getEffectivenessCostConstants()
end

---@return number
function GrantedEffectsPerLevel:getRequiredLevel()
end

---@return number
function GrantedEffectsPerLevel:getManaMulti()
end

---@return number
function GrantedEffectsPerLevel:getRequiredLevel2()
end

---@return number
function GrantedEffectsPerLevel:getRequiredLevel3()
end

---@return number
function GrantedEffectsPerLevel:getCriticalStrikeChance()
end

---@return number
function GrantedEffectsPerLevel:getDamageEffectiveness()
end

---@return number
function GrantedEffectsPerLevel:getStoredUses()
end

---@return number
function GrantedEffectsPerLevel:getCooldown()
end

---@return number
function GrantedEffectsPerLevel:getCooldownBypassType()
end

---@return table<number, Stat>
function GrantedEffectsPerLevel:getStats2()
end

---@return number
function GrantedEffectsPerLevel:getCooldownGroup()
end

---@return number
function GrantedEffectsPerLevel:getVaalSouls()
end

---@return number
function GrantedEffectsPerLevel:getVaalStoredUses()
end

---@return number
function GrantedEffectsPerLevel:getManaReservationOverride()
end

---@return number
function GrantedEffectsPerLevel:getDamageMultiplier()
end

---@return table<number, number>
function GrantedEffectsPerLevel:getStatInterpolationTypes()
end

---@return table<number, number>
function GrantedEffectsPerLevel:getCosts()
end

---@return table<number, CostType>
function GrantedEffectsPerLevel:getCostTypes()
end
