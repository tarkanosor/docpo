local UI = require("CoreLib.UI")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local Vector = require("CoreLib.Vector")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

local PROJECTILE_TRAVEL_RANGE = 150
local TORNADO_SHOT_AOS = {
    "Metadata/Effects/Spells/bow_tornado_shot/tornado.ao",
}

---@class PoE2Lib.Combat.SkillHandlers.TornadoShotSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TornadoShotSkillHandler
local TornadoShotSkillHandler = SkillHandler:extend()

TornadoShotSkillHandler.shortName = "Tornado Shot"

TornadoShotSkillHandler.description = [[
    This is a skill handler for Tornado Shot. It will place a Tornado Shot if
    there isn't another one in range of the target.
]]

TornadoShotSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == 'tornado_shot'
end)

TornadoShotSkillHandler.settings = { --
    range = 80,
    useLimit = true,
    limit = 1,
    segmentCheck = true,
    segmentRadius = 10,
    targetDistance = 60,
}

---@param target WorldActor
---@return number count
function TornadoShotSkillHandler:getTornadoShotCount(target)
    local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    local extended = Vector.resizeXY(pLoc, target:getLocation(), PROJECTILE_TRAVEL_RANGE):round()
    local _, collision = CombatUtils.Raycast(pLoc, extended, true)
    if collision then
        extended = collision
    end

    local targetLocation = target:getLocation()
    local count = 0
    for _, metaPath in ipairs(TORNADO_SHOT_AOS) do
        for _, tornado in pairs(Infinity.PoE2.getActorsByAnimatedMetaPath(metaPath)) do
            local location = tornado:getLocation()
            if location:getDistanceXY(targetLocation) <= self.settings.targetDistance then
                if self.settings.segmentCheck then
                    local distance, _ = Vector.DistanceToSegment(tornado:getLocation(), pLoc, extended)
                    if distance <= self.settings.segmentRadius then
                        count = count + 1
                    end
                else
                    count = count + 1
                end
            end
        end
    end
    return count
end

---@param target? WorldActor
---@return boolean ok, string? reason
function TornadoShotSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if target == nil then
        return false, "no target"
    end

    if self.settings.useLimit then
        local count = self:getTornadoShotCount(target)
        if count >= self.settings.limit then
            return false, "limit reached"
        end
    end

    return true, nil
end

---@return number Range, boolean canFly
function TornadoShotSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@param key string
function TornadoShotSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##tornado_shot_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    UI.Tooltip("The range of Tornado Shot")

    _, self.settings.targetDistance = ImGui.InputInt(label("Target Distance", "target_distance"), self.settings.targetDistance)
    UI.Tooltip("The distance between the Tornado Shot and the target for it to be counted. By default this is set to the projectile travel distance of copied projectiles from the Tornados.")

    _, self.settings.segmentCheck = ImGui.Checkbox(label("Segment Check", "segment_check"), self.settings.segmentCheck)
    UI.Tooltip("Check wether the Tornado Shot would be hit if you shot at the target. This could be disabled for Nova-supported skills.")
    UI.WithDisableIndent(not self.settings.segmentCheck, function()
        _, self.settings.segmentRadius = ImGui.InputInt(label("Segment Radius", "segment_radius"), self.settings.segmentRadius)
        UI.Tooltip("The radius of the Tornado Shot to the segment from the player in the direction of the target. If the Tornado Shot is farther away from the segment, it will not be counted.")
    end)

    _, self.settings.useLimit = ImGui.Checkbox(label("Use Limit", "use_limit"), self.settings.useLimit)
    UI.Tooltip("Whether to stop using Tornado Shot if a certain number of active Tornados is reached.")
    UI.WithDisableIndent(not self.settings.useLimit, function()
        _, self.settings.limit = ImGui.InputInt(label("Limit", "limit"), self.settings.limit)
        UI.Tooltip("The desired number of active Tornado Shots.")
    end)

    ImGui.PopItemWidth()
end

return TornadoShotSkillHandler
