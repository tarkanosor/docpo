---@diagnostic disable: missing-return
---@class TileMetaData : Object
TileMetaData = {}

---@return number
function TileMetaData:getMaskLayerCount()
end

---@param layerIndex integer
---@return ByteBuffer
function TileMetaData:getMaskLayer(layerIndex)
end

---@param layerIndex integer
---@param cellX integer
---@param cellY integer
---@return number
function TileMetaData:getMaskLayerCellBit(layerIndex, cellX, cellY)
end
