local InGameUI = require("PoE2Lib.Proxies.InGameUI")

---@class PoE2Lib.Panels
local Panels = {}

---@return boolean
function Panels.ClosePausingPanels()
    -- Ritual panel pauses the game
    local ritualPanel = InGameUI:getInGameUIElementByType(EInGameUIElement_Favours)
    if ritualPanel and ritualPanel:isVisible() then
        ritualPanel:changeVisibility(false)
        return true
    end

    -- World panel also pauses the game
    local worldPanel = InGameUI:getInGameUIElementByType(EInGameUIElement_World)
    if worldPanel and worldPanel:isVisible() then
        worldPanel:changeVisibility(false)
        return true
    end

    return false
end

return Panels
