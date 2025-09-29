local UI = require("CoreLib.UI")
local FlaskStats = require("PoE2Lib.Combat.FlaskStats")
local FlaskHandler = require("PoE2Lib.Combat.FlaskHandler")

---@class PoE2Lib.Combat.FlaskHandlers.ManaFlaskHandler : PoE2Lib.Combat.FlaskHandler
---@overload fun(config: PoE2Lib.Combat.FlaskHandler.Config): PoE2Lib.Combat.FlaskHandlers.ManaFlaskHandler
local ManaFlaskHandler = FlaskHandler:extend()

ManaFlaskHandler.shortName = 'Mana'

ManaFlaskHandler.description = [[
    This handler will use your mana flasks when you are low on mana.
]]

ManaFlaskHandler.settings = { --
    manaPercentage = 50,
    checkBuff = true,
}

ManaFlaskHandler:setCanHandle(function(flask, name, flaskType, localStats)
    return flaskType == EFlaskType_Mana
end)

function ManaFlaskHandler:setup()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function ManaFlaskHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if Infinity.PoE2.getLocalPlayer():getMpPercentage() > self.settings.manaPercentage then
        return false, ('mana > %d%%%%'):format(self.settings.manaPercentage)
    end

    if self.settings.checkBuff and self:hasBuff('flask_effect_mana') then
        local isInstant = (self:getLocalStat(FlaskStats.LocalFlaskRecoversInstantly) == 1)
        if not isInstant then
            return false, 'mana flask active'
        end
    end

    return true, nil
end

---@param key string
function ManaFlaskHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##mana_flask_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.manaPercentage = ImGui.InputInt(label("% mana", "mana_percentage"), self.settings.manaPercentage)
    UI.Tooltip("Trigger at this % of mana.")

    _, self.settings.checkBuff = ImGui.Checkbox(label("Check buff", "check_buff"), self.settings.checkBuff)
    UI.Tooltip("Check if the flask buff is active before using.")

    ImGui.PopItemWidth()
end

return ManaFlaskHandler
