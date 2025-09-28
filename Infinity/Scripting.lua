---@diagnostic disable: missing-return
--- Infinity Scripting namespace
---@class Infinity.Scripting
Infinity.Scripting = {}

---@type LuaScript script
---@deprecated Use `Infinity.Scripting.GetCurrentScript()` instead
Infinity.Scripting.CurrentScript = {}

---@return LuaScript script
function Infinity.Scripting.GetCurrentScript()
end

---@param name string
---@return LuaScript? script nil if not found
function Infinity.Scripting.GetScript(name)
end

---@return table<number, LuaScript>
function Infinity.Scripting.getAllScripts()
end

