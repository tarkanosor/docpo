local UI = require("CoreLib.UI")
local FlaskStats = require("PoE2Lib.Combat.FlaskStats")
local FlaskHandler = require("PoE2Lib.Combat.FlaskHandler")

---@class PoE2Lib.Combat.FlaskHandlers.LifeFlaskHandler : PoE2Lib.Combat.FlaskHandler
---@overload fun(config: PoE2Lib.Combat.FlaskHandler.Config): PoE2Lib.Combat.FlaskHandlers.LifeFlaskHandler
local LifeFlaskHandler = FlaskHandler:extend()

LifeFlaskHandler.shortName = 'Life'

LifeFlaskHandler.description = [[
    This handler will use your life flasks when you are low on life.
]]

LifeFlaskHandler.settings = { --
    lifePercentage = 70,
    checkBuff = true,
}

LifeFlaskHandler:setCanHandle(function(flask, name, flaskType, localStats)
    return flaskType == EFlaskType_Life
end)

function LifeFlaskHandler:setup()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function LifeFlaskHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    local perc = math.min(100, self:hasEternalYouth() and Infinity.PoE2.getLocalPlayer():getEsPercentage() or Infinity.PoE2.getLocalPlayer():getHpPercentage())
    if perc > self.settings.lifePercentage then
        return false, ('life > %d%%%%'):format(self.settings.lifePercentage)
    end

    if self.settings.checkBuff and self:hasBuff('flask_effect_life') then
        local isInstant = (self:getLocalStat(FlaskStats.LocalFlaskRecoversInstantly) == 1)
        if not isInstant then
            return false, 'life flask active'
        end
    end

    return true, nil
end

function LifeFlaskHandler:hasEternalYouth()
    return self:getPlayerStat(FlaskStats.EternalYouth) > 0
end

---@param key string
function LifeFlaskHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##life_flask_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    local ey = self:hasEternalYouth()
    if ey then
        ImGui.Text("Eternal Youth detected")
        UI.Tooltip("You have the Eternal Youth passive, so this flask will use your ES instead of life.")
    end

    _, self.settings.lifePercentage = ImGui.InputInt(label((ey and "% es" or "% life"), "life_percentage"), self.settings.lifePercentage)
    UI.Tooltip("Trigger at this % of life.")

    _, self.settings.checkBuff = ImGui.Checkbox(label("Check buff", "check_buff"), self.settings.checkBuff)
    UI.Tooltip("Check if the flask buff is active before using.")

    ImGui.PopItemWidth()
end

return LifeFlaskHandler
