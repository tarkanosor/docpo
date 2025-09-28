---@diagnostic disable: missing-return
---@class FlaskStatWrapper = {}ject
FlaskStatWrapper = {}

---@return table<number, Stat>
function FlaskStatWrapper:getStats()
end

---@return table<number, number>
function FlaskStatWrapper:getValues()
end

---@param statKey number
---@return boolean
function FlaskStatWrapper:hasStat(statKey)
end

---@param statKey number
---@return number value
function FlaskStatWrapper:getStatValue(statKey)
end
