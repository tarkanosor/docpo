---@diagnostic disable: missing-return
---@class IGUIMapDevicePanel : UIElement
IGUIMapDevicePanel = {}

---@return table<number, CraftingBenchOption>
function IGUIMapDevicePanel:getCraftingOptions()
end

---@return table<number, MavenElement>
function IGUIMapDevicePanel:getSpecialElements()
end

---@return boolean
function IGUIMapDevicePanel:is5SlotDevice()
end

---@return boolean
function IGUIMapDevicePanel:is6SlotDevice()
end
