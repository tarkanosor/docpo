---@diagnostic disable: missing-return
---@class UIElement : Object
UIElement = {}

function UIElement:use()
end

---@param visible boolean
function UIElement:changeVisibility(visible)
end

---@param text string
function UIElement:setText(text)
end

---@return string
function UIElement:getText()
end

---@return boolean
function UIElement:isValid()
end

---@return number
function UIElement:getFlags()
end

---@return boolean
function UIElement:isVisible()
end

---@return boolean
function UIElement:isDisabled()
end

---@return boolean
function UIElement:isHighlightKeyPressed()
end

---@return boolean
function UIElement:hasChilds()
end

---@return number
function UIElement:getChildsCount()
end

---@return string
function UIElement:getName()
end

---@return integer type EUIElementType
function UIElement:getUIElementType()
end

---@return string
function UIElement:getUIElementTypeS()
end

---@return string
function UIElement:getTexture()
end

---@return string
function UIElement:getBGImage()
end

---@return Vector2
function UIElement:getRelPos()
end

---@return Vector2
function UIElement:getAbsPos()
end

---@return Vector2
function UIElement:getSize()
end

---@return number
function UIElement:getScale()
end

---@return Vector2
function UIElement:getScaledRelPos()
end

---@return Vector2
function UIElement:getScaledAbsPos()
end

---@return Vector2
function UIElement:getScaledSize()
end

---@return UIElement
function UIElement:getRoot()
end

---@return UIElement
function UIElement:getParent()
end

---@return table<number, UIElement>
function UIElement:getChilds()
end

---@param name string 
---@return UIElement?
function UIElement:getChildByName(name)
end

---@return integer
function UIElement:getColor()
end

---@return boolean
function UIElement:isEnabled()
end

---@return RECT
function UIElement:getRect()
end
