---@diagnostic disable: missing-return
---@class ActiveSkill : Object
ActiveSkill = {}

---@return string
function ActiveSkill:getId()
end

---@return string
function ActiveSkill:getDisplayedName()
end

---@return string
function ActiveSkill:getDescription()
end

---@return integer
function ActiveSkill:getIndex()
end

---@return string
function ActiveSkill:getIndex3()
end

---@return string
function ActiveSkill:getIconDDS()
end

---@return table<number, number>
function ActiveSkill:getActiveSkillTargetTypes()
end

---@return table<number, number>
function ActiveSkill:getActiveSkillTypes()
end

---@return table<number, ItemClassData>
function ActiveSkill:getWeaponRestrictionItemClasses()
end

---@return string
function ActiveSkill:getWebsiteDescription()
end

---@return string
function ActiveSkill:getWebsiteImage()
end

---@return number
function ActiveSkill:getSkillTotemId()
end

---@return boolean
function ActiveSkill:getIsManuallyCasted()
end

---@return table<number, Stat>
function ActiveSkill:getInputStats()
end

---@return table<number, Stat>
function ActiveSkill:getOutputStats()
end
