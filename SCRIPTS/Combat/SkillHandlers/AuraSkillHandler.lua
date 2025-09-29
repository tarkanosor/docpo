local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local UI = require("CoreLib.UI")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.AuraSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.AuraSkillHandler
local AuraSkillHandler = SkillHandler:extend()

AuraSkillHandler.shortName = "Aura"

AuraSkillHandler.description = [[
    This is a skill handler for Aura.
]]

AuraSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return stats:getStatValue(SkillStats.IsBuffSkill) == 1
        and stats:getStatValue(SkillStats.IsPersistent) == 1
end)

AuraSkillHandler.settings = {}

---@param target WorldActor?
---@return boolean ok, string? reason
function AuraSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target, { cost = false })
    if not baseOk then
        return false, baseReason
    end

    if self:isAuraActive() then
        return false, "aura is already active"
    end

    return true, nil
end

function AuraSkillHandler:use(target, location)
    Infinity.PoE2.getLocalPlayer():useAuraAction(self.skillId, true)
    self:super():onUse()
end

---@param key string
function AuraSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##aura_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
    end)
end

return AuraSkillHandler
