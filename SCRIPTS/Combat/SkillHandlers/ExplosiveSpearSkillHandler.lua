local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

local EXPLOSIVE_SPEAR_METAPATH = "Metadata/Effects/Spells/spear_mine/spear_mine"

---@class PoE2Lib.Combat.SkillHandlers.ExplosiveSpearSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.ExplosiveSpearSkillHandler
local ExplosiveSpearSkillHandler = SkillHandler:extend()

ExplosiveSpearSkillHandler.shortName = "Explosive Spear"

ExplosiveSpearSkillHandler.description = [[
    This is a handler for the Explosive Spear skill.
]]

ExplosiveSpearSkillHandler.settings = { --
    range = 60,
    radius = 30,
    -- radiusAuto = false,
    canFly = true,
}

function ExplosiveSpearSkillHandler:onPulse()
    -- if self.settings.radiusAuto then
    --     self.settings.radius = self:getStat(SkillStats.ActiveSkillAoERadius)
    -- end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function ExplosiveSpearSkillHandler:canUse(target)
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

    if self:getExistingCount() >= self:getLimit() and self:getFrenzyCharges() == 0 then
        return false, "too many existing spears"
    end

    return true, nil
end

function ExplosiveSpearSkillHandler:getLimit()
    return self:getStat(SkillStats.NumberOfRemoteSpearMinesAllowed)
end

function ExplosiveSpearSkillHandler:getExistingCount()
    local count = 0
    for _, spear in pairs(Infinity.PoE2.getActorsByMetaPath(EXPLOSIVE_SPEAR_METAPATH)) do
        if spear:getCloseAttackableEnemyCount(self.settings.radius, false, false) > 0 then
            count = count + 1
        end
    end
    return count
end

---@return integer
function ExplosiveSpearSkillHandler:getFrenzyCharges()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "frenzy_charge" then
            return buff:getCharges()
        end
    end
    return 0
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function ExplosiveSpearSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, not not self.settings.canFly
end

---@param key string
function ExplosiveSpearSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##explosive_spear_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

        -- UI.WithDisable(self.settings.radiusAuto, function()
        _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
        -- end)
        -- ImGui.SameLine()
        -- _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto Radius", "radiusAuto"), self.settings.radiusAuto)
    end)
end

return ExplosiveSpearSkillHandler
