local Navigator = Infinity.PoE2.getNavigator()
local UI = require("CoreLib.UI")
local Vector = require("CoreLib.Vector")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local Math = require("CoreLib.Math")

local RAYCAST_DISTANCE_LIMIT = 100
local LENIENT_LOS_ALLOWED = true

---@class PoE2Lib.Combat.SkillHandlers.BlinkSkillHandler : PoE2Lib.Combat.SkillHandler
local BlinkSkillHandler = SkillHandler:extend()

BlinkSkillHandler.shortName = "Blink"

BlinkSkillHandler.description = [[
    Blink Skill Handler that combines offensive and travel logic.
]]

BlinkSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "blink"
end)

---@class PoE2Lib.Combat.SkillHandlers.BlinkSkillHandler.Settings
BlinkSkillHandler.settings = {
    range = 50,
    canFly = true,
    useLenientLos = false,
    collisionRadius = 1,
    collisionRadiusAuto = true,

    useTravel = true,
    rangeAuto = true,
    minGain = 20,

    useOffensive = false,
    optimizeOffensivePlacement = true,

    notNearEnemies = false,
    notNearEnemiesRange = 0,
}

function BlinkSkillHandler:onPulse()
    if self.settings.rangeAuto then
        self.settings.range = self:getStat(SkillStats.BlinkTravelDistance)
    end
    if self.settings.collisionRadiusAuto then
        -- self.settings.collisionRadius = Infinity.PoE2.getLocalPlayer():getObjectSize()
        self.settings.collisionRadius = 1
    end
end

---@return boolean
function BlinkSkillHandler:hasReservation()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "blink_reservation" and buff:getAssociatedSkillId() == (self.skillId - 0x1000) then
            return true
        end
    end
    return false
end

---@param from Vector3
---@param to Vector3
---@return boolean, Vector3?
function BlinkSkillHandler:raycast(from, to)
    if LENIENT_LOS_ALLOWED and self.settings.useLenientLos then
        return CombatUtils.Raycast(from, to, self.settings.canFly)
    else
        return CombatUtils.ConservativeRaycast(from, to, self.settings.canFly, self.settings.collisionRadius)
    end
end

---@param origin Vector3
---@param stepSize number
---@return fun():Vector3?
function BlinkSkillHandler:iterDirections(origin, stepSize)
    local angle = 0
    return function()
        if angle >= 360 then
            return nil
        end

        local x = origin.X + self.settings.range * math.cos(angle / (180 / math.pi))
        local y = origin.Y + self.settings.range * math.sin(angle / (180 / math.pi))
        angle = angle + stepSize
        return Vector3(Math.round(x), Math.round(y), origin.Z)
    end
end

function BlinkSkillHandler:getActionFlag()
    return 0x0404
end

--------------------------------------------------------------------------------
-- Travel
--------------------------------------------------------------------------------

---@return boolean
function BlinkSkillHandler:needsPathfinding()
    return true
end

---@param destination Vector3
---@param locations Vector3[]
---@param costs number[]
function BlinkSkillHandler:travel(destination, locations, costs)
    if not self.settings.useTravel then
        return false
    end

    -- Check if this is the correct Blink skill
    if bit.band(self.skillId, 0x1000) == 0 then
        return false
    end

    if not self:baseCanUse(nil) then
        return false
    end

    if not self:hasReservation() then
        return false
    end

    if self.settings.notNearEnemies then
        if Infinity.PoE2.getLocalPlayer():getCloseAttackableEnemyCount(self.settings.notNearEnemiesRange, true, true) > 0 then
            return false
        end
    end

    if #locations == 0 then
        return false
    end

    local best, cost = self:getBestLocationAlongPath(locations, costs)
    if best == nil then
        return false
    end

    local first = locations[1]
    if first ~= nil then
        local walkingCost = costs[1] + Infinity.PoE2.getLocalPlayer():getLocation():getDistanceXY(first)
        local gain = walkingCost - cost
        if gain < self.settings.minGain then
            return false
        end
    end


    local player = Infinity.PoE2.getLocalPlayer()
    player:setDodgeRollState(true)
    self:super():use(nil, best)
    player:setDodgeRollState(false)
    return true
end

---@param locations Vector3[]
---@param costs number[]
---@return Vector3? location, number cost
function BlinkSkillHandler:getBestLocationAlongPath(locations, costs)
    local origin = Infinity.PoE2.getLocalPlayer():getLocation()
    local best, cost = nil, math.huge
    for direction in self:iterDirections(origin, 10) do
        local loc, c = self:checkDirection(origin, direction, locations, costs)
        if loc and c < cost then
            best, cost = loc, c
        end
    end

    return best, cost
end

---@param origin Vector3
---@param direction Vector3
---@param locations Vector3[]
---@param costs number[]
---@return Vector3? best, number cost
function BlinkSkillHandler:checkDirection(origin, direction, locations, costs)
    local _, collision = self:raycast(origin, direction)
    local placement = collision or direction
    local cost = math.huge
    for i = 1, #locations do
        local start, finish = locations[i - 1] or origin, locations[i]
        local dist, optimal = Vector.GetPointSegmentDistance(placement, start, finish)
        if dist <= RAYCAST_DISTANCE_LIMIT or i == 1 then
            local c = costs[i] + dist + optimal:getDistanceXY(finish)
            if c < cost and not CombatUtils.Raycast(optimal, placement, false) then
                cost = c
            end
        end
    end

    return placement, cost
end

--------------------------------------------------------------------------------
-- Offensive
--------------------------------------------------------------------------------

---@param target WorldActor?
---@return boolean ok, string? reason
function BlinkSkillHandler:canUse(target)
    if bit.band(self.skillId, 0x1000) == 0 then
        return false, "wrong blink skill"
    end

    if not self.settings.useOffensive then
        return false, "offensive use disabled"
    end

    if not target then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if not self:hasReservation() then
        return false, "no reservation"
    end

    if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
        return false, "target out of range"
    end

    return true, nil
end

---@param target WorldActor
---@param location? Vector3
function BlinkSkillHandler:use(target, location)
    if self.settings.optimizeOffensivePlacement then
        local best = self:getOffensivePlacement(target)
        if best ~= nil then
            local player = Infinity.PoE2.getLocalPlayer()
            player:setDodgeRollState(true)
            self:super():use(nil, best)
            player:setDodgeRollState(false)
            return
        end
    end

    local player = Infinity.PoE2.getLocalPlayer()
    player:setDodgeRollState(true)
    self:super():use(nil, target:getLocation())
    player:setDodgeRollState(false)
end

---@param target WorldActor
function BlinkSkillHandler:getOffensivePlacement(target)
    local origin = Infinity.PoE2.getLocalPlayer():getLocation()
    local targetLoc = target:getLocation()
    local best, bestDistance = nil, math.huge
    for direction in self:iterDirections(origin, 10) do
        local distance = targetLoc:getDistanceXY(direction)
        if  distance < bestDistance
        and target:hasLineOfSightTo(direction, true)
        and not self:raycast(origin, direction)
        and Navigator:isLocationReachable(direction, 0) then
            best, bestDistance = direction, distance
        end
    end
    return best
end

---@return number Range, boolean canFly
function BlinkSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------

---@param key string
function BlinkSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##blink_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    UI.WithDisable(self.settings.rangeAuto, function()
        _, self.settings.range = ImGui.InputInt(label("Range", "range") .. key, self.settings.range)
        UI.Tooltip("This is the range of your Blink skill.")
    end)
    ImGui.SameLine()
    _, self.settings.rangeAuto = ImGui.Checkbox(label("Auto", "rangeAuto") .. key, self.settings.rangeAuto)
    UI.Tooltip("If this is enabled, the range will be automatically set to the Blink skill's travel distance based on the skill stats.")

    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly") .. key, self.settings.canFly)
    UI.Tooltip("If this is enabled, Blink will be used to fly over gaps.")

    if LENIENT_LOS_ALLOWED then
        _, self.settings.useLenientLos = ImGui.Checkbox(label("Use Lenient LoS", "useLenientLos") .. key, self.settings.useLenientLos)
        UI.Tooltip("If this is enabled, the skill will use a more lenient line of sight check. Use at your own peril, might cause more stucks.")
    end

    UI.WithDisable(LENIENT_LOS_ALLOWED and self.settings.useLenientLos, function()
        UI.WithDisable(self.settings.collisionRadiusAuto, function()
            _, self.settings.collisionRadius = ImGui.InputInt(label("Collision Radius", "collisionRadius") .. key, self.settings.collisionRadius)
            UI.Tooltip("The collision radius to use for the skill. This is used for raycasting to check for terrain and obstacles.")
        end)
        ImGui.SameLine()
        _, self.settings.collisionRadiusAuto = ImGui.Checkbox(label("Auto", "collisionRadiusAuto") .. key, self.settings.collisionRadiusAuto)
        UI.Tooltip("If this is enabled, the collision radius will be automatically set to the player's object size.")
    end)

    _, self.settings.useTravel = ImGui.Checkbox(label("Use Travel", "useTravel") .. key, self.settings.useTravel)
    UI.Tooltip("If this is enabled, the skill will be used for travel.")

    UI.WithDisableIndent(not self.settings.useTravel, function()
        _, self.settings.minGain = ImGui.InputInt(label("Min Gain", "minGain") .. key, self.settings.minGain)
        UI.Tooltip("The minimum gain required to use the skill for travel. The gain is the difference between walking and blinking to the destination.")

        _, self.settings.notNearEnemies = ImGui.Checkbox(label("Don't Travel Near Enemies Within", "notNearEnemies") .. key, self.settings.notNearEnemies)
        UI.Tooltip("If this is enabled, the skill will not be used for travel if there are enemies nearby.")
        UI.WithDisable(not self.settings.notNearEnemies, function()
            ImGui.SameLine()
            _, self.settings.notNearEnemiesRange = ImGui.InputInt(label("Range", "notNearEnemiesinRange") .. key, self.settings.notNearEnemiesRange)
            UI.Tooltip("The range to check for enemies.")
        end)
    end)

    _, self.settings.useOffensive = ImGui.Checkbox(label("Use Offensive", "useOffensive") .. key, self.settings.useOffensive)
    UI.Tooltip("If this is enabled, the skill will be used offensively to kill mobs.")
    UI.WithDisableIndent(not self.settings.useOffensive, function()
        _, self.settings.optimizeOffensivePlacement = ImGui.Checkbox(label("Optimize Placement", "optimizeOffensivePlacement") .. key, self.settings.optimizeOffensivePlacement)
        UI.Tooltip("If this is enabled, the skill will try to find the best placement to hit the target. The best placement is the one that is closest to the target while still being a full Blink.")
    end)

    ImGui.PopItemWidth()
end

return BlinkSkillHandler
