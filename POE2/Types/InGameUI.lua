---@diagnostic disable: missing-return
---@class InGameUI : UIElement
InGameUI = {}

---@param type number EInGameUIElement
---@return UIElement?
function InGameUI:getInGameUIElementByType(type)
end


-- ---@return QuestManager
-- function InGameUI:getQuestManager()
-- end

-- ---@return IGUIGroundLabelPanel
-- function InGameUI:getGroundLabelPanel()
-- end

-- ---@return IGUIMapDevicePanel
-- function InGameUI:getMapDevicePanel()
-- end

-- ---@return IGUIHudPanel
-- function InGameUI:getHudPanel()
-- end

-- ---@return IGUISkillBar
-- function InGameUI:getSkillBar()
-- end

-- ---@return IGUINPCDialog
-- function InGameUI:getNPCDialog()
-- end

-- ---@return IGUIPartyHUD
-- function InGameUI:getPartyHUD()
-- end

-- ---@return IGUIBanditPanel
-- function InGameUI:getBanditPanel()
-- end

-- ---@return IGUILanternOfArimorPanel
-- function InGameUI:getLanternOfArimorPanel()
-- end

-- ---@return IGUIFlaskBar
-- function InGameUI:getFlaskBar()
-- end

-- ---@return IGUICurrencyExchange
-- function InGameUI:getCurrencyExchange()
-- end

---@return IGUIMap
function InGameUI:getMap()
end

---@return table<number, UIElement>
function InGameUI:getChilds()
end
