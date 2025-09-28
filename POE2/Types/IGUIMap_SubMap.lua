---@diagnostic disable: missing-return
---@class IGUIMap_SubMap : UIElement
IGUIMap_SubMap = {}

---@return Vector2
function IGUIMap_SubMap:getShift()
end

---@return Vector2
function IGUIMap_SubMap:getDefaultShift()
end

---@return number
function IGUIMap_SubMap:getZoom()
end

---@return Vector2
function IGUIMap_SubMap:getMapCenter()
end

---@return number
function IGUIMap_SubMap:getMapScale()
end

---@return boolean
function IGUIMap_SubMap:getIsLarge()
end

---@return Vector2
function IGUIMap_SubMap:gridDeltaToMapDelta()
end

---@param worldPos Vector3
---@param radius number
---@param color ImVec4
---@param thickness number
---@param filled boolean
function IGUIMap_SubMap:drawWorldCircle(worldPos, radius, color, thickness, filled)
end

---@param worldPos Vector3
---@param halfDiameter number
---@param color ImVec4
---@param thickness number
---@param filled boolean
function IGUIMap_SubMap:drawWorldRectangle(worldPos, halfDiameter, color, thickness, filled)
end

---@param worldStart Vector3
---@param worldEnd Vector3
---@param color ImVec4
---@param thickness number
function IGUIMap_SubMap:drawWorldLine(worldStart, worldEnd, color, thickness)
end

---@param worldPos Vector3
---@param text string
---@param color ImVec4
---@param size number
function IGUIMap_SubMap:drawWorldText(worldPos, text, color, size)
end
