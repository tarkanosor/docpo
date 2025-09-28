---@diagnostic disable: missing-return
---@class EffectivenessCostConstantsFile : Object
EffectivenessCostConstantsFile = {}

---@return table<number, EffectivenessCostConstant>
function EffectivenessCostConstantsFile:getEffectivenessCostConstants()
end

---@param address LuaInt64
---@return EffectivenessCostConstant?
function EffectivenessCostConstantsFile:getEffectivenessCostConstantByAdr(address)
end

---@param index number
---@return EffectivenessCostConstant?
function EffectivenessCostConstantsFile:getEffectivenessCostConstantByIndex(index)
end
