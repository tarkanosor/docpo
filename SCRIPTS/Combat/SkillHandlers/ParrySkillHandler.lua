local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local RakeSkillHandler = require("PoE2Lib.Combat.SkillHandlers.RakeSkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.ParrySkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.ParrySkillHandler
local ParrySkillHandler = SkillHandler:extend()

ParrySkillHandler.shortName = "Parry"

ParrySkillHandler.description = [[
    This is a handler for the Parry skill.
]]

ParrySkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "parry"
end)

ParrySkillHandler.settings = { --
    animationCancelRake = true,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function ParrySkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target, { sharedAnimationExpiration = false })
    if not baseOk then
        return false, baseReason
    end

    if self.settings.animationCancelRake and not self:isUsingRake() then
        return false, "not using rake"
    end

    return true, nil
end

---@return boolean
function ParrySkillHandler:isUsingRake()
    local player = Infinity.PoE2.getLocalPlayer()
    local action = player:getCurrentAction()
    if action == nil then
        return false
    end

    local skill = action and action:getSkill()
    local gepl = skill and skill:getGrantedEffectsPerLevel()
    local ge = gepl and gepl:getGrantedEffect()
    local as = ge and ge:getActiveSkill()
    if as == nil or as:getId() ~= "rake" then
        return false
    end

    local now = Infinity.Win32.GetTickCount()
    if now < RakeSkillHandler.AnimationCancelWindowStart or now > RakeSkillHandler.AnimationCancelWindowEnd then
        return false
    end

    return true
end

function ParrySkillHandler:use(target, location)
    CastMethods.Methods.StartAction(self, target, location)
    CastMethods.Methods.StopAction(self, target, location)
    self:onUse()
end

function ParrySkillHandler:isChannelingSkill()
    return false
end

---@param key string
function ParrySkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##parry_skill_handler_%s_%s"):format(title, id, key)
    end

    UI.WithWidth(120, function()
        _, self.settings.animationCancelRake = ImGui.Checkbox(label("Animation Cancel Rake", "animation_cancel_rake"), self.settings.animationCancelRake)
    end)
end

return ParrySkillHandler
