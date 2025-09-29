local UI = require("CoreLib.UI")
local Core_Settings = require("CoreLib.Settings")
local InstanceCache = require("PoE2Lib.InstanceCache")
local Events = require("PoE2Lib.Events")
local Conditions = require("PoE2Lib.Items.Conditions.Conditions")

local GOLD_METAPATH = "Metadata/Items/Currency/GoldCoin"

---@class PoE2Lib.Items.LootManager
local LootManager = {}

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

---@class PoE2Lib.Items.LootManager.Settings
local Settings = {
    Version = 1,

    ApplyLootFilter = false,
    LootGold = true,
    MinGoldAmount = 1,
    Rules = {},
    UniquesDDSToShouldLoot = {},
}
LootManager.Settings = Settings

Core_Settings.AddSettingsToHandlerVersioned("LootManager", Settings, {})

--------------------------------------------------------------------------------
-- External API
--------------------------------------------------------------------------------

---@alias PoE2Lib.Items.LootManager.CustomEvaluator (fun(item: ItemActor): boolean?)

---@type PoE2Lib.Items.LootManager.CustomEvaluator[]
local CustomEvaluators = {}

---@param item ItemActor
---@return boolean?
local function EvaluateUsingCustomEvaluators(item)
    local customEvaluation = nil
    for _, evaluator in ipairs(CustomEvaluators) do
        local result = evaluator(item)
        if result == false then
            return false
        elseif result == true then
            customEvaluation = true
        end
    end
    return customEvaluation
end

--- Adds a custom evalutor to the LootManager. The custom evaluators are called
--- before the loot rules are evaluated.
---
--- If the custom evaluator returns `true`, it will be looted unless another
--- custom evaluator returns `false`. If the custom evaluator returns `false`,
--- the item will be ignored regardless of the loot rules. If the custom
--- evaluator returns `nil`, the item will be looted according to the loot rules.
---
---@param evaluator PoE2Lib.Items.LootManager.CustomEvaluator
---@return PoE2Lib.Items.LootManager.CustomEvaluator evaluator
function LootManager.AddCustomEvaluator(evaluator)
    table.insert(CustomEvaluators, evaluator)
    return evaluator
end

--- Removes a custom evaluator from the LootManager.
---@param evaluator PoE2Lib.Items.LootManager.CustomEvaluator
function LootManager.RemoveCustomEvaluator(evaluator)
    for i = #CustomEvaluators, 1, -1 do
        if CustomEvaluators[i] == evaluator then
            table.remove(CustomEvaluators, i)
        end
    end
end

--------------------------------------------------------------------------------
-- Processing
--------------------------------------------------------------------------------

local Cache = InstanceCache {
    ---@type table<integer, {size: Vector2, name: string}>
    Loot = {},
    ---@type table<integer, Vector3>
    Gold = {},
}
LootManager.Cache = Cache

function LootManager.ProcessAllWorldItems()
    for _, actor in pairs(Infinity.PoE2.getActorsByType(EActorType_WorldItem)) do
        LootManager.ProcessActor(actor)
    end
end

---@param item ItemActor
function LootManager.ShouldLoot(item)
    if item:getRarity() == ERarity_Unique then
        -- Check if it is a unique with a dds we want to loot
        local dds = item:getDDSPath():match("([^/]+)$")
        if dds and Settings.UniquesDDSToShouldLoot[dds] then
            return true
        end
    end

    local customEvaluation = EvaluateUsingCustomEvaluators(item)
    if customEvaluation ~= nil then
        return customEvaluation
    end

    return Conditions.EvaluateItem(item, Settings.Rules) == Conditions.EVALUATE_RULE_RESULT.TRUE
end

---@private
---@param actor WorldActor
---@param item ItemActor
function LootManager.AddWantedLoot(actor, item)
    LootManager.Cache.Loot[actor:getActorId()] = {
        size = item:getItemSize(),
        name = item:getItemName(),
    }
end

---@private
---@param actor WorldActor
function LootManager.ProcessActor(actor)
    local item = actor:getItem()
    if item == nil then
        return
    end

    if Settings.ApplyLootFilter and actor:getAnimatedMetaPath() == "" then
        return
    end

    if item:getMetaPath() == GOLD_METAPATH then
        if item:getCurrentStackSize() >= Settings.MinGoldAmount then
            Cache.Gold[actor:getActorId()] = actor:getLocation()
        end
        return
    end

    if not LootManager.ShouldLoot(item) then
        return
    end

    LootManager.AddWantedLoot(actor, item)
end

do
    -- Process all world items at load
    LootManager.ProcessAllWorldItems()

    -- Process all world items when we enter a world area
    Events.OnInstanceCacheChange:register(LootManager.ProcessAllWorldItems)

    -- Process new world items
    Events.OnNewActor:register(function(actor)
        if actor:hasActorType(EActorType_WorldItem) then
            LootManager.ProcessActor(actor)
        end
    end)

    -- Remove loot when it's gone
    Events.OnForgetActor:register(function(actor)
        local actorId = actor:getActorId()
        Cache.Loot[actorId] = nil
        Cache.Gold[actorId] = nil
    end)
end

--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------

LootManager.TabBar = UI.TabBar()
    :add("General", "General loot settings", function()
        LootManager.DrawGeneralSettings()
    end)
    :add("Uniques", "Configure which uniques to loot!", function()
        LootManager.DrawUniquesSettings()
    end)
    :add("Rules", "A list with all your loot rules.", function()
        LootManager.DrawRuleOverview()
    end)
    :add("New Rule", "Add a new loot rule.", function()
        LootManager.DrawRuleEditor()
    end)

--- Draw the full LootManager UI.
function LootManager.DrawSettings()
    LootManager.TabBar:draw()
end

--------------------------------------------------------------------------------
-- General Settings
--------------------------------------------------------------------------------

---@type fun()[]
local GeneralSettingsExtensions = {}

--- This can be called to add additional settings to the general settings tab.
--- The provided function will be called when the general settings tab is drawn.
---@param extension fun()
function LootManager.AddGeneralSettingsExtension(extension)
    table.insert(GeneralSettingsExtensions, extension)
end

--- Draw the general settings tab.
---
--- Use `LootManager.DrawSettings()` to draw the full LootManager UI.
function LootManager.DrawGeneralSettings()
    Core_Settings.DrawImportButton("Import Loot Settings", { "LootManager" })

    if UI.WithTooltip(ImGui.Button("Refresh Loot"), "This will refresh all the loot. It can be used after you change loot settings to apply them to loot that has already dropped.") then
        Cache.Loot = {}
        Cache.Gold = {}
        LootManager.ProcessAllWorldItems()
    end

    _, Settings.ApplyLootFilter = ImGui.Checkbox("Apply Loot Filter", Settings.ApplyLootFilter)
    UI.Tooltip("If enabled, only loot that is visible by your loot filter will be looted. That means loot must match BOTH your loot rules and loot filter. The 'Hide Filtered Ground Items' setting must be enabled in the game settings.")

    _, Settings.LootGold = ImGui.Checkbox("Loot Gold >= ", Settings.LootGold)
    ImGui.SameLine()
    UI.WithDisable(not Settings.LootGold, function()
        UI.WithWidth(100, function()
            _, Settings.MinGoldAmount = ImGui.InputInt("##loot_gold_amount", Settings.MinGoldAmount)
        end)
    end)

    for _, extension in ipairs(GeneralSettingsExtensions) do
        extension()
    end
end

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------

local RuleEditor = require("PoE2Lib.Items.Conditions.RuleEditor")()
local RuleOverview = require("PoE2Lib.Items.Conditions.RuleOverview")()

--- Draw the rule overview.
---
--- Use `LootManager.DrawSettings()` to draw the full LootManager UI.
function LootManager.DrawRuleOverview()
    RuleOverview:Draw(Settings.Rules)
end

--- Draw the rule editor.
---
--- Use `LootManager.DrawSettings()` to draw the full LootManager UI.
function LootManager.DrawRuleEditor()
    RuleEditor:Draw(Settings.Rules)
end

--------------------------------------------------------------------------------
-- Uniques
--------------------------------------------------------------------------------

---@class(module) PoE2Lib.Items.LootManager.UniqueData
local UniquesData = {
    ---@type {DDS: string, ItemName: string}[]
    AllEntries = {},

    ---@type table<string, {DDS: string, ItemName: string}>
    ByDDS = {},
}
LootManager.UniquesData = UniquesData

do
    for dds, itemName in pairs(Infinity.PoE2.getDDSToItemNameMap()) do
        local unique = { DDS = dds, ItemName = itemName }
        table.insert(UniquesData.AllEntries, unique)
        UniquesData.ByDDS[dds] = unique
    end

    table.sort(UniquesData.AllEntries, function(a, b)
        return a.ItemName < b.ItemName
    end)
    print("Found " .. tostring(#UniquesData.AllEntries) .. " uniques to loot.")
end

Core_Settings.OnSettingsProfileLoaded:register(function()
    -- Update Settings to have all the possible uniques
    for _, unique in ipairs(UniquesData.AllEntries) do
        if Settings.UniquesDDSToShouldLoot[unique.DDS] == nil then
            Settings.UniquesDDSToShouldLoot[unique.DDS] = false
        end
    end

    -- Remove uniques that are no longer in the game
    for dds, _ in pairs(Settings.UniquesDDSToShouldLoot) do
        if not UniquesData.ByDDS[dds] then
            Settings.UniquesDDSToShouldLoot[dds] = nil
        end
    end
end)

local UniqueFilter = ""

--- Draw the uniques tab.
---
--- Use `LootManager.DrawSettings()` to draw the full LootManager UI.
function LootManager.DrawUniquesSettings()
    UI.Text("This feature is very new and experimental. This hasn't been tested on every unique!", "FFE04E0A")
    UI.TextDisabled("It can know which unique it is WITHOUT identifying them! (Black magic! Game doesn't provide this information.)")

    UI.TextDisabled("Filter", "FFCE790A")
    UI.WithIndent(function()
        _, UniqueFilter = ImGui.InputText("##unique_filter", UniqueFilter, 200)
    end)

    UI.TextDisabled("Uniques", "FFCE790A")
    UI.WithIndent(function()
        UI.CreateColumns({
            { Title = "Unique", Width = 300 },
            { Title = "Loot",   Width = 100 },
        }, { Id = "loot_manager_uniques_columns" })

        for _, entry in ipairs(UniquesData.AllEntries) do
            if UniqueFilter == "" or entry.ItemName:lower():find(UniqueFilter:lower()) or entry.DDS:lower():find(UniqueFilter:lower()) then
                ImGui.Text(entry.ItemName)
                UI.Tooltip(entry.DDS)
                UI.NextColumn()
                Settings.UniquesDDSToShouldLoot[entry.DDS] = UI.Checkbox("##loot_manager_loot_unique_" .. entry.DDS, not not Settings.UniquesDDSToShouldLoot[entry.DDS])
                UI.NextColumn()
            end
        end

        UI.EndColumns()
    end)
end

return LootManager
