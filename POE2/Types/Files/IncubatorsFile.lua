---@diagnostic disable: missing-return
---@class IncubatorsFile : Object
IncubatorsFile = {}

---@return table<number, Incubator>
function IncubatorsFile:getIncubators()
end

---@param address LuaInt64
---@return Incubator?
function IncubatorsFile:getIncubatorByAdr(address)
end

---@param index number
---@return Incubator?
function IncubatorsFile:getIncubatorByIndex(index)
end
