local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local RakeSkillHandler = require("PoE2Lib.Combat.SkillHandlers.RakeSkillHandler")

local NORMAL_COMBO = (3 - 1)

---@class PoE2Lib.Combat.SkillHandlers.PrimalStrikeSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.PrimalStrikeSkillHandler
local PrimalStrikeSkillHandler = SkillHandler:extend()

PrimalStrikeSkillHandler.shortName = "Primal Strike"

PrimalStrikeSkillHandler.description = [[
    This is a handler for the Primal Strike skill.
]]

PrimalStrikeSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "primal_strike"
end)

PrimalStrikeSkillHandler.settings = { --
    range = 25,
    canFly = true,
    requireShocked = true,
    ---@type "Target" | "Any Shocked"
    mode = "Any Shocked",
}

PrimalStrikeSkillHandler.prevStrikeCombo = 0

function PrimalStrikeSkillHandler:onSkillExecute()
    local action = Infinity.PoE2.getLocalPlayer():getCurrentAction()
    if action == nil then
        return
    end

    local combo = action:getStrikeCombo()
    if combo == NORMAL_COMBO and self.prevStrikeCombo >= NORMAL_COMBO then
        self.prevStrikeCombo = self.prevStrikeCombo + 1
    else
        self.prevStrikeCombo = combo
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function PrimalStrikeSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self.settings.mode == "Any Shocked" then
        if self:isRepeatingFinalStrike() then
            return true, nil
        end

        -- Do the final strike regardless of shocked
        if not self:canRepeatFinalStrike() then
            local shocked = self:getShockedTarget()
            if shocked == nil then
                return false, "no shocked target"
            end
        end

        return true, nil
    end

    if self.settings.mode == "Target" then
        if target == nil then
            return false, "no target"
        end

        if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return false, "target out of range"
        end

        if self.settings.requireShocked and not target:hasBuff("shocked") then
            return false, "target not shocked"
        end
        return true, nil
    end

    return false, "invalid mode"
end

function PrimalStrikeSkillHandler:getComboLimit()
    return NORMAL_COMBO + self:getStat(SkillStats.RepeatLastStepOfComboAttack)
end

function PrimalStrikeSkillHandler:canRepeatFinalStrike()
    return self.prevStrikeCombo >= NORMAL_COMBO and self.prevStrikeCombo < self:getComboLimit()
end

function PrimalStrikeSkillHandler:isRepeatingFinalStrike()
    local action = Infinity.PoE2.getLocalPlayer():getCurrentAction()
    if action == nil then
        return false
    end

    if action:getSkill():getSkillIdentifier() ~= self.config.skillId then
        return false
    end

    return action:getStrikeCombo() == NORMAL_COMBO and self.prevStrikeCombo >= NORMAL_COMBO
end

---@return WorldActor?
function PrimalStrikeSkillHandler:getShockedTarget()
    for _, actor in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
        if actor:hasBuff("shocked") and self:isInRange(actor, self.settings.range, true, self.settings.canFly) then
            return actor
        end
    end
    return nil
end

function PrimalStrikeSkillHandler:use(target, location)
    if self.settings.mode == "Any Shocked" then
        if not self:canRepeatFinalStrike() and not self:isRepeatingFinalStrike() then
            local shocked = self:getShockedTarget()
            if shocked ~= nil then
                target = shocked
            end
        end
    end

    return self:super():use(target, nil)
end

---@param key string
function PrimalStrikeSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##primal_strike_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range, 1, 1000)
        _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "can_fly"), self.settings.canFly)
        self.settings.mode = UI.StringCombo("Mode", self.settings.mode, { "Target", "Any Shocked" })
        UI.WithIndent(function()
            if self.settings.mode == "Target" then
                _, self.settings.requireShocked = ImGui.Checkbox(label("Require Shocked", "require_shocked"), self.settings.requireShocked)
            end
        end)
    end)
end

return PrimalStrikeSkillHandler
