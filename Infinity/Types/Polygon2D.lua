---@diagnostic disable: missing-return
---@class Polygon2D
Polygon2D = {}

---@return table<number, Vector3>
function Polygon2D:getInnerPolygonsLines()
end

---@return table<number, Vector3>
function Polygon2D:getOuterPolygonLines()
end

---@param other Polygon2D
---@return boolean
function Polygon2D:intersects(other)
end

---@param other Polygon2D
---@return boolean
function Polygon2D:mightOverlap(other)
end
