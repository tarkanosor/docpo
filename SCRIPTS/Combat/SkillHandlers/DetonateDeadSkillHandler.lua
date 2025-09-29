local UI = require("CoreLib.UI")
local Render = require("CoreLib.Render")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.DetonateDeadSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.DetonateDeadSkillHandler
---@diagnostic disable-next-line: assign-type-mismatch
local DetonateDeadSkillHandler = SkillHandler:extend()

DetonateDeadSkillHandler.shortName = "Detonate Dead"

DetonateDeadSkillHandler.description = [[
    This is a skill handler for Detonate Dead. NOTE: Target conditions do not
    function properly, because this handler uses its own targeting logic.
]]

DetonateDeadSkillHandler:setCanHandle(function(skill, stats, name, _, _, activeSkill, asid)
    return asid == 'detonate_dead'
end)

DetonateDeadSkillHandler.settings = { --
    range = 80,
    corpseRadius = 25,
    corpseRadiusAuto = true,
    ---@type 'OptimalClear'|'FastClear'|'Target'
    targetMode = 'OptimalClear',
    preferCorpsesOverMinions = true,
    onlyContagionCorpses = false,
    drawCorpses = false,
}

---@type Actor[]
DetonateDeadSkillHandler.lastGetCorpses = {}
---@type integer
DetonateDeadSkillHandler.lastGetCorpsesTick = 0

function DetonateDeadSkillHandler:onPulse()
    if self.settings.corpseRadiusAuto then
        self.settings.corpseRadius = self:getStat(SkillStats.ActiveSkillAoERadius)
    end
end

---@param target? WorldActor
---@return boolean ok, string? reason
function DetonateDeadSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    return true, nil
end

---@param target? WorldActor
---@param location? Vector3
---@return Actor?
function DetonateDeadSkillHandler:getTargetableCorpseUncached(target, location)
    location = location or (target and target:getLocation()) or Infinity.PoE2.getLocalPlayer():getLocation()

    if self.settings.targetMode == 'FastClear' then
        local unpreferred = nil
        for _, corpse in pairs(self:getCorpses()) do
            for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
                if corpse:getLocation():getDistanceXY(monster:getLocation()) <= self.settings.corpseRadius then
                    if self:isPreferredCorpse(corpse) then
                        return corpse
                    elseif unpreferred == nil then
                        unpreferred = corpse
                    end
                end
            end
        end
        return unpreferred
    elseif self.settings.targetMode == 'OptimalClear' then
        local bestCorpse, bestDamage, bestPreferred = nil, 0, false
        for _, corpse in pairs(self:getCorpses()) do
            local targets = 0
            for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
                if corpse:getLocation():getDistanceXY(monster:getLocation()) <= self.settings.corpseRadius then
                    targets = targets + 1
                end
            end

            local damage = targets * corpse:getMaxHp()
            local preferred = self:isPreferredCorpse(corpse)
            if damage > bestDamage or (preferred and not bestPreferred and damage > 0) then
                bestCorpse, bestDamage, bestPreferred = corpse, damage, preferred
            end
        end
        return bestCorpse
    elseif self.settings.targetMode == 'Target' then
        local unpreferred = nil
        for _, corpse in pairs(self:getCorpses()) do
            local corpseLoc = corpse:getLocation()
            if location:getDistanceXY(corpseLoc) <= self.settings.corpseRadius then
                if self:isPreferredCorpse(corpse) then
                    return corpse
                elseif unpreferred == nil then
                    unpreferred = corpse
                end
            end
        end
        return unpreferred
    end
    return nil
end

---@return WorldActor[]
function DetonateDeadSkillHandler:getCorpses()
    local corpses = {}
    local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    for _, corpse in pairs(Infinity.PoE2.getUseableCorpses()) do
        if  corpse:getDistanceToPlayer() <= self.settings.range --
        and corpse:hasLineOfSightTo(pLoc, true)                 --
        and (not self.settings.onlyContagionCorpses or corpse:hasBuff("contagion")) then
            table.insert(corpses, corpse)
        end
    end
    return corpses
end

---@param corpse WorldActor
function DetonateDeadSkillHandler:isPreferredCorpse(corpse)
    if self.settings.preferCorpsesOverMinions then
        if not corpse:isHostile() then
            return false
        end
    end
    return true
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function DetonateDeadSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@param key string
function DetonateDeadSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##detonate_dead_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

    UI.WithDisable(self.settings.corpseRadiusAuto, function()
        _, self.settings.corpseRadius = ImGui.InputInt(label("Corpse Radius", "corpse_radius"), self.settings.corpseRadius)
        UI.Tooltip("The radius around the corpses to check for targets. This should be the radius of your Detonate Dead skill. (1 meters = 10 range)")
    end)
    ImGui.SameLine()
    _, self.settings.corpseRadiusAuto = ImGui.Checkbox(label("Auto", "corpse_radius_auto"), self.settings.corpseRadiusAuto)
    UI.Tooltip("Automatically set the corpse radius to the radius of your Detonate Dead skill.")

    if UI.WithTooltip(ImGui.BeginCombo(label("Target Mode", "target_mode"), self.settings.targetMode), function()
        ImGui.BulletText("Fast: Target the first corpse that has an attackable monster in range.")
        ImGui.BulletText("OptimalClear: Target the corpse that will do the most damage (targets * corpse life).")
        ImGui.BulletText("Target: Use corpses in range of the target.")
    end) then
        for _, mode in ipairs({ 'OptimalClear', 'FastClear', 'Target' }) do
            if ImGui.Selectable(mode, self.settings.targetMode == mode) then
                self.settings.targetMode = mode
            end
        end
        ImGui.EndCombo()
    end

    _, self.settings.preferCorpsesOverMinions = ImGui.Checkbox(label("Prefer Corpses Over Minions", "prefer_corpses_over_minions"), self.settings.preferCorpsesOverMinions)
    _, self.settings.onlyContagionCorpses = ImGui.Checkbox(label("Only Contagion Corpses", "only_contagion_corpses"), self.settings.onlyContagionCorpses)
    _, self.settings.drawCorpses = ImGui.Checkbox(label("Draw Corpses", "draw_corpses"), self.settings.drawCorpses)

    ImGui.PopItemWidth()
end

function DetonateDeadSkillHandler:onRenderD2D()
    if self.settings.drawCorpses then
        for _, corpse in pairs(self:getCorpses()) do
            local color = "55FF0000"
            if self.lastTargetableCorpseActor == corpse then
                color = "55FFFF00"
            end

            Render.DrawWorldCircle(corpse:getWorld(), self.settings.corpseRadius * 10.87, color, 4)
            Render.DrawWorldText(tostring(corpse:getMaxHp()), 20, "AAFF0000", corpse:getWorld(), 0, 0)
        end
    end
end

return DetonateDeadSkillHandler
