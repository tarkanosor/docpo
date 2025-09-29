local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")

local BONE_CONSTRUCT_AO = "Metadata/Monsters/PitifulFabrications/PlayerSummoned/BoneConstructPlayerSummoned.ao"

---@class PoE2Lib.Combat.SkillHandlers.UnearthSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.UnearthSkillHandler
local UnearthSkillHandler = SkillHandler:extend()

UnearthSkillHandler.shortName = 'Unearth'

UnearthSkillHandler.description = [[
    This is a skill handler for Unearth.
]]

UnearthSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "bone_cone"
end)

UnearthSkillHandler.settings = { --
    range = 60,
    canFly = true,
    useOffensively = false,
    useSummons = true,
    summonCount = 20,
    summonCountAuto = true,
}

function UnearthSkillHandler:onPulse()
    if self.settings.summonCountAuto then
        self.settings.summonCount = self:getStat(SkillStats.NumberOfSkeletalConstructsAllowed)
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function UnearthSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target, { targetableCorpse = false })
    if not baseOk then
        return false, baseReason
    end

    if self.settings.useOffensively then
        if target ~= nil and self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            return true, "offensively"
        end
    end

    if self.settings.useSummons then
        local constructs = self:getBoneConstructs()
        if #constructs < self.settings.summonCount then
            if self:getTargetableCorpse(target, nil) ~= nil then
                return true, "need summons"
            end
        end
    end

    return false, "nope"
end

function UnearthSkillHandler:getBoneConstructs()
    local constructs = {}
    for _, actor in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
        if actor:getAnimatedMetaPath() == BONE_CONSTRUCT_AO then
            table.insert(constructs, actor)
        end
    end
    return constructs
end

---@param target WorldActor?
---@param location? Vector3
function UnearthSkillHandler:use(target, location)
    if self.settings.useSummons then
        if #self:getBoneConstructs() < self.settings.summonCount then
            local corpse = self:getTargetableCorpse(target, location)
            if corpse ~= nil then
                CastMethods.Methods.DoAction(self, nil, corpse:getLocation())
                self:onUse()
            end
        end
    end

    if self.settings.useOffensively then
        if target ~= nil and self:isInRange(target, self.settings.range, true, self.settings.canFly) then
            CastMethods.Methods.DoAction(self, nil, target:getLocation())
            self:onUse()
        end
    end
end

---@param key string
function UnearthSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##unearth_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    _, self.settings.useOffensively = ImGui.Checkbox(label("Use Offensively", "use_offensively"), self.settings.useOffensively)
    UI.Tooltip("Will use Unearth to damage the target.")

    _, self.settings.useSummons = ImGui.Checkbox(label("Use Summons", "use_summons"), self.settings.useSummons)
    UI.Tooltip("Will use Unearth to summon Skeletal Constructs.")
    UI.WithIndent(function()
        UI.WithDisable(self.settings.summonCountAuto, function()
            _, self.settings.summonCount = ImGui.InputInt(label("Summon Count", "summon_count"), self.settings.summonCount)
        end)
        ImGui.SameLine()
        _, self.settings.summonCountAuto = ImGui.Checkbox(label("Auto", "summon_count_auto"), self.settings.summonCountAuto)
    end)

    ImGui.PopItemWidth()
end

return UnearthSkillHandler
