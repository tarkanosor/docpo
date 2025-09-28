---@diagnostic disable: missing-return
---@class InGameData : Object
InGameData = {}

---@return LuaInt64
function InGameData:getLocalPlayerAdr()
end

---@return Actor?
function InGameData:getLocalPlayer_Direct()
end

---@return table<integer, Actor>
function InGameData:getActors_Direct()
end

---@return WorldData
function InGameData:getWorldData()
end

---@return WorldArea?
function InGameData:getCurrentWorldArea()
end