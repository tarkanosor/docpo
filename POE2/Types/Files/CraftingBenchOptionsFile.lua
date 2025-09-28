---@diagnostic disable: missing-return
---@class CraftingBenchOptionsFile : Object
CraftingBenchOptionsFile = {}

---@return table<number, CraftingBenchOption>
function CraftingBenchOptionsFile:getCraftingBenchOptions()
end

---@param address LuaInt64
---@return CraftingBenchOption?
function CraftingBenchOptionsFile:getCraftingBenchOptionByAdr(address)
end

---@param index number
---@return CraftingBenchOption?
function CraftingBenchOptionsFile:getCraftingBenchOptionByIndex(index)
end
