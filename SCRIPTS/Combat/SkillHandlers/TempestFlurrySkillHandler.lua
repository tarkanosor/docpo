local Vector = require("CoreLib.Vector")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local CastMethods = require("PoE2Lib.Combat.CastMethods")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")
local UI = require("CoreLib.UI")
local Math = require("CoreLib.Math")

local MAX_WAYPOINT_DISTANCE = 100
local PLAYER_SIZE = 3
local MAX_OBSTRUCTION_DISTANCE = 5

---@class PoE2Lib.Combat.SkillHandlers.TempestFlurrySkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.TempestFlurrySkillHandler
local TempestFlurrySkillHandler = SkillHandler:extend()

TempestFlurrySkillHandler.shortName = "Tempest Flurry"

TempestFlurrySkillHandler.description = [[
    This is a skill handler for Tempest Flurry.
]]

---@class PoE2Lib.Combat.SkillHandlers.TempestFlurrySkillHandler.Settings
TempestFlurrySkillHandler.settings = { --
    range = 30,
    canFly = false,
    useAsAttack = true,
    useAsTravelSkill = false,
    lenientWaypointLoS = false,
    stuckTimer = 300,
}

TempestFlurrySkillHandler:setCanHandle(function(skill, stats, name, grantedEffectsPerLevel, grantedEffect, activeSkill, activeSkillId)
    return activeSkillId == "tempest_flurry"
end)

---@type "attack"|"travel"
TempestFlurrySkillHandler.lastUseType = "attack"

---@type Vector3
TempestFlurrySkillHandler.lastLocation = Vector3(0, 0, 0)
---@type number
TempestFlurrySkillHandler.lastLocationChange = 0

function TempestFlurrySkillHandler:onPulse()
    local location = Infinity.PoE2.getLocalPlayer():getLocation()
    if location:getDistanceXY(self.lastLocation) > 5 then
        -- print(("Location changed, delta: %.1fms"):format(Infinity.Win32.GetTickCount() - self.lastLocationChange))
        self.lastLocation = location
        self.lastLocationChange = Infinity.Win32.GetTickCount()
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function TempestFlurrySkillHandler:canUse(target)
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

---@param target WorldActor?
---@param location Vector3?
function TempestFlurrySkillHandler:use(target, location)
    self.lastUseType = "attack"
    return self:super():use(target, location)
end

function TempestFlurrySkillHandler:onUse()
    self:super():onUse()
end

---@param target WorldActor?
function TempestFlurrySkillHandler:updateTarget(target)
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
function TempestFlurrySkillHandler:shouldPreventMovement(target)
    if self.settings.useAsTravelSkill then
        return false
    end
    if target == nil or not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return false
    end
    return self:super():shouldPreventMovement(target)
end

---@return boolean
function TempestFlurrySkillHandler:needsPathfinding()
    return self.settings.useAsTravelSkill
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
---@return boolean
function TempestFlurrySkillHandler:travel(destination, locations, costs)
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

function TempestFlurrySkillHandler:stopAttacking()
    if self.lastUseType == "attack" and self.thisActionInitiatedByThis then
        self:super():stopAttacking()
    end
end

function TempestFlurrySkillHandler:stopTravel()
    if self.settings.useAsTravelSkill and self:isCurrentAction() and self.lastUseType == "travel" and self.thisActionInitiatedByThis then
        self:stopAction()
    end
end

---@param destination Vector3
---@param locations Vector3[]
---@return Vector3?
function TempestFlurrySkillHandler:getNextLocation(destination, locations)
    local lPlayer = Infinity.PoE2.getLocalPlayer()
    local pLoc = lPlayer:getLocation()

    if not self:isObstructed(destination) then
        return Vector.as3(Vector.add(pLoc, Vector.modifyLength(Vector.rVec(pLoc, destination), MAX_WAYPOINT_DISTANCE)))
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
function TempestFlurrySkillHandler:isObstructed(location)
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
function TempestFlurrySkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

---@param key string
function TempestFlurrySkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##tempest_flurry_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "can_fly"), self.settings.canFly)
    _, self.settings.useAsAttack = ImGui.Checkbox(label("Use as attack", "use_as_attack"), self.settings.useAsAttack)
    _, self.settings.useAsTravelSkill = ImGui.Checkbox(label("Use as travel skill", "use_as_travel_skill"), self.settings.useAsTravelSkill)
    UI.WithDisable(not self.settings.useAsTravelSkill, function()
        UI.WithIndent(function()
            _, self.settings.lenientWaypointLoS = ImGui.Checkbox(label("Lenient waypoint LoS", "lenient_waypoint_los"), self.settings.lenientWaypointLoS)
            UI.Tooltip("Will use lenient line of sight to check terrain. This will make it pause Tempest Flurry less often. But will get stuck on terrain more, while relying on stuck detection to get itself unstuck.")
            _, self.settings.stuckTimer = ImGui.InputInt(label("Stuck Timer", "stuck_timer"), self.settings.stuckTimer)
            UI.Tooltip("The time in milliseconds to wait before considering the player stuck.")
        end)
    end)
    ImGui.PopItemWidth()
end

return TempestFlurrySkillHandler
