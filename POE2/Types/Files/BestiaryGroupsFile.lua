---@diagnostic disable: missing-return
---@class BestiaryGroupsFile : Object
BestiaryGroupsFile = {}

---@return table<number, BestiaryGroup>
function BestiaryGroupsFile:getBestiaryGroups()
end

---@param address LuaInt64
---@return BestiaryGroup?
function BestiaryGroupsFile:getBestiaryGroupByAdr(address)
end

---@param index number
---@return BestiaryGroup?
function BestiaryGroupsFile:getBestiaryGroupByIndex(index)
end