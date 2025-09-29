local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.ContagionSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.ContagionSkillHandler
local ContagionSkillHandler = SkillHandler:extend()

ContagionSkillHandler.shortName = 'Contagion'

ContagionSkillHandler.description = [[
    This is a handler for the Contagion skill.
]]

ContagionSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "contagion"
end)

ContagionSkillHandler.settings = { --
    range = 80,
    ---@type 'AnyMob'|'TargetOnly'
    useMode = 'AnyMob',
}

---@param target? WorldActor
---@return boolean ok, string? reason
function ContagionSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if target == nil then
        return false, "no target"
    end

    if self.settings.useMode == 'AnyMob' then
        -- Check all monsters in range for contagion buff
        for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            for _, buff in pairs(monster:getBuffs()) do
                if buff:getKey() == 'contagion' then
                    return false, "monster in range already has contagion"
                end
            end
        end

        -- Check all deployed objects for contagion buff
        for _, deployedObject in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
            for _, buff in pairs(deployedObject:getBuffs()) do
                if buff:getKey() == 'contagion_allied' then
                    return false, "minion already has contagion"
                end
            end
        end
    elseif self.settings.useMode == 'TargetOnly' then
        -- Check if target has contagion buff
        for _, buff in pairs(target:getBuffs()) do
            if buff:getKey() == 'contagion' then
                return false, "target already has contagion"
            end
        end
    end

    -- If we got here, no monsters in range have contagion
    -- Check if target is in range for casting
    if not self:isInRange(target, self.settings.range, true, true) then
        return false, "target out of range"
    end

    return true, nil
end

---@param key string
function ContagionSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##contagion_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    self.settings.useMode, _ = UI.StringCombo(label("Use Mode", "use_mode"), self.settings.useMode, { 'AnyMob', 'TargetOnly' }, nil, function()
        ImGui.Text("How this skill should be used:")
        ImGui.BulletText("AnyMob: Will check any monster for Contagion. Will only use Contagion if no monster has it.")
        ImGui.BulletText("TargetOnly: Will only check the target for Contagion.")
    end)
    ImGui.PopItemWidth()
end

return ContagionSkillHandler
