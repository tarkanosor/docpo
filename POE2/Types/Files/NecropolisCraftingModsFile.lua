---@diagnostic disable: missing-return
---@class NecropolisCraftingModsFile : Object
NecropolisCraftingModsFile = {}

---@return table<number, NecropolisCraftingMod>
function NecropolisCraftingModsFile:getNecropolisCraftingMods()
end

---@param address LuaInt64
---@return NecropolisCraftingMod?
function NecropolisCraftingModsFile:getNecropolisCraftingModByAdr(address)
end

---@param index number
---@return NecropolisCraftingMod?
function NecropolisCraftingModsFile:getNecropolisCraftingModByIndex(index)
end

---@param id integer
---@return NecropolisCraftingMod?
function NecropolisCraftingModsFile:getNecropolisCraftingModById(id)
end
