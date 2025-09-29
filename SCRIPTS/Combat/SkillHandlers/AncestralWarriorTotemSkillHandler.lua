local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local UI = require("CoreLib.UI")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

---@class PoE2Lib.Combat.SkillHandlers.AncestralWarriorTotemSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.AncestralWarriorTotemSkillHandler
local AncestralWarriorTotemSkillHandler = SkillHandler:extend()

AncestralWarriorTotemSkillHandler.shortName = "Ancestral Warrior Totem"

AncestralWarriorTotemSkillHandler.description = [[
    This is a skill handler for Ancestral Warrior Totem.
]]

AncestralWarriorTotemSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "summon_meta_totem_slams"
end)

AncestralWarriorTotemSkillHandler.settings = { --
    range = 60,
    radius = 60,
    radiusAuto = true,
    count = 1,
}

AncestralWarriorTotemSkillHandler.lastUsing = 0

function AncestralWarriorTotemSkillHandler:onPulse()
    if self.settings.radiusAuto then
        self.settings.radius = self:getStat(SkillStats.TotemRange)
    end

    if CombatUtils.GetCurrentActionId() == self.skillId then
        self.lastUsing = Infinity.Win32.GetTickCount()
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function AncestralWarriorTotemSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, true) then
        return false, "target is out of range"
    end

    if self:countAncestralWarriorTotemTotems(target) >= self.settings.count then
        return false, "enough totems"
    end

    -- Check if we are currently using the skill to avoid double casting, which
    -- will then revent the totem from appearing
    if Infinity.Win32.GetTickCount() - self.lastUsing < 100 then
        return false, "preventing double cast"
    end

    return true, nil
end

---@param target WorldActor
---@return integer
function AncestralWarriorTotemSkillHandler:countAncestralWarriorTotemTotems(target)
    local tLoc = target:getLocation()
    local count = 0
    for _, actor in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
        if actor:getAnimatedMetaPath() == "Metadata/Monsters/Totems/ancestor_totem/AncestorFour.ao" then
            if actor:getLocation():getDistanceXY(tLoc) <= self.settings.radius and actor:hasLineOfSightTo(tLoc, true) then
                count = count + 1
            end
        end
    end
    return count
end

---@param key string
function AncestralWarriorTotemSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##ancestral_warrior_totem_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

        UI.WithDisable(self.settings.radiusAuto, function()
            _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
        end)
        ImGui.SameLine()
        _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto", "auto_radius"), self.settings.radiusAuto)

        _, self.settings.count = ImGui.InputInt(label("Count", "count"), self.settings.count)
    end)
end

return AncestralWarriorTotemSkillHandler
