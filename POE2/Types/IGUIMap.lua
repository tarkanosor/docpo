---@diagnostic disable: missing-return
---@class IGUIMap : UIElement
IGUIMap = {}

-- ---@return number
-- function IGUIMap:getShiftX()
-- end

-- ---@return number
-- function IGUIMap:getShiftY()
-- end

-- ---@return number
-- function IGUIMap:getZoom()
-- end

---@return IGUIMap_SubMap
function IGUIMap:getLargeMap()
end

---@return IGUIMap_SubMap
function IGUIMap:getSmallMap()
end
