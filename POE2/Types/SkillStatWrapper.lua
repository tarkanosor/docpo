---@diagnostic disable: missing-return
---@class SkillStatWrapper : Object
SkillStatWrapper = {}

---@return table<number, number>
function SkillStatWrapper:getStats()
end

--- Returns true if the SkillStatWrapper has the specific getStats
---@param id integer The stat id to check
---@return boolean
function SkillStatWrapper:hasStat(id)
end

---@param statIndex integer
---@return number
function SkillStatWrapper:getStatValue(statIndex)
end
