local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.OffensiveSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.OffensiveSkillHandler
local OffensiveSkillHandler = SkillHandler:extend()

OffensiveSkillHandler.shortName = "Offensive"

OffensiveSkillHandler.description = [[
    This is the default handler for offensive skills.
]]

OffensiveSkillHandler.settings = { --
    range = 60,
    corpseRadius = 20,
    corpseRange = 60,
    canFly = true,
    castOnTarget = true,
}

---@param target WorldActor?
---@return boolean ok, string? reason
function OffensiveSkillHandler:canUse(target)
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

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function OffensiveSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, not not self.settings.canFly
end

---@param target WorldActor?
---@param location? Vector3
function OffensiveSkillHandler:use(target, location)
    if not self.settings.castOnTarget then
        return self:super():use(nil, nil)
    end
    return self:super():use(target, location)
end

function OffensiveSkillHandler:getTargetableCorpsePlayerRange()
    return self.settings.range + self.settings.corpseRadius
end

function OffensiveSkillHandler:getTargetableCorpseTargetRadius()
    return self.settings.corpseRadius
end

---@param target WorldActor?
function OffensiveSkillHandler:shouldPreventMovement(target)
    if self:super():shouldPreventMovement(target) then
        return target ~= nil and self:isInRange(target, self.settings.range, true, self.settings.canFly)
    end

    return false
end

---@param key string
function OffensiveSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##offensive_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    _, self.settings.castOnTarget = ImGui.Checkbox(label("Cast on Target", "castOnTarget"), self.settings.castOnTarget)
    ImGui.PopItemWidth()
end

return OffensiveSkillHandler
