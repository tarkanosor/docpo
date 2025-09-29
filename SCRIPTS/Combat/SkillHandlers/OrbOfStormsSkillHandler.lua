local UI = require("CoreLib.UI")
local Render = require("CoreLib.Render")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

-- Tu as basculé sur le marker, je garde celui-ci
-- local ORB_OF_STORMS_AO = "Metadata/Effects/Spells/storm_cloud/rig.ao"
local ORB_OF_STORMS_AO = "Metadata/Effects/Spells/storm_cloud/aoe_marker.ao"

---@class PoE2Lib.Combat.SkillHandlers.OrbOfStormsSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.OrbOfStormsSkillHandler
local OrbOfStormsSkillHandler = SkillHandler:extend()

OrbOfStormsSkillHandler.shortName = "Orb of Storms"

OrbOfStormsSkillHandler.description = [[
    This is a skill handler for Orb of Storms. It will keep Orb of Storms active,
    with a configurable limit (global or near target/player).
]]

OrbOfStormsSkillHandler:setCanHandle(function(_, _, _, _, _, _, asid)
    return asid == "orb_of_storms"
end)

OrbOfStormsSkillHandler.settings = {
    range = 80,

    -- Détection de proximité des orbes
    orbRadius = 30,
    orbRadiusAuto = true,

    -- Placement / contraintes
    canFly = false,
    castOnSelf = false,

    -- Limite d’orbes
    useLimit = true,
    limit = 2,                       -- max d’orbes autorisées
    -- 0 = Global (toutes les orbes sur la map)
    -- 1 = Near Target (ou Near Player si castOnSelf)
    limitScope = 1,

    -- Anti-spam simple
    minRecastMs = 600,

    -- Debug / affichage
    drawOrbs = false,
}

function OrbOfStormsSkillHandler:onPulse()
    if self.settings.orbRadiusAuto then
        self.settings.orbRadius = self:getStat(SkillStats.ActiveSkillSecondaryAoERadius)
    end
end

---@type WorldActor?
OrbOfStormsSkillHandler.lastOrb = nil

---@type number
OrbOfStormsSkillHandler.lastOrbFrame = 0

-- ===== Orbs lookup =====

---@param target WorldActor
---@return WorldActor?
function OrbOfStormsSkillHandler:findOrbOfStorms(target)
    local now = Infinity.Win32.GetFrameCount()
    if now ~= self.lastOrbFrame then
        self.lastOrb = self:findOrbOfStormsUncached(target)
        self.lastOrbFrame = now
    end
    return self.lastOrb
end

---@param target WorldActor
---@return WorldActor?
function OrbOfStormsSkillHandler:findOrbOfStormsUncached(target)
    local center = target and target:getLocation()
    if not center then return nil end
    local r = self.settings.orbRadius or 0
    for _, orb in pairs(Infinity.PoE2.getActorsByType(EActorType_LimitedLifespan)) do
        if orb:getAnimatedMetaPath() == ORB_OF_STORMS_AO then
            local p = orb:getLocation()
            if p and p:getDistanceXY(center) <= r then
                return orb
            end
        end
    end
    return nil
end

---@param centerLoc Vector3?
---@param radius number?
---@return integer count
function OrbOfStormsSkillHandler:getOrbCount(centerLoc, radius)
    local count = 0
    for _, orb in pairs(Infinity.PoE2.getActorsByType(EActorType_LimitedLifespan)) do
        if orb:getAnimatedMetaPath() == ORB_OF_STORMS_AO then
            if centerLoc and radius then
                local p = orb:getLocation()
                if p and p:getDistanceXY(centerLoc) <= radius then
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
    end
    return count
end

-- ===== CanUse / Use =====

---@param target? WorldActor
---@return boolean ok, string? reason
function OrbOfStormsSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    -- Choix des contraintes selon castOnSelf
    if not self.settings.castOnSelf then
        if target == nil then
            return false, "no target"
        end
        if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return false, "target out of range"
        end
    else
        local player = Infinity.PoE2.getLocalPlayer()
        if not player then
            return false, "player actor not found"
        end
    end

    -- Application de la limite
    if self.settings.useLimit then
        local scope = self.settings.limitScope or 0
        local count
        if scope == 0 then
            -- Global
            count = self:getOrbCount(nil, nil)
        else
            -- Near Target (ou Near Player si castOnSelf)
            local centerActor = self.settings.castOnSelf and Infinity.PoE2.getLocalPlayer() or target
            local center = centerActor and centerActor:getLocation() or nil
            if not center then return false, "no center" end
            count = self:getOrbCount(center, self.settings.orbRadius)
        end
        if count >= (self.settings.limit or 0) then
            return false, "limit reached"
        end
    else
        -- Ancien comportement: si on n’utilise pas la limite, on évite juste le doublon local
        local centerActor = self.settings.castOnSelf and Infinity.PoE2.getLocalPlayer() or target
        if centerActor and self:findOrbOfStorms(centerActor) ~= nil then
            return false, "orb already active"
        end
    end

    -- Anti-spam minimal
    if self._lastCastTimeMs then
        local now = Infinity.Win32.GetTickCount()
        if (now - self._lastCastTimeMs) < (self.settings.minRecastMs or 0) then
            return false, "recently cast"
        end
    end

    return true, nil
end

--- If castOnSelf is true, target is ignored and location is used instead.
---@param target? WorldActor
---@param location? Vector3
function OrbOfStormsSkillHandler:use(target, location)
    if self.settings.castOnSelf then
        local player = Infinity.PoE2.getLocalPlayer()
        if not player then return end
        self:super():use(nil, player:getLocation())
    else
        self:super():use(target, location)
    end
    self._lastCastTimeMs = Infinity.Win32.GetTickCount()
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function OrbOfStormsSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

-- ===== UI =====

---@param key string
function OrbOfStormsSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##orb_of_storms_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(140)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

    UI.WithDisable(self.settings.orbRadiusAuto, function()
        _, self.settings.orbRadius = ImGui.InputInt(label("Orb Radius", "orb_radius"), self.settings.orbRadius)
        UI.Tooltip("Radius around target/player used to count orbs. (1 meter = 10 range)")
    end)
    ImGui.SameLine()
    _, self.settings.orbRadiusAuto = ImGui.Checkbox(label("Auto", "orbRadiusAuto"), self.settings.orbRadiusAuto)

    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    _, self.settings.castOnSelf = ImGui.Checkbox(label("Cast on Self", "castOnSelf"), self.settings.castOnSelf)

    -- Limite d’orbes
    _, self.settings.useLimit = ImGui.Checkbox(label("Use Limit", "use_limit"), self.settings.useLimit)
    UI.WithDisableIndent(not self.settings.useLimit, function()
        _, self.settings.limit = ImGui.InputInt(label("Limit", "limit"), self.settings.limit)
        local items = { "Global", "Near Target/Player" }
        local idx = (self.settings.limitScope or 0)
        local changed, newIdx = ImGui.Combo(label("Limit Scope", "limit_scope"), idx, items, #items)
        if changed then self.settings.limitScope = newIdx end
        _, self.settings.minRecastMs = ImGui.InputInt(label("Min Recast (ms)", "min_recast"), self.settings.minRecastMs)
    end)

    _, self.settings.drawOrbs = ImGui.Checkbox(label("Draw Orbs", "drawOrbs"), self.settings.drawOrbs)
    ImGui.PopItemWidth()
end

function OrbOfStormsSkillHandler:onRenderD2D()
    if self.settings.drawOrbs then
        for _, orb in pairs(Infinity.PoE2.getActorsByType(EActorType_LimitedLifespan)) do
            if orb:getAnimatedMetaPath() == ORB_OF_STORMS_AO then
                Render.DrawWorldCircle(orb:getWorld(), self.settings.orbRadius * (250 / 23), "55FF0000", 4)
            end
        end
    end
end

return OrbOfStormsSkillHandler
