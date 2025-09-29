local UI = require("CoreLib.UI")

local SkillHandler = require("PoE2Lib.Combat.SkillHandler")
local SkillStats = require("PoE2Lib.Combat.SkillStats")
local CastMethods = require("PoE2Lib.Combat.CastMethods")

local ZOMBIE_AO = "Metadata/Monsters/Zombies/PlayerSummoned/ZombiePlayerSummoned.ao"

---@class PoE2Lib.Combat.SkillHandlers.RaiseZombieSkillHandler : PoE2Lib.Combat.SkillHandler
---@overload fun(skillId: number): PoE2Lib.Combat.SkillHandlers.RaiseZombieSkillHandler
local RaiseZombieSkillHandler = SkillHandler:extend()

RaiseZombieSkillHandler.shortName = 'Raise Zombie'

RaiseZombieSkillHandler.description = [[
    This is a skill handler for Raise Zombie.
]]

RaiseZombieSkillHandler:setCanHandle(function(skill, stats, name, _, _, _, asid)
    return asid == "raise_zombie"
end)

RaiseZombieSkillHandler.settings = { --
    range = 80,
    canFly = true,
    summonCount = 20,
    summonCountAuto = true,
}

function RaiseZombieSkillHandler:onPulse()
    if self.settings.summonCountAuto then
        self.settings.summonCount = self:getStat(SkillStats.MaxZombies)
    end
end

---@param target WorldActor?
---@return boolean ok, string? reason
function RaiseZombieSkillHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target, { targetableCorpse = false })
    if not baseOk then
        return false, baseReason
    end

    if #self:getZombies() >= self.settings.summonCount then
        return false, "enough zombies"
    end

    if self:getPowerCharges() <= 0 and self:getTargetableCorpse(target, nil) == nil then
        return false, "cannot summon zombies"
    end

    return true, nil
end

function RaiseZombieSkillHandler:getZombies()
    local constructs = {}
    for _, actor in pairs(Infinity.PoE2.getLocalPlayer():getDeployedObjects()) do
        if actor:getAnimatedMetaPath() == ZOMBIE_AO then
            table.insert(constructs, actor)
        end
    end
    return constructs
end

function RaiseZombieSkillHandler:getPowerCharges()
    for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
        if buff:getKey() == "power_charge" then
            return buff:getCharges()
        end
    end
    return 0
end

---@param target WorldActor?
---@param location? Vector3
function RaiseZombieSkillHandler:use(target, location)
    if self:getPowerCharges() > 0 then
        CastMethods.Methods.DoAction(self, target, location)
        self:onUse()
        return
    end

    return self:super():use(target, location)
end

---@param key string
function RaiseZombieSkillHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##raise_zombie_skill_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    UI.WithDisable(self.settings.summonCountAuto, function()
        _, self.settings.summonCount = ImGui.InputInt(label("Summon Count", "summon_count"), self.settings.summonCount)
    end)
    ImGui.SameLine()
    _, self.settings.summonCountAuto = ImGui.Checkbox(label("Auto", "summon_count_auto"), self.settings.summonCountAuto)

    ImGui.PopItemWidth()
end

return RaiseZombieSkillHandler
