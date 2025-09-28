---@diagnostic disable: missing-return
---@class GroundEffectTypesFile : Object
GroundEffectTypesFile = {}

---@return table<number, GroundEffectType>
function GroundEffectTypesFile:getGroundEffectTypes()
end

---@param address number
---@return GroundEffectType?
function GroundEffectTypesFile:getGroundEffectTypetByAdr(address)
end

---@param index number
---@return GroundEffectType?
function GroundEffectTypesFile:getGroundEffectTypeByIndex(index)
end
