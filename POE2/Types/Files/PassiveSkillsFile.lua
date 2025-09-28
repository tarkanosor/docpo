---@diagnostic disable: missing-return
---@class PassiveSkillsFile : Object
PassiveSkillsFile = {}

---@return table<number, PassiveSkill>
function PassiveSkillsFile:getPassiveSkills()
end

---@param address LuaInt64
---@return PassiveSkill?
function PassiveSkillsFile:getPassiveSkillByAdr(address)
end

---@param index number
---@return PassiveSkill?
function PassiveSkillsFile:getPassiveSkillByIndex(index)
end

-- TODO: Check param
---@param id string
---@return PassiveSkill?
function PassiveSkillsFile:getPassiveSkillById(id)
end
