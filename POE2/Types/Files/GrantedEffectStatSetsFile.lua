---@diagnostic disable: missing-return
---@class GrantedEffectStatSetsFile : Object
GrantedEffectStatSetsFile = {}

---@return table<number, GrantedEffectStatSet>
function GrantedEffectStatSetsFile:getGrantedEffectStatSets()
end

---@param address LuaInt64
---@return GrantedEffectStatSet?
function GrantedEffectStatSetsFile:getGrantedEffectStatSetByAdr(address)
end

---@param index number
---@return GrantedEffectStatSet?
function GrantedEffectStatSetsFile:getGrantedEffectStatSetByIndex(index)
end
