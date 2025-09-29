local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local UI = require("CoreLib.UI")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.SummonSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.SummonSkillHandler
local SummonSkillHandler = SkillHandler:extend()

SummonSkillHandler.shortName = "Summon"

SummonSkillHandler.description = [[
    This is a skill handler for Summon.
]]

SummonSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return stats:getStatValue(SkillStats.SkillCreatesMinions) > 0
        and stats:getStatValue(SkillStats.IsPersistent) == 1
end)

SummonSkillHandler.settings = {
    summonCount = 1,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function SummonSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target, { cost = false })
    if not baseOk then
        return false, baseReason
    end

    if self:countUsedWithWeapon() == self:getMaxPossibleSummons() and self:getActualCount() == self:countUsedWithWeapon() then
        return false, "already have max summons"
    end

    return true, nil
end

--- Get the actual count of the summons, which can be different from the
--- reserved count because the game is being funny.
function SummonSkillHandler:getActualCount()
    local count = 0
    for _, buff in pairs(self:getAssociatedBuffs()) do
        if buff:getKey() == "minion_reserve_buff" then
            count = count + 1
        end
    end
    return count
end

function SummonSkillHandler:getMaxPossibleSummons()
    local cost = self:getStat(SkillStats.SpiritReservation)
    local available = Infinity.PoE2.getLocalPlayer():getSpirit() + (cost * self:countUsedWithWeapon())
    return math.min(math.floor(available / cost), self.settings.summonCount)
end

function SummonSkillHandler:use(target, location)
    local count = self:getMaxPossibleSummons()
    if count == self:countUsedWithWeapon() then
        count = count - 1 -- Summon one less and then summon max again to reset the count
    end
    Infinity.PoE2.getLocalPlayer():useAuraAction(self.skillId, count)
    self:super():onUse()
end

---@param key string
function SummonSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##summon_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.summonCount = ImGui.InputInt(label("Summon Count", "summon_count"), self.settings.summonCount)
    end)
end

return SummonSkillHandler
