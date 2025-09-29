local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.SoulOfferingSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.SoulOfferingSkillHandler
local SoulOfferingSkillHandler = SkillHandler:extend()

SoulOfferingSkillHandler.shortName = 'Soul Offering'

SoulOfferingSkillHandler.description = [[
    This is a handler for Soul Offering.
]]

SoulOfferingSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "power_offering"
end)

SoulOfferingSkillHandler.settings = { --
    range = 80,
}

---@type WorldActor?
SoulOfferingSkillHandler.lastTargetableMinionActor = nil
SoulOfferingSkillHandler.lastTargetableMinionFrame = 0

---@param target? WorldActor
---@return boolean ok, string? reason
function SoulOfferingSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if target == nil then
        return false, "no target"
    end

    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "infusion" then
            return false, "already have buff"
        end
    end

    if self:getTargetableMinion() == nil then
        return false, "no targetable minion"
    end

    return true, nil
end

---@param target? WorldActor
---@param location? Vector3
function SoulOfferingSkillHandler:use(target, location)
    local minion = self:getTargetableMinion()
    if minion ~= nil then
        self:super():use(minion, nil)
    end
end

function SoulOfferingSkillHandler:getTargetableMinion()
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastTargetableMinionFrame then
        self.lastTargetableMinionFrame = now
        self.lastTargetableMinionActor = nil
        for _, minion in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
            if self:isValidMinion(minion) then
                self.lastTargetableMinionActor = minion
                break
            end
        end
    end
    return self.lastTargetableMinionActor
end

---@param minion WorldActor
function SoulOfferingSkillHandler:isValidMinion(minion)
    if minion:getStatValue(SkillStats.BaseSkillCreatesSkeletonMinions) == 0 then
        return false
    end

    if not self:isInRange(minion, self.settings.range, true, true) then
        return false
    end

    return true
end

---@param key string
function SoulOfferingSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##soul_offering_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    ImGui.PopItemWidth()
end

return SoulOfferingSkillHandler
