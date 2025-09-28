---@diagnostic disable: missing-return
---@class SkillGemsFile : Object
SkillGemsFile = {}

---@return table<number, SkillGem>
function SkillGemsFile:getSkillGems()
end

---@param address LuaInt64
---@return SkillGem?
function SkillGemsFile:getSkillGemByAdr(address)
end

---@param index number
---@return SkillGem?
function SkillGemsFile:getSkillGemByIndex(index)
end
