--[[
EmberFusilladeSkillHandler
- Empile/maintient les Embers jusqu'au proc Wildshards.
- Respecte la fin du hover, ajoute un "launch grace" pour laisser partir les projectiles,
  ouvre une fenêtre de détection du proc, puis "hold" court avant de reprendre.
- Auto-déduction de la durée de hover (Stat -> lecture d'un Ember -> fallback manuel).
- AUCUN blocage Evade.
]]

local UI           = require("CoreLib.UI")
local Render       = require("CoreLib.Render")
local SkillHandler = require("PoE2Lib.Combat.SkillHandler")

-- Utils basiques
local function nowMs() return Infinity.Win32.GetTickCount() end
local function lc(s) return type(s) == "string" and s:lower() or "" end
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

---@class PoE2Lib.Combat.SkillHandlers.EmberFusilladeSkillHandler : PoE2Lib.Combat.SkillHandler
local EmberFusilladeSkillHandler = SkillHandler:extend()
EmberFusilladeSkillHandler.shortName = "Ember Fusillade"
EmberFusilladeSkillHandler.description = [[Maintain Embers until Wildshards procs; respect hover end, add launch grace, detect proc, hold, then resume.]]

-- Adapter si ton asid interne diffère
EmberFusilladeSkillHandler:setCanHandle(function(_, _, _, _, _, _, asid)
  return asid == "ember_fusillade"
end)

-- Patterns par défaut (adapter à ta data). Séparateur ';'
local DEFAULT_EMBER_PATTERNS = "ember_fusillade;ember/hover"
local DEFAULT_WILD_PATTERNS  = table.concat({
  "Metadata/Projectiles/BlazingCluster",
  "Metadata/Effects/Spells/fire_blazingcluster/projectile.ao",
  "Metadata/Effects/Spells/fire_blazingcluster/projectile_explosion.ao",
}, ";")

-- ========== Settings par défaut ==========
EmberFusilladeSkillHandler.settings = {
  -- Ciblage
  range       = 80,
  canFly      = false,
  castOnSelf  = true,

  -- Empilement d'Embers
  targetEmbers = 8,         -- seuil à atteindre avant "lâcher"
  maxEmbersCap = 12,        -- hard cap pour éviter l'overspam

  -- Hover auto
  hoverDurationAuto = true,               -- on tente l'auto
  hoverStatKey      = "EmberHoverDurationMs", -- stat SDK si dispo
  hoverDurationMs   = 755,                -- fallback manuel

  -- Timings
  refreshLeadMs   = 220,    -- on recast un peu avant la fin de hover pour maintenir
  launchGraceMs   = 140,    -- petite fenêtre post-hover pour laisser partir les projos
  minRecastMs     = 120,    -- anti-spam minimal entre 2 casts

  -- Détection proc Wildshards
  useWildProc          = true,
  wildDetectWindowMs   = 350,   -- fenêtre d'observation après "lâcher"
  procHoldMs           = 260,   -- on ne recast pas pendant ce hold si proc détecté

  -- Patterns de détection
  emberMetaPatterns = DEFAULT_EMBER_PATTERNS,
  wildMetaPatterns  = DEFAULT_WILD_PATTERNS,

  -- Debug / UI
  drawEmbers   = false,
  drawRadius   = 60,
  verbose      = false,
}

-- ========== State ==========
local effectiveHoverMs   = EmberFusilladeSkillHandler.settings.hoverDurationMs
local lastHoverProbeTick = 0

local lastCastAt         = 0
local graceUntil         = 0
local detectUntil        = 0
local holdUntil          = 0

local lastEmberSeenAt    = 0
local lastProcSeenAt     = 0

-- ========== Helpers: patterns ==========
local function parsePatterns(str)
  local out = {}
  if type(str) ~= "string" then return out end
  for pat in string.gmatch(str, "([^;]+)") do
    local p = lc((pat or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    if #p > 0 then table.insert(out, p) end
  end
  return out
end

local function metaContainsAny(actor, pats)
  if not actor or #pats == 0 then return false end
  local m = actor.getMetaPath and lc(actor:getMetaPath()) or ""
  if m == "" and actor.getName then m = lc(actor:getName()) end
  if m == "" then return false end
  for _, p in ipairs(pats) do
    if string.find(m, p, 1, true) then return true end
  end
  return false
end

-- ========== Itérateurs d'acteurs (à adapter à ton framework si besoin) ==========
function EmberFusilladeSkillHandler:iterateNearbyActors(radius)
  local list = self.world and self.world:getActorsInRange(self:getPlayer(), radius or 90) or {}
  local i, n = 0, #list
  return function()
    i = i + 1
    if i <= n then return list[i] end
  end
end

-- ========== Lecture hover (stat -> Ember -> fallback) ==========
function EmberFusilladeSkillHandler:_probeHoverMs()
  local t = nowMs()
  if t - lastHoverProbeTick < 200 then return effectiveHoverMs end
  lastHoverProbeTick = t

  -- 1) Stat directe
  if self.settings.hoverDurationAuto and self.getStat and self.settings.hoverStatKey and #self.settings.hoverStatKey > 0 then
    local ok, val = pcall(function() return self:getStat(self.settings.hoverStatKey) end)
    if ok and type(val) == "number" and val > 0 then
      effectiveHoverMs = clamp(val, 200, 3000)
      if self.settings.verbose then
        print(("[Ember] Hover via stat '%s' = %d ms"):format(self.settings.hoverStatKey, effectiveHoverMs))
      end
      return effectiveHoverMs
    end
  end

  -- 2) Lecture d’un Ember actif (LimitedLifespan, si exposé)
  if self.settings.hoverDurationAuto then
    for a in self:iterateNearbyActors(90) do
      -- Heuristique: un Ember correspond aux patterns emberMetaPatterns
      if metaContainsAny(a, parsePatterns(self.settings.emberMetaPatterns or "")) then
        local lifeMax, lifeLeft
        if a.getLimitedLifespan then
          local ls = a:getLimitedLifespan()
          if ls then
            lifeMax  = ls.getMaxMs and ls:getMaxMs() or nil
            lifeLeft = ls.getRemainMs and ls:getRemainMs() or nil
          end
        elseif a.getLifeTimes then
          -- Autre API possible
          local lt = a:getLifeTimes()
          lifeMax  = lt and lt.maxMs or nil
          lifeLeft = lt and lt.leftMs or nil
        end

        if type(lifeMax) == "number" and lifeMax > 0 then
          effectiveHoverMs = clamp(lifeMax, 200, 3000)
          if self.settings.verbose then
            print(("[Ember] Hover via LimitedLifespan = %d ms (remain=%s)"):format(effectiveHoverMs, tostring(lifeLeft)))
          end
          return effectiveHoverMs
        end
      end
    end
  end

  -- 3) Fallback manuel
  effectiveHoverMs = clamp(self.settings.hoverDurationMs or 755, 200, 3000)
  return effectiveHoverMs
end

-- ========== Comptage d'Embers & temps restant approximé ==========
function EmberFusilladeSkillHandler:getEmberCount()
  local emberPats = parsePatterns(self.settings.emberMetaPatterns or "")
  local count, list = 0, {}
  local minRemain = nil

  for a in self:iterateNearbyActors(90) do
    if metaContainsAny(a, emberPats) then
      count = count + 1
      table.insert(list, a)
      -- Estimation du temps restant si possible
      local left
      if a.getLimitedLifespan then
        local ls = a:getLimitedLifespan()
        left = ls and ls.getRemainMs and ls:getRemainMs() or nil
      end
      if type(left) == "number" then
        minRemain = (minRemain and math.min(minRemain, left)) or left
      end
    end
  end

  if count > 0 then lastEmberSeenAt = nowMs() end
  return count, list, minRemain -- minRemain peut être nil si API non dispo
end

-- ========== Détection du proc Wildshards ==========
function EmberFusilladeSkillHandler:detectWildProc()
  if not self.settings.useWildProc then return false end
  local pats = parsePatterns(self.settings.wildMetaPatterns or "")
  if #pats == 0 then return false end

  local t = nowMs()
  local seen = false
  for a in self:iterateNearbyActors(110) do
    if metaContainsAny(a, pats) then
      seen = true
      break
    end
  end
  if seen then
    lastProcSeenAt = t
    if self.settings.verbose then print("[Ember] Wildshards proc détecté") end
  end
  return seen
end

-- ========== Décision de cast ==========
function EmberFusilladeSkillHandler:tick(target)
  local t = nowMs()
  local hoverMs = self:_probeHoverMs()

  -- Etats temporisés
  local inGrace = (t < graceUntil)
  local inDetect= (t < detectUntil)
  local inHold  = (t < holdUntil)

  -- Comptage d'embers
  local count, _, minRemain = self:getEmberCount()
  local canCast = self:canCast() and (t - lastCastAt >= (self.settings.minRecastMs or 120))

  -- 1) Si on est en "hold" post-proc: on laisse partir, pas de cast
  if inHold then
    return
  end

  -- 2) Fenêtre de détection du proc: on scrute, mais on n’empile pas
  if inDetect then
    if self:detectWildProc() then
      holdUntil = t + (self.settings.procHoldMs or 260)
      detectUntil = 0
      if self.settings.verbose then print("[Ember] PASSAGE EN HOLD post-proc") end
      return
    end
    -- Fin de fenêtre sans proc: on retombera en routine normale après detectUntil
    return
  end

  -- 3) Fenêtre de grâce de lancement (juste après la fin du hover): pas de cast
  if inGrace then
    return
  end

  -- 4) Routine d’empilement/maintenance
  local targetEmbers = self.settings.targetEmbers or 8
  local maxCap       = self.settings.maxEmbersCap or math.max(targetEmbers, 12)
  local refreshLead  = self.settings.refreshLeadMs or 220
  local launchGrace  = self.settings.launchGraceMs or 140

  -- a) Si on n'a pas atteint le seuil, on empile
  if count < targetEmbers then
    if canCast then
      self:cast(target or self:getPlayer(), { range = self.settings.range, castOnSelf = self.settings.castOnSelf })
      lastCastAt = t
      return
    else
      return
    end
  end

  -- b) On est au seuil (ou au-dessus) -> on se prépare à "lâcher"
  -- Stratégie:
  -- - Tant que hover n'est pas en train d'expirer, on n’empile pas.
  -- - Quand on approche de la fin du hover (minRemain <= refreshLead), DEUX CAS:
  --     • Si on veut maintenir (count < maxCap), on peut refresh une fois AVANT la fin pour prolonger (stack lock).
  --     • Sinon, on s'arrête de caster juste AVANT la fin pour laisser partir: on ouvre grace -> detect.
  local remain = minRemain
  if type(remain) ~= "number" then
    -- Si on ne sait pas lire le temps restant, on approx: on force un cycle "lâcher"
    -- en se basant sur la dernière vue des embers.
    remain = math.max(0, hoverMs - (t - lastEmberSeenAt))
  end

  if remain <= refreshLead then
    -- Sommes-nous à cap ou non ?
    if count < maxCap then
      -- On peut refresh UNE fois si autorisé par anti-spam
      if canCast then
        self:cast(target or self:getPlayer(), { range = self.settings.range, castOnSelf = self.settings.castOnSelf })
        lastCastAt = t
        return
      else
        return
      end
    else
      -- On s'arrête de caster pour laisser les projectiles décoller
      graceUntil  = t + launchGrace
      detectUntil = self.settings.useWildProc and (t + (self.settings.wildDetectWindowMs or 350)) or 0
      if self.settings.verbose then
        print(("[Ember] LAUNCH: grace %d ms | detect %d ms"):format(launchGrace, self.settings.wildDetectWindowMs or 350))
      end
      return
    end
  else
    -- Trop tôt pour refresh (on maintient le stack sans recaster)
    return
  end
end

-- ========== UI ==========
function EmberFusilladeSkillHandler:drawSettings(key)
  local function label(title, id) return ("%s##ember_fus_%s_%s"):format(title, id, key) end
  ImGui.PushItemWidth(170)

  ImGui.Text("Ember Fusillade — Handler")
  ImGui.Separator()

  -- Ciblage
  _, self.settings.range      = ImGui.SliderInt(label("Range", "rng"), self.settings.range, 20, 120)
  _, self.settings.castOnSelf = ImGui.Checkbox(label("Cast on self", "self"), self.settings.castOnSelf)

  ImGui.Separator()
  ImGui.Text("Stacking")
  _, self.settings.targetEmbers = ImGui.SliderInt(label("Target Embers", "target"), self.settings.targetEmbers, 1, 20)
  _, self.settings.maxEmbersCap = ImGui.SliderInt(label("Max Embers Cap", "cap"), self.settings.maxEmbersCap, self.settings.targetEmbers, 30)

  ImGui.Separator()
  ImGui.Text("Hover duration")
  _, self.settings.hoverDurationAuto = ImGui.Checkbox(label("Auto (stat / probe)", "hoverauto"), self.settings.hoverDurationAuto)
  if self.settings.hoverDurationAuto then
    _, self.settings.hoverStatKey = ImGui.InputText(label("Stat Key", "hoverkey"), self.settings.hoverStatKey or "")
    ImGui.Text(string.format("Effective Hover: %d ms", effectiveHoverMs or 0))
  else
    _, self.settings.hoverDurationMs = ImGui.SliderInt(label("Hover Duration (ms)", "hoverms"), self.settings.hoverDurationMs, 300, 2000)
  end

  ImGui.Separator()
  ImGui.Text("Timings")
  _, self.settings.refreshLeadMs = ImGui.SliderInt(label("Refresh Lead (ms)", "lead"), self.settings.refreshLeadMs, 80, 600)
  _, self.settings.launchGraceMs = ImGui.SliderInt(label("Launch Grace (ms)", "grace"), self.settings.launchGraceMs, 60, 400)
  _, self.settings.minRecastMs   = ImGui.SliderInt(label("Min Recast (ms)", "minrc"), self.settings.minRecastMs, 60, 400)

  ImGui.Separator()
  ImGui.Text("Wildshards proc")
  _, self.settings.useWildProc        = ImGui.Checkbox(label("Detect Proc", "wild"), self.settings.useWildProc)
  _, self.settings.wildDetectWindowMs = ImGui.SliderInt(label("Detect Window (ms)", "wildwin"), self.settings.wildDetectWindowMs, 80, 600)
  _, self.settings.procHoldMs         = ImGui.SliderInt(label("Post-Proc Hold (ms)", "hold"), self.settings.procHoldMs, 100, 800)

  _, self.settings.wildMetaPatterns  = ImGui.InputText(label("Wild meta contains (;)", "wildmeta"), self.settings.wildMetaPatterns or DEFAULT_WILD_PATTERNS)
  _, self.settings.emberMetaPatterns = ImGui.InputText(label("Ember meta contains (;)", "embermeta"), self.settings.emberMetaPatterns or DEFAULT_EMBER_PATTERNS)

  ImGui.Separator()
  ImGui.Text("Debug")
  _, self.settings.drawEmbers = ImGui.Checkbox(label("Draw Embers", "draw"), self.settings.drawEmbers)
  _, self.settings.drawRadius = ImGui.SliderInt(label("Draw Radius", "drawrad"), self.settings.drawRadius, 20, 120)
  _, self.settings.verbose    = ImGui.Checkbox(label("Verbose logs", "verbose"), self.settings.verbose)

  ImGui.PopItemWidth()
end

-- ========== Render debug ==========
function EmberFusilladeSkillHandler:onRenderD2D()
  if not self.settings.drawEmbers then return end
  local _, list = self:getEmberCount()
  for _, e in ipairs(list) do
    local w = e.getWorld and e:getWorld()
    if w then
      Render.DrawWorldCircle(w, self.settings.drawRadius * (250/23), "FFFF5500", 3)
    end
  end
end

-- ========== Intégrations spéc. framework ==========
-- Hook "shouldDisableEvade" volontairement neutre (on ne bloque pas Evade)
function EmberFusilladeSkillHandler:shouldDisableEvade()
  return false
end

return EmberFusilladeSkillHandler
