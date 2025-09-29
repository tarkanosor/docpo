local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

local PAIN_OFFERING_SPIKE_AO = "Metadata/Monsters/OfferingSpike/PainOfferingSpike.ao"

---@class PoE2Lib.Combat.SkillHandlers.PainOfferingSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.PainOfferingSkillHandler
local PainOfferingSkillHandler = SkillHandler:extend()

PainOfferingSkillHandler.shortName = 'Pain Offering'

PainOfferingSkillHandler.description = [[
    This is a handler for Pain Offering.
]]

PainOfferingSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "pain_offering"
end)

PainOfferingSkillHandler.settings = { --
    range = 80,
    aroundTarget = false,
    radius = 60,
    radiusAuto = true,
}

---@type WorldActor?
PainOfferingSkillHandler.lastTargetableMinionActor = nil
PainOfferingSkillHandler.lastTargetableMinionFrame = 0

function PainOfferingSkillHandler:onPulse()
    if self.settings.radiusAuto then
        self.settings.radius = self:getStat(SkillStats.ActiveSkillAoERadius)
    end
end

---@param target? WorldActor
---@return boolean ok, string? reason
function PainOfferingSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    local targetLocation = target:getLocation()
    if self:hasActiveSpike(targetLocation) then
        return false, "spike already active"
    end

    if self:getTargetableMinion(targetLocation) == nil then
        return false, "no targetable minion"
    end

    return true, nil
end

---@param target? WorldActor
---@param location? Vector3
function PainOfferingSkillHandler:use(target, location)
    local minion = self:getTargetableMinion(location or (target or Infinity.PoE2.getLocalPlayer()):getLocation())
    if not minion then
        return
    end
    self:super():use(nil, minion:getLocation())
end

---@param targetLocation Vector3
function PainOfferingSkillHandler:hasActiveSpike(targetLocation)
    for _, actor in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
        if actor:getAnimatedMetaPath() == PAIN_OFFERING_SPIKE_AO and
        (not self.settings.aroundTarget or
            ((actor:getLocation():getDistanceXY(targetLocation) <= self.settings.radius) and actor:hasLineOfSightTo(targetLocation, true))) then
            return true
        end
    end
    return false
end

---@param targetLocation Vector3
function PainOfferingSkillHandler:getTargetableMinion(targetLocation)
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastTargetableMinionFrame then
        self.lastTargetableMinionFrame = now
        self.lastTargetableMinionActor = nil
        for _, minion in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
            if self:isValidMinion(minion, targetLocation) then
                self.lastTargetableMinionActor = minion
                break
            end
        end
    end
    return self.lastTargetableMinionActor
end

---@param minion WorldActor
---@param targetLocation Vector3
function PainOfferingSkillHandler:isValidMinion(minion, targetLocation)
    if minion:getStatValue(SkillStats.BaseSkillCreatesSkeletonMinions) == 0 then
        return false
    end

    if not self:isInRange(minion, self.settings.range, true, true) then
        return false
    end

    if self.settings.aroundTarget then
        if minion:getLocation():getDistanceXY(targetLocation) > self.settings.radius then
            return false
        end
        if not minion:hasLineOfSightTo(targetLocation, true) then
            return false
        end
    end

    return true
end

---@param key string
function PainOfferingSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##pain_offering_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.aroundTarget = ImGui.Checkbox(label("Around Target", "around_target"), self.settings.aroundTarget)
    UI.Tooltip("Will keep the Pain Offering spike active around the target.")
    UI.WithDisable(not self.settings.aroundTarget, function()
        UI.WithIndent(function()
            UI.WithDisable(self.settings.radiusAuto, function()
                _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
            end)
            ImGui.SameLine()
            _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto", "radius_auto"), self.settings.radiusAuto)
        end)
    end)
    ImGui.PopItemWidth()
end

return PainOfferingSkillHandler
