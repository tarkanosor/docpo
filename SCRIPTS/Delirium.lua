local Lazy = require "CoreLib.Lazy"
local Delirium = {}


local function getDeliriumSkipButton()
    local igui = Infinity.PoE2.getGameStateController():getInGameState():getInGameUI()
    local hud = igui:getInGameUIElementByType(EInGameUIElement_HUD)
    if not hud or not hud:isVisible() then
        print("ERROR: HUD not found/visible")
        return nil
    end

    local hudRight = hud:getChildByName("HUDRight")
    if not hudRight or not hudRight:isVisible() then
        print("ERROR: HUDRight not found/visible")
        return nil
    end

    local skipButtonLayout = hudRight:getChildByName("skip_button_layout")
    if not skipButtonLayout or not skipButtonLayout:isVisible() then
        print("ERROR: skip_button_layout not found/visible")
        return nil
    end

    local deliriumSkipButton = skipButtonLayout:getChildByName("delirium_skip_delay_button")
    if not deliriumSkipButton or not deliriumSkipButton:isVisible() then
        return nil
    end

    return deliriumSkipButton
end

function Delirium.IsDeliriumActive()
    return getDeliriumSkipButton() ~= nil
end

function Delirium.CanSkipDelirium()
    return getDeliriumSkipButton() ~= nil
end

local deliriumSkippedTime = 0
function Delirium.TimeSinceDeliriumSkipped()
    return Infinity.Win32.GetTickCount() - deliriumSkippedTime
end

local lastInDeliriumTime = 0
function Delirium.TimeSinceLastInDelirium()
    return Infinity.Win32.GetTickCount() - lastInDeliriumTime
end

function Delirium.SkipDelirium()
    local deliriumSkipButton = getDeliriumSkipButton()
    if not deliriumSkipButton then
        return
    end

    deliriumSkipButton:use()
    deliriumSkippedTime = Infinity.Win32.GetTickCount()
end

---@return UIElement[]
local function getRewardsUIs()
    local hud = Infinity.PoE2.getGameStateController():getInGameState():getInGameUI():getInGameUIElementByType(EInGameUIElement_HUD)
    if not hud or not hud:isVisible() then
        return {}
    end

    local hudLeft = hud:getChildByName("HUDLeft")
    if not hudLeft or not hudLeft:isVisible() then
        return {}
    end

    ---@type UIElement?
    local container = nil
    -- We take first non-named child
    for _, child in ipairs(hudLeft:getChilds()) do
        if child:getName() == "" then
            if not child:isVisible() then
                return {}
            end

            container = child:getChilds()[1]
            break
        end
    end

    if not container or not container:isVisible() then
        return {}
    end

    return container:getChilds()
end
---@return integer
function Delirium.GetRewardCount()
    local rewards = getRewardsUIs()
    local visible = 0
    for _, reward in ipairs(rewards) do
        if reward:isVisible() then
            visible = visible + 1
        end
    end

    return visible
end

---@return integer
function Delirium.GetRewardLevel()
    if Delirium.GetRewardCount() == 0 then
        return 0
    end

    local rewards = getRewardsUIs()
    if #rewards == 0 then
        return 0
    end

    local level = tonumber(rewards[1]:getChilds()[2]:getText())
    if not level then
        return 0
    end

    return level
end

local StatDeliriumFogNeverDissipates = Lazy.Cell(function()
    return Infinity.PoE2.getFileController():getStatsFile():getByKey("map_delirium_fog_never_dissipates").Id
end)

function Delirium.IsInNeverDissipatingDelirium()
    local worldAreaStats = Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getCurrentWorldStats()
    return (worldAreaStats[StatDeliriumFogNeverDissipates()] or 0) >= 1
end

local lastPulseInDelirium = false
Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnPulse", function(pulse)
    if Delirium.GetRewardCount() > 0 then
        if not lastPulseInDelirium then
            print("Detected delirium start")
        end
        lastPulseInDelirium = true
        lastInDeliriumTime = Infinity.Win32.GetTickCount()
    elseif lastPulseInDelirium then
        print("Detected delirium end")
        lastPulseInDelirium = false
    end
end)

return Delirium
