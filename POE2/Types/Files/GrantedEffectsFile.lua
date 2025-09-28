---@diagnostic disable: missing-return
---@class GrantedEffectsFile : Object
GrantedEffectsFile = {}

---@return table<number, GrantedEffect>
function GrantedEffectsFile:getGrantedEffects()
end

---@param address LuaInt64
---@return GrantedEffect?
function GrantedEffectsFile:getGrantedEffectByAdr(address)
end

---@param index number
---@return GrantedEffect?
function GrantedEffectsFile:getGrantedEffectByIndex(index)
end
