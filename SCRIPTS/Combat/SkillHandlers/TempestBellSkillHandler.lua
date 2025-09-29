local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.TempestBellSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TempestBellSkillHandler
local TempestBellSkillHandler = SkillHandler:extend()

TempestBellSkillHandler.shortName = "Tempest Bell"

TempestBellSkillHandler.description = [[
    This is a skill handler for Tempest Bell.
]]

TempestBellSkillHandler.settings = { --
    range = 30,
    canFly = false,
    ignoreActiveBellCount = true,
}

TempestBellSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "tempest_bell"
end)

---@param target WorldActor?
---@return boolean ok, string? reason
function TempestBellSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return false, "target out of range"
    end

    if self:getActiveBellCount() >= self:getBellLimit() then
        return false, "too many active bells"
    end

    return true, nil
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function TempestBellSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly ~= false
end

function TempestBellSkillHandler:getActiveBellCount()
    local count = 0
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "tempest_bell_active" and buff:getAssociatedSkillId() == self.skillId then
            count = count + buff:getCharges()
        end
    end
    return count
end

---@return integer
function TempestBellSkillHandler:getBellLimit()
    return self:getStat(SkillStats.NumberOfTempestBellAllowed)
end

---@param key string
function TempestBellSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##tempest_bell_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "can_fly"), self.settings.canFly)
    _, self.settings.ignoreActiveBellCount = ImGui.Checkbox(label("Ignore Active Bell Count", "ignore_active_bell_count"), self.settings.ignoreActiveBellCount)
    UI.Tooltip("If checked, it will ignore the active bell count. It will replace the active bells with new bells.")
    ImGui.PopItemWidth()
end

return TempestBellSkillHandler
