local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.LightningSpearSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.LightningSpearSkillHandler
local LightningSpearSkillHandler = SkillHandler:extend()

LightningSpearSkillHandler.shortName = "Lightning Spear"

LightningSpearSkillHandler.description = [[
    This is a handler for the Lightning Spear skill.
]]

LightningSpearSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "lightning_burst"
end)

LightningSpearSkillHandler.settings = { --
    range = 80,
    checkVoltaicCharge = false,
    minVoltaicCharges = 10,
    ignoreVoltaicChargesStandingStill = false,
    ignoreVoltaicChargesStandingStillDuration = 300,
}

LightningSpearSkillHandler.lastPlayerMove = 0

function LightningSpearSkillHandler:onPulse()
    if Infinity.PoE2.getLocalPlayer():isMoving() then
        self.lastPlayerMove = Infinity.Win32.GetTickCount()
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function LightningSpearSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, true) then
        return false, "target out of range"
    end

    if self.settings.checkVoltaicCharge then
        local notMovingIgnore = (self.settings.ignoreVoltaicChargesStandingStill and (Infinity.Win32.GetTickCount() - self.lastPlayerMove) > self.settings.ignoreVoltaicChargesStandingStillDuration)
        if not notMovingIgnore and self:getVoltaicCharges() < self.settings.minVoltaicCharges then
            return false, "not enough volatic charges"
        end
    end

    return true, nil
end

---@return number Range, boolean canFly
function LightningSpearSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@return integer
function LightningSpearSkillHandler:getVoltaicCharges()
    for _, buff in pairs(self:getAssociatedBuffs()) do
        if buff:getKey() == "support_static_charge" then
            return buff:getCharges()
        end
    end
    return 0
end

---@param key string
function LightningSpearSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##lightning_spear_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

        _, self.settings.checkVoltaicCharge = ImGui.Checkbox(label("When Voltaic Charges >=", "use_voltaic_charges"), self.settings.checkVoltaicCharge)
        UI.WithDisable(not self.settings.checkVoltaicCharge, function()
            ImGui.SameLine()
            _, self.settings.minVoltaicCharges = ImGui.SliderInt(label("", "min_voltaic_charges"), self.settings.minVoltaicCharges, 1, 30, "%d Charges")

            UI.WithIndent(function()
                _, self.settings.ignoreVoltaicChargesStandingStill = ImGui.Checkbox(label("Ignore when standing still for", "ignore_voltaic_charges_standing_still"), self.settings.ignoreVoltaicChargesStandingStill)
                ImGui.SameLine()
                UI.WithDisable(not self.settings.ignoreVoltaicChargesStandingStill, function()
                    _, self.settings.ignoreVoltaicChargesStandingStillDuration = ImGui.SliderInt(label("", "ignore_voltaic_charges_standing_still_duration"), self.settings.ignoreVoltaicChargesStandingStillDuration, 0, 1000, "%dms")
                end)
            end)
        end)
    end)
end

return LightningSpearSkillHandler
