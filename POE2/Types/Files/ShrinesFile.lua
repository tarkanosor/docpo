---@diagnostic disable: missing-return
---@class ShrinesFile : Object
ShrinesFile = {}

---@return table<number, Shrine>
function ShrinesFile:getShrines()
end

---@param address LuaInt64
---@return Shrine?
function ShrinesFile:getShrineByAdr(address)
end

---@param index number
---@return Shrine?
function ShrinesFile:getShrineByIndex(index)
end
