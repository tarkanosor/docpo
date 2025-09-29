local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local CrossbowAmmoSkillHandler = require("PoE2Lib.Combat.SkillHandlers.CrossbowAmmoSkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.CrossbowSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.CrossbowSkillHandler
local CrossbowSkillHandler = SkillHandler:extend()

CrossbowSkillHandler.shortName = "Crossbow"

CrossbowSkillHandler.description = [[
    This is a handler for crossbow skills. It will automatically load the
    correct ammo to use the skill and fire it.
]]

CrossbowSkillHandler:setCanHandle(function(skill, stats, name, _, _, _)
    return stats:hasStat(SkillStats.IsCrossbowSkill)
end)

CrossbowSkillHandler.settings = { --
    range = 60,
    canFly = true,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function CrossbowSkillHandler:canUse(target)
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

---@return CrossbowSkillWrapper?
function CrossbowSkillHandler:getCrossbowSkillWrapper()
    return Infinity.PoE2.getLocalPlayer():getCrossbowSkillWrapperBySkillId(self.skillId)
end

function CrossbowSkillHandler:isAmmoLoaded()
    for weaponSlot, crossbowSkill in ipairs(Infinity.PoE2.getLocalPlayer():getLoadedCrossbowSkills()) do
        if crossbowSkill and crossbowSkill:getSkillIdentifier() == self.skillId then
            return true
        end
    end
    return false
end

---@param target WorldActor?
---@param location Vector3?
function CrossbowSkillHandler:use(target, location)
    if not self:isAmmoLoaded() then
        CrossbowAmmoSkillHandler:Simple(self:getCrossbowSkillWrapper():getReloadSkill():getSkillIdentifier()):use()
        return
    end
    self:super():use(target, location)
end

---@param target WorldActor?
function CrossbowSkillHandler:shouldPreventMovement(target)
    if target == nil then
        return false
    end

    if self:isChannelingSkill() and Infinity.PoE2.getGlobalUIManager():isInputMethod(EInputMode_KeyboardMouse) then
        if self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return self:isCurrentAction()
        end
    end

    return false
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function CrossbowSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly ~= false
end

---@param key string
function CrossbowSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##crossbow_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    ImGui.PopItemWidth()
end

return CrossbowSkillHandler
