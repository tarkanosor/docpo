---@diagnostic disable: missing-return
---@class NPCsFile : Object
NPCsFile = {}

---@return table<number, NPC>
function NPCsFile:getNPCs()
end

---@param address LuaInt64
---@return NPC?
function NPCsFile:getNPCByAdr(address)
end

---@param index number
---@return NPC?
function NPCsFile:getNPCByIndex(index)
end
