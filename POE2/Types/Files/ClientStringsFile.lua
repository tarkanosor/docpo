---@diagnostic disable: missing-return
---@class ClientStringsFile : Object
ClientStringsFile = {}

---@return table<number, ClientString>
function ClientStringsFile:getClientStrings()
end

---@param address LuaInt64
function ClientStringsFile:getClientStringByAdr(address)
end

---@param index number
function ClientStringsFile:getClientStringByIndex(index)
end
