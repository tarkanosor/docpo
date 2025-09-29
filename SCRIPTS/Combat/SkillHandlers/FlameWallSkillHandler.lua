local Vector = require("CoreLib.Vector")
local Render = require("CoreLib.Render")
local UI = require("CoreLib.UI")
local PulseCache = require("CoreLib.PulseCache")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

local FLAME_WALL_DEBUFF = 'firewall_debuff'
local FLAME_WALL_METAPATH = "Metadata/Monsters/Anomalies/Firewall"
local FLAME_WALL_SIZE_ADDITION = 2

local GROUND_SERVER_EFFECT_METAPATH = "Metadata/Effects/Spells/ground_effects/VisibleServerGroundEffect"
local GAS_CLOUD_AO = "Metadata/Effects/Spells/crossbow_toxic_grenade/toxic_cloud.ao"

---@class PoE2Lib.Combat.SkillHandlers.FlameWallSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.FlameWallSkillHandler
---@diagnostic disable-next-line: assign-type-mismatch
local FlameWallSkillHandler = SkillHandler:extend()

FlameWallSkillHandler.shortName = "Flame Wall"

FlameWallSkillHandler.description = [[
    This is a special skill handler for Flame Wall. NOTE: If you want to use
    Flame Wall for the added damage to fire projectiles, set Flame Wall
    with higher priority than your main skill.
]]

FlameWallSkillHandler:setCanHandle(function(skill, stats, name, _, _, activeSkill, asid)
    return asid == 'firewall'
end)

FlameWallSkillHandler.settings = { --
    range = 40,
    canFly = true,
    minDistancePlayer = 10,
    minDistanceTarget = 10,
    offsetMultiplier = 0.5,
    ---@type 'DPS'|'Wall'|'GasClouds'
    useMode = 'DPS',
    isCircle = false,
    drawFlameWalls = false,
    ---@type 'Clear'|'Target'
    gasCloudMode = 'Clear',
    gasCloudRadius = 14,
    drawGasClouds = false,
}

---@type WorldActor?
FlameWallSkillHandler.lastTargetGasCloudActor = nil
---@type integer
FlameWallSkillHandler.lastTargetGasCloudFrame = 0

local FlameWallActors = PulseCache(function()
    return Infinity.PoE2.getActorsByMetaPath(FLAME_WALL_METAPATH)
end)

local GasCloudActors = PulseCache(function()
    ---@type WorldActor[]
    local gasClouds = {}
    for _, actor in pairs(Infinity.PoE2.getActorsByMetaPath(GROUND_SERVER_EFFECT_METAPATH)) do
        if actor:getAnimatedMetaPath() == GAS_CLOUD_AO then
            table.insert(gasClouds, actor)
        end
    end
    return gasClouds
end)

---@param target? WorldActor
---@return boolean ok, string? reason
function FlameWallSkillHandler:canUse(target)
    if target == nil then
        return false, "no target"
    end

    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self.settings.useMode == "DPS" then
        if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return false, "out of range"
        end

        for _, buff in pairs(target:getBuffs()) do
            if buff:getKey() == FLAME_WALL_DEBUFF then
                return false, "target is inside Flame Wall already"
            end
        end

        return true, nil
    end

    if self.settings.useMode == "Wall" then
        if self:haveCoveringFlameWall(target) then
            return false, "already have a Flame Wall"
        end
        return true, nil
    end

    if self.settings.useMode == "GasClouds" then
        local gasCloud = self:getTargetGasCloud(target)
        if gasCloud == nil then
            return false, "no gas cloud"
        end
        return true, nil
    end

    return true, nil
end

---@param target? WorldActor
---@param location? Vector3
---@return WorldActor? target
---@return Vector3? location
function FlameWallSkillHandler:fixupTargetsDPS(target, location)
    if not self.settings.isCircle then
        return target, location
    end

    -- If it is a circle we need to offset it by 21 distance to any side that is walkable and in distance
    local lp = Infinity.PoE2.getLocalPlayer()
    local pLoc = lp:getLocation()
    local tLoc = location or (target and target:getLocation())
    if not tLoc then
        return target, location
    end

    local offset = 21
    local navigator = Infinity.PoE2.getNavigator()
    local function checkSide(angle, offset)
        local loc = Vector3(tLoc.X + math.cos(math.rad(angle)) * offset,
            tLoc.Y + math.sin(math.rad(angle)) * offset, tLoc.Z)
        if not navigator:isWalkable(math.floor(loc.X), math.floor(loc.Y), false) then
            return nil
        end

        if loc:getDistanceXY(pLoc) > self.settings.range then
            return nil
        end

        if not lp:hasLineOfSightTo(loc, true) then
            return nil
        end

        return loc
    end

    -- Check left and right side of out straight angle
    local closestLoc = nil
    local closestDist = math.huge
    for i = 0, 360, 10 do
        local loc = checkSide(i, offset)
        if loc then
            local dist = loc:getDistanceXY(pLoc)
            if not closestLoc or dist < closestDist then
                closestDist = dist
                closestLoc = loc
            end
        end
    end

    if closestLoc then
        return nil, closestLoc
    end

    return target, location
end

---@param target? WorldActor
---@param location? Vector3
function FlameWallSkillHandler:use(target, location)
    if self.settings.useMode == "DPS" then
        target, location = self:fixupTargetsDPS(target, location)
        self:super():use(target, location)
        return
    end

    if self.settings.useMode == "Wall" then
        location = location or (target and target:getLocation())
        if location == nil then
            return
        end

        local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
        local distance = location:getDistanceXY(pLoc)
        -- By default we try to put it in the middle, limited by our range.
        local offset = distance * self.settings.offsetMultiplier
        -- If the min distances are together larger than the distance, then they
        -- are overlapping. In that case we cannot use them.
        if distance > self.settings.minDistancePlayer + self.settings.minDistanceTarget then
            offset = math.max(self.settings.minDistancePlayer,
                math.min(distance - self.settings.minDistanceTarget, offset))
        end

        offset = math.min(offset, self.settings.range)

        local result = Vector.as3(Vector.add(pLoc, Vector.mult(Vector.rVec(pLoc, location), offset)))
        self:super():use(nil, result)
        return
    end

    if self.settings.useMode == 'GasClouds' then
        local gasCloud = self:getTargetGasCloud(target)
        if gasCloud == nil then
            return
        end

        self:super():use(nil, gasCloud:getLocation())
        return
    end
end

---@param target WorldActor
function FlameWallSkillHandler:haveCoveringFlameWall(target)
    local from = Infinity.PoE2.getLocalPlayer():getLocation()
    local to = target:getLocation()
    for _, wall in pairs(FlameWallActors:getValue()) do
        if self:isObstruction(wall, from, to) then
            return true
        end
    end
    return false
end

---@param actor WorldActor
---@param from Vector3
---@param to Vector3
---@return boolean
function FlameWallSkillHandler:isObstruction(actor, from, to)
    local dist, _ = Vector.DistanceToSegment(actor:getLocation(), from, to)
    return dist <= (actor:getObjectSize() + FLAME_WALL_SIZE_ADDITION)
end

---@param target WorldActor?
function FlameWallSkillHandler:getTargetGasCloud(target)
    local now = Infinity.Win32.GetFrameCount()
    if now == self.lastTargetGasCloudFrame then
        return self.lastTargetGasCloudActor
    end
    self.lastTargetGasCloudFrame = now
    self.lastTargetGasCloudActor = nil

    if self.settings.gasCloudMode == "Clear" then
        for _, gasCloud in pairs(GasCloudActors:getValue()) do
            if  self:isValidGasCloud(gasCloud)
            and gasCloud:getCloseAttackableEnemyCount(self.settings.gasCloudRadius, false, false) > 0 then
                local igniteTarget = self:getIgniteTargetInsideGasCloud(gasCloud)
                if igniteTarget ~= nil then
                    self.lastTargetGasCloudActor = igniteTarget
                    return igniteTarget
                end
            end
        end
        return nil
    end

    if self.settings.gasCloudMode == "Target" then
        if target == nil then
            return nil
        end
        local tLoc = target:getLocation()
        for _, gasCloud in pairs(GasCloudActors:getValue()) do
            if  self:isValidGasCloud(gasCloud)
            and gasCloud:getLocation():getDistanceXY(tLoc) <= self.settings.gasCloudRadius then
                local igniteTarget = self:getIgniteTargetInsideGasCloud(gasCloud)
                if igniteTarget ~= nil then
                    self.lastTargetGasCloudActor = igniteTarget
                    return igniteTarget
                end
            end
        end
        return nil
    end

    return nil
end

---@param gasCloud WorldActor
function FlameWallSkillHandler:isValidGasCloud(gasCloud)
    if not self:isInRange(gasCloud, self.settings.range, true, true) then
        return false
    end

    local loc = gasCloud:getLocation()
    for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
        if mob:hasBuff("ignited") and mob:getLocation():getDistanceXY(loc) <= self.settings.gasCloudRadius then
            return false
        end
    end

    return true
end

---@param gasCloud WorldActor
---@return WorldActor?
function FlameWallSkillHandler:getIgniteTargetInsideGasCloud(gasCloud)
    local loc = gasCloud:getLocation()
    for _, mob in pairs(Infinity.PoE2.getPotentialCombatTargets()) do
        if mob:getLocation():getDistanceXY(loc) <= self.settings.gasCloudRadius then
            return mob
        end
    end
    return nil
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function FlameWallSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

---@param key string
function FlameWallSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##flame_wall_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "can_fly"), self.settings.canFly)

    if UI.WithTooltip(ImGui.BeginCombo(label("Target Mode", "target_mode"), self.settings.useMode), function()
        ImGui.BulletText("DPS: Will put a Flame Wall on your target for damage.")
        ImGui.BulletText(
            "Wall: Will put a Flame Wall between you and your target for the added damage to fire projectiles.")
        ImGui.BulletText("GasClouds: Will put a Flame Wall on Gas Clouds to blown them up.")
    end) then
        for _, mode in ipairs({ 'DPS', 'Wall', 'GasClouds' }) do
            if ImGui.Selectable(mode, self.settings.useMode == mode) then
                self.settings.useMode = mode
            end
        end
        ImGui.EndCombo()
    end

    if self.settings.useMode == "DPS" then
        _, self.settings.isCircle = ImGui.Checkbox(label("Is Circle", "is_circle"), self.settings.isCircle)
    end
    if self.settings.useMode == "Wall" then
        ImGui.Indent()
        _, self.settings.offsetMultiplier = ImGui.InputFloat(label("Offset Multiplier", "offset_multiplier"), self.settings.offsetMultiplier)
        UI.Tooltip(
            "How far to put the Flame Wall between the player and the target. 0 = at the player, 0.5 = is in the middle, 1 = at the target.")
        ImGui.Unindent()
    end

    if self.settings.useMode == "GasClouds" then
        ImGui.Indent()
        if UI.WithTooltip(ImGui.BeginCombo(label("Mode", "gas_cloud_mode"), self.settings.gasCloudMode), function()
            ImGui.BulletText("Target: Will use Flame Wall on Gas Clouds around your current target.")
            ImGui.BulletText("Clear: Will use Flame Wall on any Gas Clouds that will hit a target.")
        end) then
            for _, mode in ipairs({ 'Clear', 'Target' }) do
                if ImGui.Selectable(mode, self.settings.gasCloudMode == mode) then
                    self.settings.gasCloudMode = mode
                end
            end
            ImGui.EndCombo()
        end

        _, self.settings.gasCloudRadius = ImGui.InputInt(label("Gas Cloud Radius", "gas_cloud_radius"), self.settings.gasCloudRadius)
        UI.Tooltip("The radius of the gas clouds.")

        _, self.settings.drawGasClouds = ImGui.Checkbox(label("Draw Gas Clouds", "draw_gas_clouds"), self.settings.drawGasClouds)
        UI.Tooltip("Draws circles around the gas clouds.")

        ImGui.Unindent()
    end

    _, self.settings.drawFlameWalls = ImGui.Checkbox(label("Draw Flame Walls", "draw_flame_walls"),
        self.settings.drawFlameWalls)

    ImGui.PopItemWidth()
end

function FlameWallSkillHandler:onRenderD2D()
    if self.settings.drawFlameWalls then
        for _, wall in pairs(FlameWallActors:getValue()) do
            local color = "55FF0000"
            Render.DrawWorldCircle(wall:getWorld(), (wall:getObjectSize() + FLAME_WALL_SIZE_ADDITION) * (250 / 23), color, 4)
        end
    end

    if self.settings.drawGasClouds then
        for _, gasCloud in pairs(GasCloudActors:getValue()) do
            local color = "55FF0000"
            if gasCloud:getCloseAttackableEnemyCount(self.settings.gasCloudRadius, false, false) > 0 then
                if self:isValidGasCloud(gasCloud) then
                    color = "5500FF00"
                else
                    color = "55FFFF00"
                end
            end
            Render.DrawWorldCircle(gasCloud:getWorld(), self.settings.gasCloudRadius * (250 / 23), color, 4)
        end
    end
end

return FlameWallSkillHandler
