---@diagnostic disable: missing-return
---@class Infinity.PoE2.WorldManager
Infinity.PoE2.WorldManager = {}

---@return POE2Navigator
function Infinity.PoE2.WorldManager.getNavigator()
end

---@param x number
---@param y number
---@return boolean
function Infinity.PoE2.WorldManager.isWalkableCell(x, y)
end

---@param x number
---@param y number
---@return number
function Infinity.PoE2.WorldManager.getCellHeight(x, y)
end

---@param x number
---@param y number
---@return boolean
function Infinity.PoE2.WorldManager.isWalkableTile(x, y)
end

---@return number
function Infinity.PoE2.WorldManager.getMaxWalkableTileX(...)
end

---@return number
function Infinity.PoE2.WorldManager.getMaxWalkableTileY(...)
end

---@return number
function Infinity.PoE2.WorldManager.getMinWalkableTileX(...)
end

---@return number
function Infinity.PoE2.WorldManager.getMinWalkableTileY(...)
end

function Infinity.PoE2.WorldManager.cacheCurrentWorld()
end
