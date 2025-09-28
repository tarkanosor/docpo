---@diagnostic disable: missing-return
---@class CostTypesFile : Object
CostTypesFile = {}

---@return table<number, CostType>
function CostTypesFile:getCostTypes()
end

---@param address LuaInt64
---@return CostType?
function CostTypesFile:getCostTypeByAdr(address)
end

---@param index number
---@return CostType?
function CostTypesFile:getCostTypeByIndex(index)
end
