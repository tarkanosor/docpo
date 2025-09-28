---@diagnostic disable: missing-return
---@class WorldData : Object
WorldData = {}

---@return table<number, TileData>
function WorldData:getAllTiles()
end

---@return boolean
function WorldData:hasTileData()
end

---@param gridPosX number
---@param gridPosY number
---@return TileData?
function WorldData:getTileData(gridPosX, gridPosY)
end

---@param file string
---@return table<number, TileData>
function WorldData:getTilesByMetaFile(file)
end

---@param x integer
---@param y integer
---@param vIndex integer
---@return integer bitFlag
function WorldData:getCellBitFlag(x, y, vIndex)
end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param layer integer @0 for ground, 1 for flyable
---@return boolean hasCollision
---@return integer collisionX
---@return integer collisionY
function WorldData:raycast(x1, y1, x2, y2, layer)
end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param layer integer @0 for ground, 1 for flyable
---@param objectSize integer
---@return boolean hasCollision
---@return integer collisionX
---@return integer collisionY
function WorldData:conservativeRaycast(x1, y1, x2, y2, layer, objectSize)
end

---@return number
function WorldData:getTilesWidth()
end

---@return number
function WorldData:getTilesHeight()
end

---@return number
function WorldData:getRenderedTileXMin()
end

---@return number
function WorldData:getRenderedTileYMin()
end

---@return number
function WorldData:getRenderedTileXMax()
end

---@return number
function WorldData:getRenderedTileYMax()
end
