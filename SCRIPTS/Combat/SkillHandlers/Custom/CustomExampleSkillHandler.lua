local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local UI = require("CoreLib.UI")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

---@class PoE2Lib.Combat.SkillHandlers.RollingShatterSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.RollingShatterSkillHandler
local RollingShatterSkillHandler = SkillHandler:extend()

RollingShatterSkillHandler.shortName = "RollingShatter"
RollingShatterSkillHandler.description = [[
    Cast RollingSlam for the first slam in a sequence, then cancel the rest of the RollingSlam animation
    and immediately cast Boneshatter for subsequent slams. Sequence resets after timeout.
]]

-- Auto-detect ASID if you want; replace with real ASID to auto-select this handler
RollingShatterSkillHandler:setCanHandle(function(skill, stats, _, _, _, activeSkill, asid)
    -- replace with ASID you need, or remove to select manually in UI
    return asid == "__rollingslam_asid__"
end)

RollingShatterSkillHandler.settings = {
    sequence_timeout_ms = 2000,   -- window to consider slams part of same sequence
    min_interval_ms = 120,        -- minimal interval between casts
    skill_first = "RollingSlam",  -- first skill to cast (string name or id)
    skill_follow = "Boneshatter", -- follow-up skill to cast
    cancel_delay_ms = 120,        -- delay after the first slam hit before cancelling animation (tweak)
    debug = false,
}

-- Internal runtime state
function RollingShatterSkillHandler:init(skillId)
    RollingShatterSkillHandler.super.init(self, skillId)
    self._last_cast_time = 0
    self._in_sequence = false
    self._sequence_timer = nil
end

local now_ms = function()
    return (os.time() * 1000)
end

local function dbg(self, ...)
    if self.settings.debug then
        print("[RollingShatter] ", ...)
    end
end

-- === TODO: adapter functions ===
-- Replace these implementations with the concrete API calls from docpo/Infinity to:
-- 1) cast a skill by name/id
-- 2) cancel/interrupt the current skill animation/cast
function RollingShatterSkillHandler:doCast(skillName, target)
    -- TODO: replace with actual cast call (example placeholders):
    -- Player.CastSkillByName(skillName, target) or CombatUtils.castSkill(skillId, target)
    dbg(self, "doCast placeholder ->", skillName, target and target.Name or "no target")
    -- Example (pseudo) :
    -- local skillId = self:skillNameToId(skillName) -- if needed
    -- Game.CastSkill(skillId, target)
end

function RollingShatterSkillHandler:cancelCurrentAnimation()
    -- TODO: replace with actual cancel/interrupt call provided by engine
    -- Possible functions to use: CombatUtils.interruptAnimation(), Player:StopCasting(), etc.
    dbg(self, "cancelCurrentAnimation placeholder -> calling engine cancel")
    -- Example (pseudo):
    -- CombatUtils.interruptAnimation()
end
-- === end adapters ===

-- Base checks (keeps default logic)
function RollingShatterSkillHandler:canUse(target)
    local ok, reason = self:baseCanUse(target)
    if not ok then
        return false, reason
    end
    -- if skill needs a target:
    if target == nil then
        return false, "no target"
    end
    return true, nil
end

-- Simple getter for range if needed by framework
function RollingShatterSkillHandler:getCurrentMaxSkillDistance()
    return 60, true
end

-- Called by your ASID/animation detector when a slam event is observed.
-- target: the WorldActor hit/target (optional but recommended)
function RollingShatterSkillHandler:onSlam(target)
    local tnow = now_ms()
    -- If sequence expired, treat as first slam
    if not self._in_sequence or (tnow - (self._last_cast_time or 0) > self.settings.sequence_timeout_ms) then
        dbg(self, "Detected first slam of sequence")
        self._in_sequence = true
        self._last_cast_time = tnow
        -- Cast the first skill (RollingSlam)
        self:doCast(self.settings.skill_first, target)

        -- After a short delay to ensure the first slam hits, cancel the rest of the RollingSlam animation
        -- then immediately cast Boneshatter.
        local delay = math.max(0, self.settings.cancel_delay_ms) / 1000
        -- Use a coroutine/timer to schedule cancellation + follow-up cast
        -- The framework may provide a scheduler; if not, use a simple coroutine+wait implemented with the environment's wait function.
        -- Here we try to use a generic timer via CombatUtils if available, else fallback to coroutine + sleep (replace if needed).
        if CombatUtils and CombatUtils.schedule ~= nil then
            -- If the repo exposes a scheduler function
            CombatUtils.schedule(delay, function()
                dbg(self, "Timer fired -> cancelling animation + follow-up cast")
                self:cancelCurrentAnimation()
                -- small safety: avoid immediate double-cast if min_interval not met
                if (now_ms() - self._last_cast_time) >= self.settings.min_interval_ms then
                    self._last_cast_time = now_ms()
                    self:doCast(self.settings.skill_follow, target)
                else
                    dbg(self, "Skipped follow cast due to min_interval")
                end
            end)
        else
            -- Fallback: spawn coroutine that waits (requires environment support for Wait)
            -- If your engine provides Wait(ms) or Sleep(s) implement accordingly.
            local co = coroutine.create(function()
                -- Attempt engine sleep; replace 'os.execute' is not appropriate in game, so swap to actual Wait if provided.
                -- TODO: replace this block by the engine's async/timer API
                -- Example placeholder:
                -- Wait(delay) -> then execute
                dbg(self, "Fallback timer: waiting " .. tostring(delay) .. "s (you should replace with engine timer)")
                -- No real sleep here: immediate call (so you must adapt in your environment)
                self:cancelCurrentAnimation()
                if (now_ms() - self._last_cast_time) >= self.settings.min_interval_ms then
                    self._last_cast_time = now_ms()
                    self:doCast(self.settings.skill_follow, target)
                end
            end)
            -- try to resume immediately (not ideal); recommended to replace with engine scheduler
            local ok, err = coroutine.resume(co)
            if not ok then dbg(self, "coroutine resume error:", err) end
        end

        -- schedule sequence reset
        if CombatUtils and CombatUtils.schedule ~= nil then
            -- cancel previous if exists is left as exercise, but schedule a reset after timeout
            CombatUtils.schedule(self.settings.sequence_timeout_ms / 1000, function()
                dbg(self, "Sequence timeout expired -> reset")
                self._in_sequence = false
            end)
        else
            -- fallback: simply set a timestamp and let onSlam check the timeout
            -- nothing needed here because onSlam checks timestamps
        end
    else
        -- We're already in sequence: treat as follow-up (but normally we cancel animation after first so we cast follow immediately in the timer)
        dbg(self, "onSlam called while in sequence; may be redundant")
        -- Optionally cast follow here if you want immediate reaction on repeated onSlam events
        if (now_ms() - self._last_cast_time) >= self.settings.min_interval_ms then
            self._last_cast_time = now_ms()
            self:doCast(self.settings.skill_follow, target)
        else
            dbg(self, "Skipped follow cast due to min_interval")
        end
    end
end

-- Standard use() method that the framework might call when player asks to use the skill via handler
function RollingShatterSkillHandler:use(target)
    -- call onSlam to trigger the same behavior
    self:onSlam(target)
end

-- ImGui settings drawing
function RollingShatterSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##rolling_shatter_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(160)
    _, self.settings.sequence_timeout_ms = ImGui.InputInt(label("Sequence timeout (ms)", "timeout"), self.settings.sequence_timeout_ms)
    _, self.settings.min_interval_ms = ImGui.InputInt(label("Min interval (ms)", "minint"), self.settings.min_interval_ms)
    _, self.settings.cancel_delay_ms = ImGui.InputInt(label("Cancel delay (ms)", "canceldelay"), self.settings.cancel_delay_ms)
    _, self.settings.skill_first = ImGui.InputText(label("First skill", "first"), self.settings.skill_first)
    _, self.settings.skill_follow = ImGui.InputText(label("Follow skill", "follow"), self.settings.skill_follow)
    _, self.settings.debug = ImGui.Checkbox(label("Debug prints", "debug"), self.settings.debug)
    ImGui.PopItemWidth()
end

return RollingShatterSkillHandler
