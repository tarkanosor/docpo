---@diagnostic disable: missing-return
---@class ModsFile : Object
ModsFile = {}

---@return table<number, Mod>
function ModsFile:getMods()
end

---@return table<integer, Mod>
function ModsFile:getCraftableMods()
end

---@return table<integer, Mod>
function ModsFile:getSextantMods()
end

---@return table<integer, Mod>
function ModsFile:getExpeditionMods()
end

---@return table<integer, Mod>
function ModsFile:getChestMods()
end

---@return table<ModType, table<number, Mod>>
function ModsFile:getModsGroupedByModType()
end

---@param address LuaInt64
---@return Mod?
function ModsFile:getModByAdr(address)
end

---@param index integer
---@return Mod?
function ModsFile:getModByIndex(index)
end

---@return table<integer, Mod>
function ModsFile:getPositivePrimordialAltarMods()
end

---@return table<integer, Mod>
function ModsFile:getNegativePrimordialAltarMods()
end

---@return table<integer, Mod>
function ModsFile:getAnimalCharmMods()
end

---@return table<integer, Mod>
function ModsFile:getAzmeriAltarMods()
end