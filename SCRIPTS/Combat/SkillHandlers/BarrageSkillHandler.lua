local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local UI = require("CoreLib.UI")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.BarrageSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.BarrageSkillHandler
local BarrageSkillHandler = SkillHandler:extend()

BarrageSkillHandler.shortName = "Barrage"

BarrageSkillHandler.description = [[
    This is a skill handler for Barrage.
]]

BarrageSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "empower_barrage"
end)

BarrageSkillHandler.settings = { --
    requireTarget = true,
    minTargetRarity = ERarity_Rare,
    requireFrenzyCharges = true,
    minFrenzyCharges = 3,
    -- minFrenzyChargesAuto = true,
}

function BarrageSkillHandler:onPulse()
    -- if self.settings.minFrenzyChargesAuto then
    --     self.settings.frenzyChargeCount = self:getPlayerStat(SkillStats.MaxFrenzyCharges)
    -- end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function BarrageSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if Infinity.PoE2.getLocalPlayer():hasBuff("empower_barrage_visual") then
        return false, "already have buff"
    end

    if self.settings.requireTarget then
        if target == nil then
            return false, "no target"
        end

        if target:getRarity() < self.settings.minTargetRarity then
            return false, "target rarity too low"
        end
    end

    if self.settings.requireFrenzyCharges and not self:hasFrenzyCharges() then
        return false, "not enough frenzy charges"
    end

    if Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getCurrentWorldArea():isHideout() then
        return false, "in hideout"
    end

    return true, nil
end

function BarrageSkillHandler:hasFrenzyCharges()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "frenzy_charge" and buff:getCharges() >= self.settings.minFrenzyCharges then
            return true
        end
    end
    return false
end

function BarrageSkillHandler:use(target, location)
    return self:super():use(nil, nil)
end

---@param key string
function BarrageSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##barrage_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.requireTarget = ImGui.Checkbox(label("Require Target", "require_target"), self.settings.requireTarget)
        UI.WithDisableIndent(not self.settings.requireTarget, function()
            self.settings.minTargetRarity = UI.EnumCombo(label("Min Target Rarity", "min_target_rarity"), self.settings.minTargetRarity, Infinity.PoE2.Enums.ERarity)
        end)

        _, self.settings.requireFrenzyCharges = ImGui.Checkbox(label("Require Frenzy Charges >=", "require_frenzy_charges"), self.settings.requireFrenzyCharges)
        UI.WithDisable(not self.settings.requireFrenzyCharges, function()
            ImGui.SameLine(0, 4)
            _, self.settings.minFrenzyCharges = ImGui.InputInt(label("", "min_frenzy_charges"), self.settings.minFrenzyCharges)
            -- ImGui.SameLine(0, 4)
            -- _, self.settings.minFrenzyChargesAuto = ImGui.Checkbox(label("Auto", "min_frenzy_charges_auto"), self.settings.minFrenzyChargesAuto)
        end)
    end)
end

return BarrageSkillHandler
