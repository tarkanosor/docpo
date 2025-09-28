---@diagnostic disable: missing-return
---@class Infinity.Rendering
Infinity.Rendering = {}

---@param pos Vector3
---@return Vector2
function Infinity.Rendering.WorldToScreen(pos)
end

---@param text string
---@param pos Vector2
---@param height number
---@param color ImVec4
---@param center boolean
function Infinity.Rendering.DrawText(text, pos, height, color, center)
end

---@param from Vector2
---@param to Vector2
---@param color ImVec4
---@param thickness number
function Infinity.Rendering.DrawLine(from, to, color, thickness)
end

---@param center Vector2
---@param size number
---@param color ImVec4
---@param thickness number
---@param filled boolean
function Infinity.Rendering.DrawCircle(center, size, color, thickness, filled)
end

---@param p1 ImVec2
---@param p2 ImVec2
---@param p3 ImVec2
---@param color ImVec4
---@param thickness number
---@param filled boolean
function Infinity.Rendering.DrawTriangle(p1, p2, p3, color, thickness, filled)
end

---@param center Vector2
---@param size number
---@param color ImVec4
---@param thickness number
---@param filled boolean
function Infinity.Rendering.DrawSquare(center, size, color, thickness, filled)
end

---@param p1 ImVec2
---@param p2 ImVec2
---@param color ImVec4
---@param thickness number
---@param rounding number
---@param filled? boolean
function Infinity.Rendering.DrawRect(p1, p2, color, thickness, rounding, filled)
end

---@param p1 ImVec2
---@param p2 ImVec2
---@param p3 ImVec2
---@param p4 ImVec2
---@param color ImVec4
---@param thickness number
---@param filled boolean
function Infinity.Rendering.DrawQuad(p1, p2, p3, p4, color, thickness, filled)
end

---@param from Vector2
---@param to Vector2
---@param color ImVec4
---@param thickness number
function Infinity.Rendering.DrawWorldLine(from, to, color, thickness)
end

---@param center Vector3
---@param size number
---@param color ImVec4
---@param thickness number
---@param filled boolean
function Infinity.Rendering.DrawWorldCircle(center, size, color, thickness, filled)
end

---@param center Vector3
---@param size number
---@param color ImVec4
---@param thickness number
function Infinity.Rendering.DrawWorldSquare(center, size, color, thickness, filled)
end

---@param worldMin Vector3
---@param worldMax Vector3
---@param color ImVec4
---@param thickness number
function Infinity.Rendering.DrawWorldBox(worldMin, worldMax, color, thickness)
end

---@param points table<integer, Vector3>
---@param color ImVec4
---@param thickness number
---@param filled boolean?
function Infinity.Rendering.DrawWorldPolygon(points, color, thickness, filled)
end

---@param a Vector3
---@param b Vector3
---@param c Vector3
---@param d Vector3
---@param color ImVec4
---@param thickness number
---@param filled boolean?
function Infinity.Rendering.DrawWorldQuad(a,b,c,d, color, thickness, filled)
end

---@param a Vector3
---@param b Vector3
---@param color ImVec4
---@param thickness number
---@param filled boolean?
function Infinity.Rendering.DrawWorldRect(a, b, color, thickness, filled)
end