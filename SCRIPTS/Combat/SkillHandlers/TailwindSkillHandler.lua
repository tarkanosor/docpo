local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local Vector = require("CoreLib.Vector")

---@class PoE2Lib.Combat.SkillHandlers.TailwindSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TailwindSkillHandler
local TailwindSkillHandler = SkillHandler:extend()

TailwindSkillHandler.shortName = "Tailwind"

TailwindSkillHandler.description = [[
    This skill handler will use the chosen skill to keep Tailwind active.
]]

TailwindSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return false
end)

TailwindSkillHandler.settings = { --
    stacks = 10,
    refreshDuration = 2.000,
    disableInHideout = true,
}

---@return number count
function TailwindSkillHandler:getTailwindCount()
    local count = 0
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == 'tailwind' then
            if buff:getTimeLeft() >= self.settings.refreshDuration then
                count = count + 1
            end
        end
    end
    return count
end

---@param target? WorldActor
---@return boolean ok, string? reason
function TailwindSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    local count = self:getTailwindCount()
    if count >= self.settings.stacks then
        return false, "enough stacks"
    end

    if self.settings.disableInHideout and Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getCurrentWorldArea():isHideout() then
        return false, "in hideout"
    end

    return true, nil
end

---@return number Range, boolean canFly
function TailwindSkillHandler:getCurrentMaxSkillDistance()
    return 0, true
end

---@param key string
function TailwindSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##tailwind_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.stacks = ImGui.InputInt(label("Stacks", "stacks"), self.settings.stacks)
    UI.Tooltip("The number of stacks of Tailwind to maintain.")

    _, self.settings.refreshDuration = ImGui.InputFloat(label("Refresh Duration", "refresh_duration"), self.settings.refreshDuration, 1, 2, "%.3f seconds")
    UI.Tooltip("The duration of the Tailwind stack at which to refresh the buff.")

    ImGui.PopItemWidth()
end

return TailwindSkillHandler
