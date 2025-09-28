---@diagnostic disable: missing-return
---@class GroundEffectsFile : Object
GroundEffectsFile = {}

---@return table<number, GroundEffect>
function GroundEffectsFile:getGroundEffects()
end

---@param address LuaInt64
---@return GroundEffect?
function GroundEffectsFile:getGroundEffectByAdr(address)
end

---@param index number
---@return GroundEffect?
function GroundEffectsFile:getGroundEffectByIndex(index)
end
