---@diagnostic disable: missing-return
---@class IGUILanternOfArimorPanel : UIElement
IGUILanternOfArimorPanel = {}

---@return table<integer, Mod>
function IGUILanternOfArimorPanel:getMods()
end

---@return table<integer, integer>
function IGUILanternOfArimorPanel:getMinPackSizes()
end

---@return table<integer, integer>
function IGUILanternOfArimorPanel:getMaxPackSizes()
end

---@return table<integer, integer>
function IGUILanternOfArimorPanel:getPackDensities()
end

---@class UsableAllFlame
---@field ItemId integer 
---@field PlayerInventoryId integer
---@field Item Actor

---@return table<integer, UsableAllFlame>
function IGUILanternOfArimorPanel:getUsableAllFlames()
end