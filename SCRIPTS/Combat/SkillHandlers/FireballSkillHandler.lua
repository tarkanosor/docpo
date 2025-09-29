local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.FireballSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.FireballSkillHandler
local FireballSkillHandler = SkillHandler:extend()

FireballSkillHandler.shortName = "Fireball"

FireballSkillHandler.description = [[
    This is a skill handler for Fireball with optimized targeting modes.
    Will prioritize hitting Frost Walls when they're near the target (if enabled).
]]

FireballSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == 'greater_fireball'
end)

FireballSkillHandler.settings = { --
    range = 80,
    explosionRadius = 17,
    ---@type 'OptimalClear'|'Target'
    targetMode = 'OptimalClear',
    --@type boolean?
    targetfrostWall = false,
    frostWallExplosionRadius = 30,
}


--- Used to cache the optimal target. Contains the last optimal target actor.
---@type WorldActor?
FireballSkillHandler.lastOptimalTargetActor = nil

--- Used to cache the optimal target location. Contains the last optimal target location.
---@type Vector3?
FireballSkillHandler.lastOptimalTargetLocation = nil

--- Used to cache the optimal target. Contains the last update tick.
---@type number
FireballSkillHandler.lastOptimalTargetActorFrame = 0

-- Override default frost wall targeting logic from base SkillHandler
---@param target WorldActor?
---@param location? Vector3
---@return WorldActor? target, Vector3? location
function FireballSkillHandler:overrideTarget(target, location)
    return target, location
end

---@param center Vector3
---@param explosionRadius number
---@return number hits
function FireballSkillHandler:countExplosionHits(center, explosionRadius)
    local hits = 0
    for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
        if center:getDistanceXY(monster:getLocation()) <= explosionRadius then
            hits = hits + 1
        end
    end
    return hits
end

---@param target? WorldActor
---@param location? Vector3
---@return Vector3? location, number? hits
function FireballSkillHandler:findFrostWallTarget(target, location)
    if not SkillHandler.SharedState.HasFrostWall:getValue() then
        return nil, nil
    end

    local targetLoc = location or (target and target:getLocation())
    if not targetLoc then
        return nil, nil
    end

    -- For Target mode, find closest wall to target
    if self.settings.targetMode == 'Target' then
        local bestWall, bestDist, hits = nil, self.settings.frostWallExplosionRadius, nil
        for _, frostWall in pairs(SkillHandler.SharedState.FrostWalls:getValue()) do
            local wallLoc = frostWall:getLocation()
            if self:isInRange(wallLoc, self.settings.range, true, false) then
                local dist = wallLoc:getDistanceXY(targetLoc)
                if dist <= bestDist then
                    hits = self:countExplosionHits(wallLoc, self.settings.frostWallExplosionRadius)
                    bestWall = wallLoc
                    bestDist = dist
                end
            end
        end
        return bestWall, hits
    end

    -- For OptimalClear, find wall that hits most enemies
    if self.settings.targetMode == 'OptimalClear' then
        local bestWall, bestHits = nil, 0
        for _, frostWall in pairs(SkillHandler.SharedState.FrostWalls:getValue()) do
            local wallLoc = frostWall:getLocation()
            if self:isInRange(wallLoc, self.settings.range, true, false) then
                local hits = self:countExplosionHits(wallLoc, self.settings.frostWallExplosionRadius)
                if hits > bestHits then
                    bestWall = wallLoc
                    bestHits = hits
                end
            end
        end
        return bestWall, bestHits
    end

    return nil, nil
end

---@param target? WorldActor
---@param location? Vector3
---@return WorldActor? targetActor, Vector3? targetLocation
function FireballSkillHandler:getOptimalTarget(target, location)
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastOptimalTargetActorFrame then
        self.lastOptimalTargetActor, self.lastOptimalTargetLocation = self:getOptimalTargetUncached(target, location)
        self.lastOptimalTargetActorFrame = now
    end

    return self.lastOptimalTargetActor, self.lastOptimalTargetLocation
end

---@param target? WorldActor
---@param location? Vector3
---@return WorldActor? targetActor, Vector3? targetLocation
function FireballSkillHandler:getOptimalTargetUncached(target, location)
    if self.settings.targetMode == 'Target' then
        if self.settings.targetFrostWall then
            local wallLocation, _ = self:findFrostWallTarget(target, location)
            if wallLocation then
                return nil, wallLocation
            end
        end
        if target and self:isInRange(target, self.settings.range, true, true) then
            return target, nil
        end
        return nil, nil
    end

    if self.settings.targetMode == 'OptimalClear' then
        local bestTarget, bestLocation, bestHits = nil, nil, 0

        for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            if self:isInRange(monster, self.settings.range, true, true) then
                local hits = self:countExplosionHits(monster:getLocation(), self.settings.explosionRadius)
                if hits > bestHits then
                    bestTarget = monster
                    bestLocation = nil
                    bestHits = hits
                end
            end
        end

        if self.settings.targetFrostWall then
            local wallLocation, wallHits = self:findFrostWallTarget(target, location)
            if wallLocation and wallHits > bestHits then
                bestTarget = nil
                bestLocation = wallLocation
            end
        end

        return bestTarget, bestLocation
    end

    return nil, nil
end

---@param target? WorldActor
---@return boolean ok, string? reason
function FireballSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    local optimalTarget, optimalLocation = self:getOptimalTarget(target, nil)
    if optimalTarget == nil and optimalLocation == nil then
        return false, "no target"
    end

    return true, nil
end

---@param target? WorldActor
---@param location? Vector3
function FireballSkillHandler:use(target, location)
    local optimalTarget, optimalLocation = self:getOptimalTarget(target, location)
    self:super():use(optimalTarget, optimalLocation)
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function FireballSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@param key string
function FireballSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##fireball_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.explosionRadius = ImGui.InputInt(label("Explosion Radius", "explosion_radius"), self.settings.explosionRadius)
    UI.Tooltip("The radius of the Fireball explosion. (1 meters = 10 range)")

    if UI.WithTooltip(ImGui.BeginCombo(label("Target Mode", "target_mode"), self.settings.targetMode), function()
        ImGui.BulletText("OptimalClear: Target the monster or frost wall that will hit the most enemies with the explosion.")
        ImGui.BulletText("Target: Always cast at the current target or nearest frost wall (if enabled).")
    end) then
        for _, mode in ipairs({ 'OptimalClear', 'Target' }) do
            if ImGui.Selectable(mode, self.settings.targetMode == mode) then
                self.settings.targetMode = mode
            end
        end
        ImGui.EndCombo()
    end

    _, self.settings.targetfrostWall = ImGui.Checkbox(label("Target Frost Walls", "target_frost_wall"), self.settings.targetfrostWall)
    UI.WithDisable(not self.settings.targetfrostWall, function()
        ImGui.Indent()
        _, self.settings.frostWallExplosionRadius = ImGui.InputInt(label("Frost Wall Explosion Radius", "frost_wall_explosion_radius"), self.settings.frostWallExplosionRadius)
        UI.Tooltip("Maximum allowed distance between Frost Wall and target for wall targeting.")
        ImGui.Unindent()
    end)

    ImGui.PopItemWidth()
end

return FireballSkillHandler
