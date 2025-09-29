local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.ChargedStaffSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.ChargedStaffSkillHandler
local ChargedStaffSkillHandler = SkillHandler:extend()

ChargedStaffSkillHandler.shortName = "Charged Staff"

ChargedStaffSkillHandler.description = [[
    This is a handler for debugging and has no additional logic. It will try to
    spam the skill solely on the base SkillHandler conditions.
]]

ChargedStaffSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "charged_staff"
end)

ChargedStaffSkillHandler.settings = { --
    minPowerCharges = 3,
    maxStack = 3,
    refreshAtSeconds = 2,
    refreshBeforePowerChargesExpireSeconds = 2,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function ChargedStaffSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    local powerCharges = self:getPowerCharges()
    if powerCharges == nil then
        return false, "no power charges"
    end

    if self.settings.refreshBeforePowerChargesExpireSeconds > powerCharges:getTimeLeft() then
        return true, "power charges will expire"
    end

    if powerCharges:getCharges() < self.settings.minPowerCharges then
        return false, "not enough power charges"
    end

    local buff = self:getBuff()
    if buff then
        if buff:getCharges() >= self.settings.maxStack and buff:getTimeLeft() > self.settings.refreshAtSeconds then
            return false, "no need to buff"
        end
    end

    return true, nil
end

---@return Buff?
function ChargedStaffSkillHandler:getPowerCharges()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "power_charge" then
            return buff
        end
    end
    return nil
end

---@return Buff?
function ChargedStaffSkillHandler:getBuff()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "charged_staff_stack" then
            return buff
        end
    end
    return nil
end

---@param target WorldActor?
---@param location? Vector3
function ChargedStaffSkillHandler:use(target, location)
    return self:super():use(nil, nil)
end

---@param key string
function ChargedStaffSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##charged_staff_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.minPowerCharges = ImGui.InputInt(label("Min Power Charges", "min_power_charges"), self.settings.minPowerCharges)
    _, self.settings.maxStack = ImGui.InputInt(label("Max Stack", "max_stack"), self.settings.maxStack)
    _, self.settings.refreshAtSeconds = ImGui.InputFloat(label("Refresh At Seconds", "refresh_at_seconds"), self.settings.refreshAtSeconds)
    _, self.settings.refreshBeforePowerChargesExpireSeconds = ImGui.InputFloat(label("Refresh Before Power Charges Expire Seconds", "refresh_before_power_charges_expire_seconds"), self.settings.refreshBeforePowerChargesExpireSeconds)
    ImGui.PopItemWidth()
end

return ChargedStaffSkillHandler
