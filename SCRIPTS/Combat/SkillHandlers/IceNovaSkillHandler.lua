local UI = require("CoreLib.UI")
local Render = require("CoreLib.Render")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")

---@type table<string, string>
local FROSTBOLT_MTX_METAPATHS = { --
    ["None"] = "Metadata/Projectiles/GreaterFrostbolt",
}

---@class PoE2Lib.Combat.SkillHandlers.IceNovaSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.IceNovaSkillHandler
---@diagnostic disable-next-line: assign-type-mismatch
local IceNovaSkillHandler = SkillHandler:extend()

IceNovaSkillHandler.shortName = "Ice Nova"

IceNovaSkillHandler.description = [[
    This is a skill handler for Ice Nova. Set this skill with higher priority
    than Frostbolt if you're using FrostboltCombo mode.
]]

IceNovaSkillHandler:setCanHandle(function(skill, stats, name, _, _, activeSkill, asid)
    return asid == 'ice_nova'
end)

IceNovaSkillHandler.settings = { --
    range = 80,
    radius = 25,
    radiusAuto = true,
    radiusAutoMinus = 0,
    ---@type 'AoE'|'FrostboltCombo'
    skillMode = 'FrostboltCombo',
    ---@type 'OptimalClear'|'TargetOnly'
    frostboltMode = 'OptimalClear',
    frostboltMtx = "None",
    drawFrostbolts = false,
}

---@type WorldActor?
IceNovaSkillHandler.lastTargetableFrostboltActor = nil
---@type integer
IceNovaSkillHandler.lastTargetableFrostboltTick = 0

---@type WorldActor[]
IceNovaSkillHandler.lastGetFrostbolts = {}
---@type integer
IceNovaSkillHandler.lastGetFrostboltsTick = 0

---@type number
IceNovaSkillHandler.frostboltHash = 0

function IceNovaSkillHandler:onPulse()
    -- Update radius, because this can change during gameplay. In the settings,
    -- it's only updated when the settings are drawn.
    if self.settings.radiusAuto then
        self.settings.radius = (self:getStat(SkillStats.ActiveSkillAoERadius) - (self.settings.radiusAuto and self.settings.radiusAutoMinus or 0))
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function IceNovaSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    if self.settings.skillMode == 'AoE' then
        if target == nil then
            return false, "no target"
        end
        if not self:isInRange(target, self.settings.radius, true, true) then
            return false, "target out of range"
        end
    end

    if self.settings.skillMode == 'FrostboltCombo' then
        local frostbolt = self:getTargetableFrostbolt(target)
        if frostbolt == nil then
            return false, "no targetable Frostbolts"
        end
    end

    return true, nil
end

---@param target WorldActor?
---@param location? Vector3
function IceNovaSkillHandler:use(target, location)
    if self.settings.skillMode == 'AoE' then
        self:super():use(nil, nil)
    end

    if self.settings.skillMode == 'FrostboltCombo' then
        if self.settings.frostboltMode == "OptimalClear" then
            local frostbolt = self:getTargetableFrostbolt(target)
            if frostbolt == nil then
                return
            end
            self:super():use(frostbolt, nil)
            return
        end

        if self.settings.frostboltMode == "TargetOnly" then
            self:super():use(target, location)
            return
        end
    end
end

---@param target WorldActor?
---@param location? Vector3
---@return WorldActor?
function IceNovaSkillHandler:getTargetableFrostbolt(target, location)
    local now = Infinity.Win32.GetTickCount()
    if self.lastTargetableFrostboltTick ~= now then
        self.lastTargetableFrostboltActor = self:getTargetableFrostboltUncached(target, location)
        self.lastTargetableFrostboltTick = now
    end
    return self.lastTargetableFrostboltActor
end

---@param target WorldActor?
---@param location? Vector3
---@return WorldActor?
function IceNovaSkillHandler:getTargetableFrostboltUncached(target, location)
    location = location or (target and target:getLocation())
    if location == nil then
        return nil
    end

    if self.settings.frostboltMode == 'OptimalClear' then
        local bestFrostbolt, bestTargets = nil, 0
        for _, frostbolt in pairs(self:getFrostbolts()) do
            local targets = frostbolt:getCloseAttackableEnemyCount(self.settings.radius)
            if targets > bestTargets then
                bestFrostbolt, bestTargets = frostbolt, targets
            end
        end
        return bestFrostbolt
    end

    if self.settings.frostboltMode == 'TargetOnly' then
        for _, frostbolt in pairs(self:getFrostbolts()) do
            if location:getDistanceXY(frostbolt:getLocation()) < self.settings.radius and frostbolt:hasLineOfSightTo(location, false) then
                return frostbolt
            end
        end
        return nil
    end

    return nil
end

---@return WorldActor[]
function IceNovaSkillHandler:getFrostbolts()
    local now = Infinity.Win32.GetTickCount()
    if self.lastGetFrostboltsTick ~= now then
        self.lastGetFrostbolts = self:getFrostboltsUncached()
        self.lastGetFrostboltsTick = now
    end
    return self.lastGetFrostbolts
end

---@return WorldActor[]
function IceNovaSkillHandler:getFrostboltsUncached()
    local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
    local frostbolts = {}
    for _, frostbolt in pairs(Infinity.PoE2.getActorsByMetaPath(FROSTBOLT_MTX_METAPATHS[self.settings.frostboltMtx])) do
        if frostbolt:isMoving() and frostbolt:getLocation():getDistanceXY(pLoc) <= self.settings.range then
            -- Frostbolts that stop moving probably hit a wall or something.
            -- When they do, they will despawn and they're no longer a valid
            -- target for Ice Nova of Frostbolts. The actors will still remain
            -- for a bit, so we need to filter them out.
            table.insert(frostbolts, frostbolt)
        end
    end
    return frostbolts
end

--- Gets the current max distance skill can hit any target at.
---@return number Range, boolean canFly
function IceNovaSkillHandler:getCurrentMaxSkillDistance()
    if self.settings.skillMode == 'AoE' then
        return self.settings.radius or 0, true
    end
    if self.settings.skillMode == 'FrostboltCombo' then
        return self.settings.range or 0, true
    end
    return 0, true
end

---@param key string
function IceNovaSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##ice_nova_of_frostbolts_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)

    if UI.WithTooltip(ImGui.BeginCombo(label("Skill Mode", "skill_mode"), self.settings.skillMode), function()
        ImGui.BulletText("AoE: Will use Ice Nova around yourself.")
        ImGui.BulletText("FrostboltCombo: Will cast Ice Nova on Frostbolts")
    end) then
        for _, mode in ipairs({ "AoE", "FrostboltCombo" }) do
            if ImGui.Selectable(mode, self.settings.skillMode == mode) then
                self.settings.skillMode = mode
            end
        end
        ImGui.EndCombo()
    end

    UI.WithDisable(self.settings.skillMode ~= "FrostboltCombo", function()
        ImGui.Indent()
        if UI.WithTooltip(ImGui.BeginCombo(label("Frostbolt Mode", "frostbolt_mode"), self.settings.frostboltMode), function()
            ImGui.BulletText("OptimalClear: Will try to use the Frostbolt that will hit the most enemies. Will NOT focus the current target. (Worse performance)")
            ImGui.BulletText("TargetOnly: Only check the target for Frostbolts to use. (Better performance)")
        end) then
            for _, mode in ipairs({ 'OptimalClear', 'TargetOnly' }) do
                if ImGui.Selectable(mode, self.settings.frostboltMode == mode) then
                    self.settings.frostboltMode = mode
                end
            end
            ImGui.EndCombo()
        end
        ImGui.Unindent()
    end)

    UI.WithDisable(self.settings.radiusAuto, function()
        _, self.settings.radius = ImGui.InputInt(label("Radius", "radius"), self.settings.radius)
    end)
    UI.Tooltip("The radius around the Frostbolts to check for targets. This should be the radius of your Ice Nova of Frostbolts skill. (1 meters = 10 range)")
    ImGui.SameLine()
    _, self.settings.radiusAuto = ImGui.Checkbox(label("Auto", "radius_auto"), self.settings.radiusAuto)
    UI.Tooltip("Automatically set the radius to the radius of your Ice Nova of Frostbolts skill.")
    UI.WithDisable(not self.settings.radiusAuto, function()
        ImGui.SameLine()
        ImGui.Text("Minus")
        ImGui.SameLine()
        _, self.settings.radiusAutoMinus = ImGui.InputInt(label("Radius", "radius_auto_minus"), self.settings.radiusAutoMinus)
        UI.Tooltip("Subtract this value from the radius when using the auto radius feature.")
    end)
    if self.settings.radiusAuto then
        self.settings.radius = (self:getStat(SkillStats.ActiveSkillAoERadius) - (self.settings.radiusAuto and self.settings.radiusAutoMinus or 0))
    end

    -- if UI.WithTooltip(ImGui.BeginCombo(label("Frostbolt MTX", "mtx"), self.settings.frostboltMtx), "Select the MTX you are using for Frostbolt.") then
    --     for _, mtx in ipairs({"None"}) do
    --         if ImGui.Selectable(mtx, self.settings.frostboltMode == mtx) then
    --             local metapath = FROSTBOLT_MTX_METAPATHS[mtx]
    --             if metapath == nil then
    --                 error("Could not find metapath for Frostbolt MTX: " .. mtx)
    --                 return
    --             end
    --             self.settings.frostboltMtx = mtx
    --         end
    --     end
    --     ImGui.EndCombo()
    -- end

    _, self.settings.drawFrostbolts = ImGui.Checkbox(label("Draw Frostbolts", "draw_frostbolts"), self.settings.drawFrostbolts)

    ImGui.PopItemWidth()
end

function IceNovaSkillHandler:onRenderD2D()
    if self.settings.drawFrostbolts then
        for _, frostbolt in pairs(self:getFrostbolts()) do
            local color = "55FF0000"
            if self.lastTargetableFrostboltActor == frostbolt then
                color = "55FFFF00"
            end

            Render.DrawWorldCircle(frostbolt:getWorld(), self.settings.radius * 10.87, color, 4)
        end
    end
end

return IceNovaSkillHandler
