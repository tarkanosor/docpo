---@diagnostic disable: missing-return
---@class ExpeditionData : Object
ExpeditionData = {}

---@return table<number, Actor>
function ExpeditionData:getCursorActors()
end

---@return table<number, Actor>
function ExpeditionData:getExpeditonActors()
end

---@return table<number, Vector3>
function ExpeditionData:getDeployedExplosivePositions()
end

---@return number
function ExpeditionData:getMaxCount()
end

---@return number
function ExpeditionData:getCurrentCount()
end

---@return number
function ExpeditionData:getAmountLeft()
end

---@return boolean
function ExpeditionData:isInRange()
end

---@return boolean
function ExpeditionData:canPlace()
end

---@param location Vector2
---@return boolean
function ExpeditionData:canPlaceAt(location)
end
