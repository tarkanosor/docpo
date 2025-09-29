local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

---@class PoE2Lib.Combat.SkillHandlers.LightningWarpSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.LightningWarpSkillHandler
local LightningWarpSkillHandler = SkillHandler:extend()

LightningWarpSkillHandler.shortName = "Lightning Warp"

LightningWarpSkillHandler.description = "This is a skill handler for Lightning Warp."

LightningWarpSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == 'teleport_ball'
end)

LightningWarpSkillHandler.settings = { --
    range = 80,
    explosionRadius = 40,
    ---@type 'OptimalClear'|'Target'
    targetMode = 'OptimalClear',
    targetLightningBall = false,
}

local BALL_LIGHTNING_META_PATH = "Metadata/Projectiles/BallLightningPlayer"

--- Used to cache the optimal target. Contains the last optimal target actor.
---@type WorldActor?
LightningWarpSkillHandler.lastOptimalTargetActor = nil

--- Used to cache the optimal target location. Contains the last optimal target location.
---@type Vector3?
LightningWarpSkillHandler.lastOptimalTargetLocation = nil

--- Used to cache the optimal target. Contains the last update tick.
---@type number
LightningWarpSkillHandler.lastOptimalTargetActorFrame = 0

---@param target? WorldActor
---@param location? Vector3
---@return Vector3? location, number? hits
function LightningWarpSkillHandler:findLightningBall(target, location)
    local targetLoc = location or (target and target:getLocation())
    if not targetLoc then
        return nil, nil
    end

    if self.settings.targetMode == 'Target' then
        for _, lightningBall in pairs(Infinity.PoE2.getActorsByMetaPath(BALL_LIGHTNING_META_PATH)) do
            if self:isInRange(lightningBall, self.settings.range, true, true) then
                return lightningBall:getLocation(), lightningBall:getCloseAttackableEnemyCount(self.settings.explosionRadius)
            end
        end
        return nil, nil
    end

    if self.settings.targetMode == 'OptimalClear' then
        local bestBall, bestHits = nil, 0
        for _, lightningBall in pairs(Infinity.PoE2.getActorsByMetaPath(BALL_LIGHTNING_META_PATH)) do
            if self:isInRange(lightningBall, self.settings.range, true, true) then
                local hits = lightningBall:getCloseAttackableEnemyCount(self.settings.explosionRadius)
                if hits > bestHits then
                    bestBall = lightningBall:getLocation()
                    bestHits = hits
                end
            end
        end
        return bestBall, bestHits
    end

    return nil, nil
end

local CULL_THRESHOLDS = { --
    [ERarity_White] = 30,
    [ERarity_Magic] = 20,
    [ERarity_Rare] = 10,
    [ERarity_Unique] = 5,
}

---@param target WorldActor
function LightningWarpSkillHandler:isCullable(target)
    local threshold = CULL_THRESHOLDS[target:getRarity()] or 0
    return threshold >= target:getHpPercentage()
end

---@param target? WorldActor
---@param location? Vector3
---@return WorldActor? targetActor, Vector3? targetLocation
function LightningWarpSkillHandler:getOptimalTargetUncached(target, location)
    if self.settings.targetMode == 'Target' then
        if target and self:isCullable(target) and self:isInRange(target, self.settings.range, true, true) then
            return target, nil
        end
        if self.settings.targetLightningBall then
            local lightningBall, _ = self:findLightningBall(target, location)
            if lightningBall then
                return nil, lightningBall
            end
        end
        return nil, nil
    end

    if self.settings.targetMode == 'OptimalClear' then
        local bestTarget, bestLocation, bestHits = nil, nil, 0

        for _, monster in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
            if self:isCullable(monster) and self:isInRange(monster, self.settings.range, true, true) then
                local hits = monster:getCloseAttackableEnemyCount(self.settings.explosionRadius)
                if hits > bestHits then
                    bestTarget = monster
                    bestLocation = nil
                    bestHits = hits
                end
            end
        end

        if self.settings.targetLightningBall then
            local lightningBall, lightningHits = self:findLightningBall(target, location)
            if lightningBall and lightningHits > bestHits then
                bestTarget = nil
                bestLocation = lightningBall
            end
        end

        return bestTarget, bestLocation
    end
end

---@param target? WorldActor
---@param location? Vector3
---@return WorldActor? targetActor, Vector3? targetLocation
function LightningWarpSkillHandler:getOptimalTarget(target, location)
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastOptimalTargetActorFrame then
        self.lastOptimalTargetActor, self.lastOptimalTargetLocation = self:getOptimalTargetUncached(target, location)
        self.lastOptimalTargetActorFrame = now
    end

    return self.lastOptimalTargetActor, self.lastOptimalTargetLocation
end

---@param target? WorldActor
---@return boolean ok, string? reason
function LightningWarpSkillHandler:canUse(target)
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
function LightningWarpSkillHandler:use(target, location)
    local optimalTarget, optimalLocation = self:getOptimalTarget(target, location)
    self:super():use(optimalTarget, optimalLocation)
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function LightningWarpSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, true
end

---@param key string
function LightningWarpSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##lightning_warp_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.explosionRadius = ImGui.InputInt(label("Explosion Radius", "explosion_radius"), self.settings.explosionRadius)

    if UI.WithTooltip(ImGui.BeginCombo(label("Target Mode", "target_mode"), self.settings.targetMode), function()
        ImGui.BulletText("OptimalClear: Target the cullable monster or lightning ball that will hit the most enemies with the explosion.")
        ImGui.BulletText("Target: Always cast at the current target (if cullable) or nearest lightning ball (if enabled).")
    end) then
        for _, mode in ipairs({ 'OptimalClear', 'Target' }) do
            if ImGui.Selectable(mode, self.settings.targetMode == mode) then
                self.settings.targetMode = mode
            end
        end
        ImGui.EndCombo()
    end

    _, self.settings.targetLightningBall = ImGui.Checkbox(label("Target Lightning Ball", "target_lightning_ball"), self.settings.targetLightningBall)

    ImGui.PopItemWidth()
end

return LightningWarpSkillHandler
