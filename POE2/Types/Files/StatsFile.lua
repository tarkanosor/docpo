---@diagnostic disable: missing-return
---@class StatsFile : Object
StatsFile = {}

---@return table<number, Stat>
function StatsFile:getStats()
end

---@param id number
---@return Stat?
function StatsFile:getStatById(id)
end

---@param name string
---@return Stat?
function StatsFile:getStatByName(name)
end
