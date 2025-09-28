---@diagnostic disable: missing-return
---@class Skill : Object
Skill = {}

---@return boolean
function Skill:isNull()
end

---@return number
function Skill:getSkillId()
end

---@return number
function Skill:getSkillUseStage()
end

---@return number
function Skill:getSkillFlag02()
end

---@return boolean
function Skill:canBeUsedWithWeapon()
end

---@return boolean
function Skill:canBeUsed()
end

---@return number
function Skill:getCost()
end

---@return number
function Skill:getTotalUses()
end

---@return number
function Skill:getCooldown()
end

---@return number
function Skill:getSoulsPerUse()
end

---@return number
function Skill:getTotalVaalUses()
end

---@return number
function Skill:getSlotIdentifier()
end

---@return number
function Skill:getSocketIndex()
end

---@return boolean
function Skill:getIsUserSkill()
end

---@return boolean
function Skill:getAllowedToCast()
end

---@return boolean
function Skill:getIsUsing()
end

---@return boolean
function Skill:getPrepareForUsage()
end

---@return table<number, SupportGemWrapper>
function Skill:getSupportGems()
end

---@return SkillStatWrapper
function Skill:getSkillStatWrapper()
end

---@return GrantedEffectsPerLevel?
function Skill:getGrantedEffectsPerLevel()
end

---@return GrantedEffectStatSetsPerLevel?
function Skill:getGrantedEffectStatSetsPerLevel()
end

---@return boolean
function Skill:isAssociatedBuffActive()
end

---@return boolean
function Skill:isOnSkillBar()
end

---@return VaalSkill
function Skill:getVaalSkill()
end

---@return number
function Skill:getActiveCooldownCount()
end

---@return number
function Skill:getNumberDeployed()
end

---@return boolean
function Skill:isTotemSkill()
end

---@return boolean
function Skill:isMineSkill()
end

---@return number
function Skill:getMaxCharges()
end

---@return number
function Skill:getCharges()
end
