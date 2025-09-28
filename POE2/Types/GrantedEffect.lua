---@diagnostic disable: missing-return
---@class GrantedEffect
GrantedEffect = {}

---@return string
function GrantedEffect:getId()
end

---@return number
function GrantedEffect:getBaseEffectiveness()
end

---@return number
function GrantedEffect:getIncrementalEffectiveness()
end

---@return string
function GrantedEffect:getSupportGemLetter()
end

---@return number
function GrantedEffect:getCastTime()
end

---@return ActiveSkill?
function GrantedEffect:getActiveSkill()
end
