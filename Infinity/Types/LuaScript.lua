---@diagnostic disable: missing-return
---@class LuaScript
---@field IsRunning boolean
---@field Name string
---@field Directory string
---@field RegisterPacketReceivedCallback unknown
---@field RegisterPacketSentCallback unknown
---@field UnregisterPacketReceivedCallback unknown
---@field UnregisterPacketSentCallback unknown
LuaScript = {}

function LuaScript:Start()
end

function LuaScript:Stop()
end

---@param target LuaScript
---@param code string
function LuaScript:LuaExec(target, code)
end

---@param name CallbackName
---@param callback fun(...)
function LuaScript:RegisterCallback(name, callback)
end

---@param name CallbackName
---@param callback fun(...)
function LuaScript:UnregisterCallback(name, callback)
end

---@param name CallbackName
---@param callback fun(...)
---@deprecated Use `LuaScript:RegisterCallback()`
function LuaScript:RegisterGlobalHook(name, callback)
end

---@param name CallbackName
---@param callback fun(...)
---@deprecated Use `LuaScript:UnregisterCallback()`
function LuaScript:UnregisterGlobalHook(name, callback)
end

---@alias CallbackName
---| '"Infinity.OnPulse"'
---| '"Infinity.OnScriptStart"'
---| '"Infinity.OnScriptStop"'
---| '"Infinity.OnGUIDraw"'
---| '"Infinity.OnRenderD2D"'
---| '"Infinity.OnNewActor"' # fun(actor: Actor)
---| '"Infinity.OnCachedWorld"'
---| '"Infinity.OnSkillExecute"' # fun(skillId: number)
---| '"Infinity.OnPacketReceive"' # fun(byteBuffer: ByteBuffer)
---| '"Infinity.OnPacketSend"' # fun(byteBuffer: ByteBuffer)
---| '"Infinity.OnServerInventoryCreate"' # fun(serverInventory: ServerInventory)
---| '"Infinity.OnServerInventoryAddItem"' # fun(serverInventory: ServerInventory, itemActor: Actor, itemPosX: number, itemPosY: number, isGroundLoot: boolean)
---| '"Infinity.OnServerInventoryRemoveItem"' # fun(serverInventory: ServerInventory, itemActor: Actor, itemPosX: number, itemPosY: number)
---| '"Infinity.OnRecalculateNavMesh"'
---| '"Infinity.OnRecalculateReachability"'
---| '"Infinity.OnAutoLoginAutoLoad"'
---| '"Infinity.OnDeleteActor"'
---| '"Infinity.OnActorKilled"
---| '"Infinity.OnNavigationInvalidated"'
---| '"Infinity.OnTileRecalculation"'
---| '"Infinity.OnNewActorWrapper"'
---| '"Infinity.OnDeleteActorWrapper"'
