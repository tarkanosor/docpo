local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local UI = require("CoreLib.UI")

---@class PoE2Lib.Combat.SkillHandlers.SnipersMarkSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.SnipersMarkSkillHandler
local SnipersMarkSkillHandler = SkillHandler:extend()

SnipersMarkSkillHandler.shortName = "Sniper's Mark"

SnipersMarkSkillHandler.description = [[
    This is a skill handler for Sniper's Mark.
]]

SnipersMarkSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "snipers_mark"
end)

SnipersMarkSkillHandler.settings = { --
    range = 80,
    minRarity = ERarity_Rare,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function SnipersMarkSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if target:hasBuff("snipers_mark") then
        return false, "target already marked"
    end

    if not self:isInRange(target, self.settings.range, true, true) then
        return false, "target out of range"
    end

    if target:getRarity() < self.settings.minRarity then
        return false, "target rarity too low"
    end

    return true, nil
end

---@param key string
function SnipersMarkSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##snipers_mark_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
        self.settings.minRarity = UI.EnumCombo(label("Min Rarity", "min_rarity"), self.settings.minRarity, Infinity.PoE2.Enums.ERarity)
    end)
end

return SnipersMarkSkillHandler
