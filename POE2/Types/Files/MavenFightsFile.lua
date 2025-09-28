---@diagnostic disable: missing-return
---@class MavenFightsFile : Object
MavenFightsFile = {}

---@return table<number, MavenFight>
function MavenFightsFile:getMavenFights()
end

---@param address LuaInt64
---@return MavenFight?
function MavenFightsFile:getMavenFightByAdr(address)
end

---@param index number
---@return MavenFight?
function MavenFightsFile:getMavenFightByIndex(index)
end
