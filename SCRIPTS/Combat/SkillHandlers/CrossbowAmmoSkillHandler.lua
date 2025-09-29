local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@class PoE2Lib.Combat.SkillHandlers.CrossbowAmmoSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.CrossbowAmmoSkillHandler
local CrossbowAmmoSkillHandler = SkillHandler:extend()

CrossbowAmmoSkillHandler.shortName = 'Crossbow Ammo'

CrossbowAmmoSkillHandler.description = [[
    This is a handler for Crossbow Ammo skills. The correct ammo will be loaded
    by the Crossbow skill handler. The Crossbow Ammo skills should only be used
    for advanced usage!
]]

CrossbowAmmoSkillHandler:setCanHandle(function(skill, stats, name, _, _, _)
    return stats:hasStat(SkillStats.IsCrossbowAmmoSkill)
end)

CrossbowAmmoSkillHandler.settings = { --
    forceLoad = false,
    reloadMaxWhenNoTarget = true,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function CrossbowAmmoSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self.settings.forceLoad then
        if not self:isAmmoLoaded() then
            return true, "ammo not loaded"
        end
    end

    if self.settings.reloadMaxWhenNoTarget and target == nil then
        local crossbowSkillWrapper = self:getCrossbowSkillWrapper()
        if crossbowSkillWrapper == nil then
            return false, "crossbow skill wrapper not found"
        end
        if crossbowSkillWrapper:getCurrentAmmo() < crossbowSkillWrapper:getMaxAmmo() then
            return true, "reloading to max"
        end
    end

    return false, nil
end

---@return CrossbowSkillWrapper?
function CrossbowAmmoSkillHandler:getCrossbowSkillWrapper()
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    for _, crossbowSkillWrapper in ipairs(lPlayer:getCrossbowSkillWrappers()) do
        if crossbowSkillWrapper:getReloadSkill():getSkillIdentifier() == self.skillId then
            return crossbowSkillWrapper
        end
    end
    return nil
end

---@return boolean
function CrossbowAmmoSkillHandler:isAmmoLoaded()
    local crossbowSkillWrapper = self:getCrossbowSkillWrapper()
    if crossbowSkillWrapper == nil then
        return false
    end

    for weaponSlot, crossbowSkill in ipairs(Infinity.PoE2.getLocalPlayer():getLoadedCrossbowSkills()) do
        if crossbowSkill:getSkillIdentifier() == crossbowSkillWrapper.SkillId then
            return true
        end
    end

    return false
end

---@param key string
function CrossbowAmmoSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##crossbow_ammo_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.forceLoad = ImGui.Checkbox(label("Force Load", self.skillId), self.settings.forceLoad)
    UI.Tooltip("If enabled, this handler will always force load the ammo for the skill.")

    _, self.settings.reloadMaxWhenNoTarget = ImGui.Checkbox(label("Reload Max When No Target", self.skillId), self.settings.reloadMaxWhenNoTarget)
    UI.Tooltip("If enabled, this handler will reload the ammo to the max when there is no target.")
    ImGui.PopItemWidth()
end

return CrossbowAmmoSkillHandler
