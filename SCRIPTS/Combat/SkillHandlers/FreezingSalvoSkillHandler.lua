local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.FreezingSalvoSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.FreezingSalvoSkillHandler
local FreezingSalvoSkillHandler = SkillHandler:extend()

FreezingSalvoSkillHandler.shortName = "Freezing Salvo"

FreezingSalvoSkillHandler.description = [[
    This is a skill handler for Freezing Salvo.
]]

FreezingSalvoSkillHandler.settings = { --
    range = 80,
    canFly = true,
    minSeals = 10,
}

FreezingSalvoSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "freezing_salvo"
end)

---@param target WorldActor?
---@return boolean ok, string? reason
function FreezingSalvoSkillHandler:canUse(target)
    if self:getSeals() < self.settings.minSeals then
        return false, "not enough seals"
    end
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

    return true, nil
end

function FreezingSalvoSkillHandler:getSeals()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "freezing_salvo_seals" and buff:getAssociatedSkillId() == self.skillId then
            return buff:getCharges()
        end
    end
    return 0
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function FreezingSalvoSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, not not self.settings.canFly
end

---@param key string
function FreezingSalvoSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##freezing_salvo_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.minSeals = ImGui.InputInt(label("Min Seals", "min_seals"), self.settings.minSeals)
    ImGui.PopItemWidth()
end

return FreezingSalvoSkillHandler
