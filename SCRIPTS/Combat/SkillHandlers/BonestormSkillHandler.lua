local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local UI          = require("CoreLib.UI")

-- Même anipath que dans OrbOfStorms handler (détection fiable)
local ORB_OF_STORMS_AO = "Metadata/Effects/Spells/storm_cloud/aoe_marker.ao"

---@class PoE2Lib.Combat.SkillHandlers.BonestormSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.BonestormSkillHandler
local BonestormSkillHandler = SkillHandler:extend()

BonestormSkillHandler.shortName = "Bonestorm"
BonestormSkillHandler.description = [[
    Cast Bonestorm only when enough Orb of Storms are active (same detection as the OOS handler).
    Channels for a fixed duration, then releases.
]]

-- On laisse le framework choisir le skill; ce handler est générique
BonestormSkillHandler:setCanHandle(function() return true end)

BonestormSkillHandler.settings = {
    -- Portée/LOS du cast
    range = 60,
    canFly = true,
    castOnSelf = false,

    -- Gating: nb d’Orb of Storms requis (0 = désactivé)
    requiredOrbs = 2,
    -- 0 = Global, 1 = Near Target/Player (même logique que ton OOS handler)
    orbScope = 0,
    orbRadius = 35,

    -- Canalisation
    channelDurationMs = 500,  -- durée fixe, pas de comptage de projectiles
    minRecastMs = 800,        -- anti-spam entre 2 casts
    cancelOnMove = false,     -- optionnel: annule si tu bouges pendant le channel

    -- Debug
    drawDebug = false,
}

-- Etat interne
local inChannel = false
local channelStart = 0
local lastCastTick = 0

-- ========= OOS helpers (copiés de l’OOS handler) =========

---@param centerLoc Vector3? @centre (nil => global)
---@param radius number?   @rayon (nil => global)
---@return integer
function BonestormSkillHandler:getOrbCount(centerLoc, radius)
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

---@param target WorldActor|nil
---@return integer
function BonestormSkillHandler:_countRelevantOrbs(target)
    if self.settings.orbScope == 0 then
        return self:getOrbCount(nil, nil)
    end
    local centerActor = self.settings.castOnSelf and Infinity.PoE2.getLocalPlayer() or target
    local center = centerActor and centerActor:getLocation() or nil
    if not center then return 0 end
    return self:getOrbCount(center, self.settings.orbRadius or 0)
end

---@param target WorldActor|nil
---@return boolean
function BonestormSkillHandler:_enoughOrbs(target)
    local need = tonumber(self.settings.requiredOrbs) or 0
    if need <= 0 then return true end
    local n = self:_countRelevantOrbs(target)
    if self.settings.drawDebug then
        print(string.format("[Bonestorm] OOS count=%d need=%d scope=%s radius=%d",
            n, need, (self.settings.orbScope==0 and "Global" or "Near"), self.settings.orbRadius or 0))
    end
    return n >= need
end

-- ========= Casting / Channel =========

function BonestormSkillHandler:canUse(target)
    -- Base checks (cooldown interne, mana, etc. du framework)
    local ok, reason = self:baseCanUse(target)
    if not ok then return false, reason end

    -- Cible / portée
    if not self.settings.castOnSelf then
        if not target then return false, "no target" end
        if not self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return false, "target out of range"
        end
    else
        if not Infinity.PoE2.getLocalPlayer() then
            return false, "player not found"
        end
    end

    -- Anti-spam simple
    if lastCastTick ~= 0 then
        local now = Infinity.Win32.GetTickCount()
        if (now - lastCastTick) < (self.settings.minRecastMs or 0) then
            return false, "recently cast"
        end
    end

    -- Gating par Orbs of Storms — identique à l’OOS handler
    if not self:_enoughOrbs(target) then
        return false, "not enough OOS"
    end

    return true, nil
end

function BonestormSkillHandler:use(target, location)
    -- Cast position
    local castPos
    if self.settings.castOnSelf then
        local lp = Infinity.PoE2.getLocalPlayer()
        if not lp then return end
        castPos = lp:getLocation()
    else
        if target then
            castPos = target:getLocation()
        else
            return
        end
    end

    -- Démarre la canalisation
    inChannel = true
    channelStart = Infinity.Win32.GetTickCount()

    -- Déclenchement (laisse le parent appuyer/maintenir selon le framework)
    self:super():use(target, castPos)
end

function BonestormSkillHandler:onTick()
    if not inChannel then return end

    local now = Infinity.Win32.GetTickCount()
    local elapsed = now - channelStart

    -- Option: annuler si le joueur bouge
    if self.settings.cancelOnMove then
        local lp = Infinity.PoE2.getLocalPlayer()
        local isMoving = lp and lp.isMoving and lp:isMoving()
        if isMoving then
            -- Essayer toutes les variantes possibles pour relâcher
            if self.stopChannel then pcall(function() self:stopChannel() end) end
            if self.release then pcall(function() self:release() end) end
            inChannel = false
            lastCastTick = now
            if self.settings.drawDebug then print("[Bonestorm] Channel cancelled (movement)") end
            return
        end
    end

    if elapsed >= (self.settings.channelDurationMs or 0) then
        -- Relâche la canalisation après la durée
        if self.stopChannel then pcall(function() self:stopChannel() end) end
        if self.release then pcall(function() self:release() end) end
        inChannel = false
        lastCastTick = now
        if self.settings.drawDebug then print("[Bonestorm] Channel finished") end
    end
end

function BonestormSkillHandler:getCurrentMaxSkillDistance()
    return self.settings.range or 0, self.settings.canFly
end

-- ========= UI =========

function BonestormSkillHandler:drawSettings(key)
    local function label(title, id) return ("%s##bonestorm_%s_%s"):format(title, id, key) end

    ImGui.PushItemWidth(160)
    _, self.settings.range = ImGui.InputInt(label("Range", "range"), self.settings.range)
    _, self.settings.canFly = ImGui.Checkbox(label("Can Fly", "canFly"), self.settings.canFly)
    _, self.settings.castOnSelf = ImGui.Checkbox(label("Cast on Self", "castOnSelf"), self.settings.castOnSelf)

    ImGui.Separator()
    _, self.settings.requiredOrbs = ImGui.SliderInt(label("Required OOS", "requiredOrbs"), self.settings.requiredOrbs, 0, 6)
    local scopeItems = { "Global", "Near Target/Player" }
    _, self.settings.orbScope = ImGui.Combo(label("OOS Scope", "orbScope"), self.settings.orbScope, scopeItems, #scopeItems)
    if self.settings.orbScope == 1 then
        _, self.settings.orbRadius = ImGui.SliderInt(label("Near Radius", "orbRadius"), self.settings.orbRadius, 5, 100)
    end

    ImGui.Separator()
    _, self.settings.channelDurationMs = ImGui.SliderInt(label("Channel Time (ms)", "channelMs"), self.settings.channelDurationMs, 100, 2000)
    _, self.settings.minRecastMs = ImGui.SliderInt(label("Min Recast (ms)", "minRecastMs"), self.settings.minRecastMs, 0, 3000)
    _, self.settings.cancelOnMove = ImGui.Checkbox(label("Cancel on Move", "cancelOnMove"), self.settings.cancelOnMove)

    ImGui.Separator()
    _, self.settings.drawDebug = ImGui.Checkbox(label("Verbose debug logs", "debug"), self.settings.drawDebug)
    ImGui.PopItemWidth()
end

return BonestormSkillHandler
