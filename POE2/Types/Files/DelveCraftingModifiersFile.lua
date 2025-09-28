---@diagnostic disable: missing-return
---@class DelveCraftingModifiersFile : Object
DelveCraftingModifiersFile = {}

---@return table<number, DelveCraftingModifier>
function DelveCraftingModifiersFile:getDelveCraftingModifiers()
end

---@param address LuaInt64
---@return GrantedEffectStatSetsPerLevel?
function DelveCraftingModifiersFile:getDelveCraftingModifierByAdr(address)
end

---@param index number
---@return GrantedEffectStatSetsPerLevel?
function DelveCraftingModifiersFile:getDelveCraftingModifierByIndex(index)
end
