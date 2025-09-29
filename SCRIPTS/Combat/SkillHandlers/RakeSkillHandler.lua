local Vector = require("CoreLib.Vector")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")
local UI = require("CoreLib.UI")
local Math = require("CoreLib.Math")

local MAX_WAYPOINT_DISTANCE = 100
local PLAYER_SIZE = 3
local MAX_OBSTRUCTION_DISTANCE = 5

---@class PoE2Lib.Combat.SkillHandlers.RakeSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.RakeSkillHandler
local RakeSkillHandler = SkillHandler:extend()

RakeSkillHandler.shortName = "Rake"

RakeSkillHandler.description = [[
    This is a skill handler for Rake.
]]

---@class PoE2Lib.Combat.SkillHandlers.RakeSkillHandler.Settings
RakeSkillHandler.settings = { --
    range = 50,
    canFly = false,
    useAsAttack = true,
    useAsTravelSkill = false,
    lenientWaypointLoS = false,
    stuckTimer = 300,
    animationCancelFraction = 0.30,
}

RakeSkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "rake"
end)

---@type "attack"|"travel"
RakeSkillHandler.lastUseType = "attack"

---@type Vector3
RakeSkillHandler.lastLocation = Vector3(0, 0, 0)
---@type number
RakeSkillHandler.lastLocationChange = 0

RakeSkillHandler.AnimationCancelWindowStart = 0
RakeSkillHandler.AnimationCancelWindowEnd = 0

function RakeSkillHandler:onPulse()
    local location = Infinity.PoE2.getLocalPlayer():getLocation()
    if location:getDistanceXY(self.lastLocation) > 5 then
        -- print(("Location changed, delta: %.1fms"):format(Infinity.Win32.GetTickCount() - self.lastLocationChange))
        self.lastLocation = location
        self.lastLocationChange = Infinity.Win32.GetTickCount()
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function RakeSkillHandler:canUse(target)
    if not self.settings.useAsAttack then
        return false, "not using as attack"
    end

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

function RakeSkillHandler:getActionFlag()
    return 0x0400
end

---@param target WorldActor?
---@param location Vector3?
function RakeSkillHandler:use(target, location)
    self.lastUseType = "attack"
    return self:super():use(target, location)
end

function RakeSkillHandler:onUse()
    self:super():onUse()
end

function RakeSkillHandler:onSkillExecute()
    self:super():onSkillExecute()
    local animation = self:calculateAnimationDuration()
    local now = Infinity.Win32.GetTickCount()
    local windowStart = now + (self.settings.animationCancelFraction * animation)
    local windowEnd = now + animation
    RakeSkillHandler.AnimationCancelWindowStart = math.max(RakeSkillHandler.AnimationCancelWindowStart, windowStart)
    RakeSkillHandler.AnimationCancelWindowEnd = math.max(RakeSkillHandler.AnimationCancelWindowEnd, windowEnd)
end

---@param target WorldActor?
function RakeSkillHandler:updateTarget(target)
    if self.settings.useAsTravelSkill then
        return
    end

    if self.settings.useAsAttack then
        if target and self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            self:super():updateTarget(target)
        else
            self:super():updateTarget(nil)
        end
    end
end

---@param target WorldActor?
---@return boolean
function RakeSkillHandler:shouldPreventMovement(target)
    if self.settings.useAsTravelSkill then
        return false
    end
    if target == nil or not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return false
    end
    return self:super():shouldPreventMovement(target)
end

---@return boolean
function RakeSkillHandler:needsPathfinding()
    return self.settings.useAsTravelSkill
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
---@return boolean
function RakeSkillHandler:travel(destination, locations, costs)
    if not self.settings.useAsTravelSkill then
        return false
    end

    -- If we have been standing still for a second, then we might be stuck
    local now = Infinity.Win32.GetTickCount()
    if now - self.lastLocationChange > self.settings.stuckTimer and self.lastExecuteTick > self.lastLocationChange then
        return false
    end

    local nextLoc = self:getNextLocation(destination, locations)
    if not nextLoc then
        return false
    end

    local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    if pLoc:getDistanceXY(nextLoc) > 50 then
        nextLoc = Vector.resizeXY(pLoc, nextLoc, 50) --[[@as Vector3]]
    end

    if self:isCurrentAction() then
        self:updateActionLocation(nil, nextLoc)
        return true
    end

    if self:baseCanUse(nil) then
        CastMethods.Methods.StartAction(self, nil, nextLoc)
        self:onUse()
        self.lastUseType = "travel"
        return true
    end

    return false
end

function RakeSkillHandler:stopAttacking()
    if self.lastUseType == "attack" and self.thisActionInitiatedByThis then
        self:super():stopAttacking()
    end
end

function RakeSkillHandler:stopTravel()
    if self.settings.useAsTravelSkill and self:isCurrentAction() and self.lastUseType == "travel" and self.thisActionInitiatedByThis then
        self:stopAction()
    end
end

---@param destination Vector3
---@param locations Vector3[]
---@return Vector3?
function RakeSkillHandler:getNextLocation(destination, locations)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()

    if not self:isObstructed(destination) then
        return destination
    end

    for i = #locations, 1, -1 do
        local wp = locations[i]
        local distance = wp:getDistanceXY(pLoc)
        if distance >= 1 and distance <= MAX_WAYPOINT_DISTANCE then
            if not self:isObstructed(wp) then
                return wp
            end
        end
    end

    local first = locations[1]
    if first and first:getDistanceXY(pLoc) > MAX_WAYPOINT_DISTANCE then
        local shortened = Vector.round(Vector.resizeXY(pLoc, first, MAX_WAYPOINT_DISTANCE)) --[[@as Vector3]]
        if not self:isObstructed(shortened) then
            return shortened
        end
    end

    -- Try to move around corners
    if first then
        local dx = first.X - pLoc.X
        local xsign = Math.sign(dx)
        if xsign ~= 0 then
            local xloc = Vector3(pLoc.X + xsign * 10, pLoc.Y, pLoc.Z)
            if not self:isObstructed(xloc) then
                return xloc
            end
        end


        local dy = first.Y - pLoc.Y
        local ysign = Math.sign(dy)
        if ysign ~= 0 then
            local yloc = Vector3(pLoc.X, pLoc.Y + ysign * 10, pLoc.Z)
            if not self:isObstructed(yloc) then
                return yloc
            end
        end
    end

    return nil
end

---@param location Vector3
---@return boolean
function RakeSkillHandler:isObstructed(location)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()

    if not lPlayer:hasLineOfSightTo(location, false) then
        return true
    end

    local shortened = Vector.round(Vector.resizeXY(pLoc, location, MAX_OBSTRUCTION_DISTANCE)) --[[@as Vector3]]
    if self.settings.lenientWaypointLoS and not lPlayer:hasLineOfSightTo(shortened, false) then
        return true
    elseif not self.settings.lenientWaypointLoS and CombatUtils.ConservativeRaycast(pLoc, shortened, false, PLAYER_SIZE) then
        return true
    end

    for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_Collidable)) do
        -- Ignore monsters because travel skills pass through them
        if not actor:hasActorType(EActorType_Monster) and not actor:hasActorType(EActorType_Player) then
            local size = actor:getObjectSize() + PLAYER_SIZE
            if actor:getDistanceToPlayer() <= (MAX_OBSTRUCTION_DISTANCE + size) and Vector.DistanceToSegment(actor:getLocation(), pLoc, location) <= size then
                return true
            end
        end
    end
    return false
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function RakeSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

---@param key string
function RakeSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##rake_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "can_fly"), self.settings.canFly)
    _, self.settings.useAsAttack = ImGui.Checkbox(label("Use as attack", "use_as_attack"), self.settings.useAsAttack)
    _, self.settings.useAsTravelSkill = ImGui.Checkbox(label("Use as travel skill", "use_as_travel_skill"), self.settings.useAsTravelSkill)
    UI.WithDisable(not self.settings.useAsTravelSkill, function()
        UI.WithIndent(function()
            _, self.settings.lenientWaypointLoS = ImGui.Checkbox(label("Lenient waypoint LoS", "lenient_waypoint_los"), self.settings.lenientWaypointLoS)
            UI.Tooltip("Will use lenient line of sight to check terrain. This will make it pause Rake less often. But will get stuck on terrain more, while relying on stuck detection to get itself unstuck.")
            _, self.settings.stuckTimer = ImGui.InputInt(label("Stuck Timer", "stuck_timer"), self.settings.stuckTimer)
            UI.Tooltip("The time in milliseconds to wait before considering the player stuck.")
        end)
    end)

    _, self.settings.animationCancelFraction = ImGui.InputFloat(label("Animation Cancel Fraction", "animation_cancel_fraction"), self.settings.animationCancelFraction, 0.05, 0.1, "%.2f")
    ImGui.PopItemWidth()
end

return RakeSkillHandler
