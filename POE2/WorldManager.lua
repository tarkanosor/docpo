---@diagnostic disable: missing-return
---@class Infinity.PoE.WorldManager
Infinity.PoE.WorldManager = {}

---@return POENavigator
function Infinity.PoE.WorldManager.getNavigator()
end

---@param x number
---@param y number
---@return boolean
function Infinity.PoE.WorldManager.isWalkableCell(x, y)
end

---@param x number
---@param y number
---@return number
function Infinity.PoE.WorldManager.getCellHeight(x, y)
end

---@param x number
---@param y number
---@return boolean
function Infinity.PoE.WorldManager.isWalkableTile(x, y)
end

---@return number
function Infinity.PoE.WorldManager.getMaxWalkableTileX(...)
end

---@return number
function Infinity.PoE.WorldManager.getMaxWalkableTileY(...)
end

---@return number
function Infinity.PoE.WorldManager.getMinWalkableTileX(...)
end

---@return number
function Infinity.PoE.WorldManager.getMinWalkableTileY(...)
end

function Infinity.PoE.WorldManager.cacheCurrentWorld()
end
