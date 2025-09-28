---@diagnostic disable: missing-return
---@class ActiveSkillsFile : Object
ActiveSkillsFile = {}

---@return table<number, ActiveSkill>
function ActiveSkillsFile:getActiveSkills()
end

---@param address LuaInt64
---@return ActiveSkill?
function ActiveSkillsFile:getActiveSkillByAdr(address)
end

---@param index number
---@return ActiveSkill?
function ActiveSkillsFile:getActiveSkillByIndex(index)
end

