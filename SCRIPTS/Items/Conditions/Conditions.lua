---@diagnostic disable: duplicate-set-field, duplicate-doc-alias
local Class = require("CoreLib.Class")
local UI = require("CoreLib.UI")
local Table = require("CoreLib.Table")
local Color = require("CoreLib.Color")
local ServerData = require("PoE2Lib.Proxies.ServerData")


---@class PoE2Lib.Items.Conditions.Conditions
local Conditions = {}

---@enum CONDITION_STATE
CONDITION_STATE = { DISABLED = 0, REQUIRED = 1, NOT = 2 }

---@class ItemCondition : Class
ItemCondition = Class({})
ItemCondition.UniqueId = "Unnamed Item Condition"

function ItemCondition:init(uniqueId, evaluateActorFunction, drawFurtherSettingsFunction, drawOverviewInfo, isValidItemClassFunction, isValidBaseItemTypeFunction)
    self.UniqueId = uniqueId

    if evaluateActorFunction then
        self._EvaluateActor = evaluateActorFunction
    end

    if drawFurtherSettingsFunction then
        self._DrawFurtherSettings = drawFurtherSettingsFunction
    end

    if drawOverviewInfo then
        self._DrawOverviewInfo = drawOverviewInfo
    end

    if isValidItemClassFunction then
        self._IsValidForItemClass = isValidItemClassFunction
    end

    if isValidBaseItemTypeFunction then
        self._IsValidForBaseItemType = isValidBaseItemTypeFunction
    end
end

---@param item ItemActor
---@param settingsEntry table
---@return boolean
function ItemCondition:EvaluateActor(item, settingsEntry)
    if self._EvaluateActor then
        return self._EvaluateActor(item, settingsEntry)
    end

    return false
end

---@param itemClassData ItemClass
---@return boolean
function ItemCondition:IsValidForItemClass(itemClassData)
    if itemClassData:getKey() == "ALLITEMS" then
        return true
    end

    if self._IsValidForItemClass then
        return self._IsValidForItemClass(itemClassData)
    end

    return false
end

---@param baseItemType BaseItemType
function ItemCondition:IsValidForBaseItemType(baseItemType)
    if self._IsValidForBaseItemType then
        return self._IsValidForBaseItemType(baseItemType)
    end

    return self:IsValidForItemClass(baseItemType:getItemClass())
end

function ItemCondition:DrawFurtherSettings(settingsEntry)
    if self._DrawFurtherSettings then
        self._DrawFurtherSettings(settingsEntry)
    end
end

function ItemCondition:DrawOverviewInfo(settingsEntry)
    if self._DrawOverviewInfo then
        self._DrawOverviewInfo(settingsEntry)
    end
end

---@class Operator : Class
local Operator = Class()

function Operator:init(name, evaluationFunction)
    self.Name = name
    self._Evaluate = evaluationFunction
end

---@param left any
---@param right any
---@return boolean
function Operator:Evaluate(left, right)
    return self._Evaluate(left, right)
end

---@type table<string, Operator>
Conditions.Operators = {}

Conditions.Operators["<"] = Operator("<", function(left, right)
    return left < right
end)

Conditions.Operators["<="] = Operator("<=", function(left, right)
    return left <= right
end)

Conditions.Operators[">"] = Operator(">", function(left, right)
    return left > right
end)

Conditions.Operators[">="] = Operator(">=", function(left, right)
    return left >= right
end)

Conditions.Operators["=="] = Operator("==", function(left, right)
    return left == right
end)

Conditions.Operators["~="] = Operator("~=", function(left, right)
    return left ~= right
end)

local operatorNames = {}
for k, v in pairs(Conditions.Operators) do
    table.insert(operatorNames, v.Name)
end
table.sort(operatorNames)

---@param settingsEntry table
local function _DrawOperatorSelector(settingsEntry)
    if not settingsEntry.Operator then
        settingsEntry.Operator = ">="
    end

    local index = -1
    for i, v in ipairs(operatorNames) do
        if v == settingsEntry.Operator then
            index = i
            break
        end
    end
    ImGui.PushItemWidth(46)
    local newIndex = UI.Combo("##operator_combo_" .. tostring(settingsEntry), index, operatorNames, nil)
    ImGui.PopItemWidth()
    if newIndex ~= index then
        settingsEntry.Operator = operatorNames[newIndex]
    end
end

Conditions.DrawOperatorSelector = _DrawOperatorSelector

---@param left any
---@param right any
---@param operator Operator|string
local function _EvaluateOperator(left, right, operator)
    if operator then
        if type(operator) == "string" then
            operator = Conditions.Operators[operator]
        end

        return operator:Evaluate(left, right)
    else
        print("ERROR: Operator " .. tostring(operator) .. " not found")
    end

    return false
end

Conditions.EvaluateOperator = _EvaluateOperator

--- Debug Code that dumps all possible item classes into "itemclasses.txt"
-- do
-- local itemClasses = Infinity.PoE2.getFileController():getItemClassesFile():getAll()
-- local output = ""
-- for _, itemClass in pairs(itemClasses) do
--     output = output .. "\"" .. itemClass:getKey() .. "\",\n"
-- end

-- Infinity.FileSystem.WriteFile("itemclasses.txt", output)
-- end

Conditions.RollableItemClasses = {
    "TrapTool",
    "TowerAugmentation",
    "Thrown Two Hand Axe",
    "Thrown One Hand Axe",
    "One Hand Axe",
    "One Hand Mace",
    "One Hand Sword",
    "Bow",
    "Staff",
    "Two Hand Sword",
    "Two Hand Axe",
    "Two Hand Mace",
    "Buckler",
    "Flail",
    "Focus",
    "Crossbow",
    "Spear",
    "Warstaff",
    "Sceptre",
    "Shield",
    "Helmet",
    "Body Armour",
    "Boots",
    "Belt",
    "Quiver",
    "Gloves",
    "Amulet",
    "Ring",
    "Claw",
    "Dagger",
    "Wand",
    "ExpeditionLogbook",
    "AbyssJewel",
    "Jewel",
    "Map",
}

Conditions.SocketableItemClasses = Conditions.RollableItemClasses

Conditions.SkillGemItemClasses = {
    "Meta Skill Gem",
    "Support Skill Gem",
    "Active Skill Gem",
}

Conditions.FlaskItemClasses = {
    "LifeFlask",
    "ManaFlask",
    "UtilityFlask",
}

---Items that are always the same and cannot be changed
Conditions.HardcodedItemItemClasses = {
    "PinnacleKey",
    "Omen",
    "SoulCore",
    "UncutReservationGem",
    "UncutSupportGem",
    "UncutSkillGem",
    "UltimatumKey",
    "SkillGemToken",
    "ConventionTreasure",
    "VaultKey",
    "Breachstone",
    "SanctumSpecialRelic",
    "Relic",
    "InstanceLocalItem",
    "IncubatorStackable",
    "Incubator",
    "HiddenItem",
    "ItemisedSanctum",
    "UniqueFragment",
    "MiscMapItem",
    "MapFragment",
    "FishingRod",
    "Currency",
    "StackableCurrency",
    "QuestItem",
}

Conditions.NotEasyToDetermineItemClasses = {
}

Conditions.DeadItemClasses = {
    "Thrown Shield",
    "Nothing",
    "Crossbow Attachment REMOVE",
    "DONOTUSE12",
    "ArchnemesisMod",
    "Trinket",
    "DONOTUSE1",
    "DONOTUSE2",
    "DONOTUSE3",
    "DONOTUSE4",
    "DONOTUSE5",
    "DONOTUSE7",
    "DONOTUSE8",
    "DONOTUSE9",
    "DONOTUSE10",
    "DONOTUSE11",
    "HeistContract",
    "HeistEquipmentWeapon",
    "HeistEquipmentTool",
    "HeistEquipmentUtility",
    "HeistEquipmentReward",
    "HeistBlueprint",
    "AtlasUpgradeItem",
    "DelveStackableSocketableCurrency",
    "DelveSocketableCurrency",
    "MemoryLine",
    "SentinelDrone",
    "GiftBox",
    "HeistObjective",
    "UniqueShard",
    "UniqueShardBase",
    "IncursionItem",
    "PantheonSoul",
    "Leaguestone",
    "DivinationCard",
    "Microtransaction",
    "HideoutDoodad",
    "Unarmed",
    "SmallRelic",
    "MediumRelic",
    "LargeRelic",
    "Currency",
    "SkillGemToken",
}

---@type table<string, ItemCondition>
Conditions.Map = {}

---@type table<integer, ItemCondition>
Conditions.List = {}

---@param t table @Table with the following structure: {UniqueId = string, EvaluateActor = function, EvaluateWorldItemActorWrapper = function, DrawSettings = function, DrawOverviewInfo = function, IsValidForItemClass = function, IsValidForBaseItemType = function}
---@return ItemCondition
local function define(t)
    if not t.UniqueId then
        error("UniqueId is required")
    end

    if not t.EvaluateActor then
        error("EvaluateActor function is required")
    end

    local condition = ItemCondition(t.UniqueId, t.EvaluateActor, t.DrawSettings,
        t.DrawOverviewInfo, t.IsValidForItemClass, t.IsValidForBaseItemType)
    Conditions.Map[t.UniqueId] = condition

    table.insert(Conditions.List, condition)
    return condition
end

-- Item Size
local possibleSizes = { Vector2(1, 1), Vector2(1, 2), Vector2(1, 3), Vector2(2, 1), Vector2(2, 2), Vector2(2, 3), Vector2(
    2, 4) }
local possibleSizesNames = { "1x1", "1x2", "1x3", "2x1", "2x2", "2x3", "2x4" }

local function _GetSizeIndex(vec2)
    local index = -1
    for i, v in ipairs(possibleSizes) do
        if v.X == vec2.X and v.Y == vec2.Y then
            index = i
            break
        end
    end

    return index
end

local function _EvaluateItemSize(v1, v2, operator)
    -- print(v1.X, v1.Y, v2.X, v2.Y, operator.Name)
    -- First we do a complete check
    if operator:Evaluate(v1.X, v2.X) and operator:Evaluate(v1.Y, v2.Y) then
        return true
    end

    -- Now we check, if it applies to one and the other is ==, then we also return true
    if operator:Evaluate(v1.X, v2.X) and v1.Y == v2.Y then
        return true
    end

    if operator:Evaluate(v1.Y, v2.Y) and v1.X == v2.X then
        return true
    end


    return false
end

-- Item Size
define({
    UniqueId = "Item Size",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local size = itemActor:getItemSize()
        if size then
            if not settingsEntry.SizeX or not settingsEntry.SizeY then
                settingsEntry.SizeX = 2
                settingsEntry.SizeY = 3
            end

            local itemSize = size
            local settingsItemSize = Vector2(settingsEntry.SizeX, settingsEntry.SizeY)
            local operator = Conditions.Operators[settingsEntry.Operator]
            if operator then
                return _EvaluateItemSize(itemSize, settingsItemSize, operator)
            else
                print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
            end
            return false
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.SizeX or not settingsEntry.SizeY then
            settingsEntry.SizeX = 2
            settingsEntry.SizeY = 3
        end

        _DrawOperatorSelector(settingsEntry)

        UI.SameLine()

        local index = _GetSizeIndex(Vector2(settingsEntry.SizeX, settingsEntry.SizeY))

        local newIndex = UI.Combo("##item_size_combo_" .. tostring(settingsEntry), index, possibleSizesNames, nil)
        if newIndex ~= index then
            local newSize = possibleSizes[newIndex]
            settingsEntry.SizeX = newSize.X
            settingsEntry.SizeY = newSize.Y
        end
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        if not settingsEntry.SizeX or not settingsEntry.SizeY then
            settingsEntry.SizeX = 2
            settingsEntry.SizeY = 3
        end

        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.SizeX) .. "x" .. tostring(settingsEntry.SizeY))
    end,


    IsValidForItemClass = function(itemClass)
        -- pretty sure we only need this for all items, since all others seem to have a fixed size
        if itemClass:getKey() ~= "ALLITEMS" then
            return false
        end

        return true
    end,
})

-- Is Identified
define({
    UniqueId = "Identified",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local IsIdentified = itemActor:isIdentified()
        if IsIdentified == nil then
            -- If item does not have an identified state, we just say yes
            return true
        end

        return IsIdentified
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        ---Empty as we don't need any settings, it is a true or false condition
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Is Corrupted
define({
    UniqueId = "Corrupted",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        return itemActor:isItemCorrupted()
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        ---Empty as we don't need any settings, it is a true or false condition
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        if Table.FindIndex(Conditions.SkillGemItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Item Rarity
local possibleRarities = { ERarity_White, ERarity_Magic, ERarity_Rare, ERarity_Unique }
local possibleRaritiesNames = { "Normal", "Magic", "Rare", "Unique" }

define({
    UniqueId = "Item Rarity",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local rarity = itemActor:getRarity()
        if not rarity then
            rarity = ERarity_White
        end

        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(rarity, settingsEntry.ItemRarity)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.ItemRarity then
            settingsEntry.ItemRarity = ERarity_White
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()

        local index = -1
        for i, v in ipairs(possibleRarities) do
            if v == settingsEntry.ItemRarity then
                index = i
                break
            end
        end

        local newIndex = UI.Combo("##item_rarity_combo_" .. tostring(settingsEntry), index, possibleRaritiesNames, nil)
        if newIndex ~= index then
            settingsEntry.ItemRarity = possibleRarities[newIndex]
        end
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. possibleRaritiesNames[settingsEntry.ItemRarity + 1])
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        if Table.FindIndex(Conditions.FlaskItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Item Level
define({
    UniqueId = "Item Level",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local itemLevel = itemActor:getItemLevel()
        if itemLevel then
            local operator = Conditions.Operators[settingsEntry.Operator]
            if operator then
                return operator:Evaluate(itemLevel, settingsEntry.ItemLevel)
            else
                print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
            end
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.ItemLevel then
            settingsEntry.ItemLevel = 61
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.ItemLevel = UI.SliderInt("##item_level_" .. tostring(settingsEntry), settingsEntry.ItemLevel, 1,
            100)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.ItemLevel))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        if Table.FindIndex(Conditions.FlaskItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})


--- Base Item Level
define({
    UniqueId = "Base Level",

    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local baseItemLevel = itemActor:getBaseItemLevel()
        -- print("Base Item Level: " .. tostring(baseItemLevel))

        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(baseItemLevel, settingsEntry.BaseItemLevel)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.BaseItemLevel then
            settingsEntry.BaseItemLevel = 1
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.BaseItemLevel = UI.InputInt("Base Level:##drop_level_" .. tostring(settingsEntry), settingsEntry.BaseItemLevel, 1, 100)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.BaseItemLevel))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        return true
    end,
})

--- Item Quality
define({
    UniqueId = "Item Quality",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local quality = itemActor:getItemQuality()
        if quality then
            local operator = Conditions.Operators[settingsEntry.Operator]
            if operator then
                return operator:Evaluate(quality, settingsEntry.ItemQuality)
            else
                print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
            end
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.ItemQuality then
            settingsEntry.ItemQuality = 0
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.ItemQuality = UI.SliderInt("##item_quality_" .. tostring(settingsEntry), settingsEntry.ItemQuality, 0, 30)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.ItemQuality))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        if Table.FindIndex(Conditions.FlaskItemClasses, itemClass:getKey()) then
            return true
        end

        if Table.FindIndex(Conditions.SkillGemItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

--- Drop Level
define({
    UniqueId = "Drop Level",

    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local dropLevel = itemActor:getBaseItemType():getDropLevel()

        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(dropLevel, settingsEntry.DropLevel)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.DropLevel then
            settingsEntry.DropLevel = 1
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.DropLevel = UI.InputInt("Drop Level:##drop_level_" .. tostring(settingsEntry), settingsEntry.DropLevel, 1, 100)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.DropLevel))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        return true
    end,
})

-- Required Level
define({
    UniqueId = "Required Level",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local requiredLevel = itemActor:getRequiredLevel()
        if requiredLevel then
            local operator = Conditions.Operators[settingsEntry.Operator]
            if operator then
                return operator:Evaluate(requiredLevel, settingsEntry.RequiredLevel)
            else
                print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
            end
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.RequiredLevel then
            settingsEntry.RequiredLevel = 61
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.RequiredLevel = UI.SliderInt("##required_level_" .. tostring(settingsEntry),
            settingsEntry.RequiredLevel, 1, 100)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.RequiredLevel))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Is Relic
define({
    UniqueId = "Relic",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        return itemActor:isRelic()
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Is Synthetic
define({
    UniqueId = "Synthetic",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        return itemActor:isSynthetic()
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

-- Has Enchanted Mod
define({
    UniqueId = "Has Enchanted Mod",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local eMods = itemActor:getEnchantMods()
        if eMods then
            return Table.Length(eMods) > 0
        end

        return false
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.RollableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

--- Socket Count
define({
    UniqueId = "Socket Count",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local socketGroups = itemActor:getSocketGroups()
        if socketGroups then
            local operator = Conditions.Operators[settingsEntry.Operator]
            if operator then
                return operator:Evaluate(Table.Length(socketGroups), settingsEntry.SocketCount)
            else
                print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
            end
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.SocketCount then
            settingsEntry.SocketCount = 1
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.SocketCount = UI.SliderInt("##socket_count_" .. tostring(settingsEntry), settingsEntry.SocketCount,
            1, 6)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.SocketCount))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        if Table.FindIndex(Conditions.SocketableItemClasses, itemClass:getKey()) then
            return true
        end

        return false
    end,
})

--- Map Tiers
define({
    UniqueId = "Waystone Tier",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local mapTier = itemActor:getMapTier()
        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(mapTier, settingsEntry.MapTier)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.MapTier then
            settingsEntry.MapTier = 1
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.MapTier = UI.SliderInt("##map_tier_" .. tostring(settingsEntry), settingsEntry.MapTier, 1, 16)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.MapTier))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        return itemClass:getKey() == "Map"
    end,
})

--- Unidentified Tiers
define({
    UniqueId = "Unidentified Tier",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(itemActor:getUnidentifiedTier(), settingsEntry.UnidentifiedTier)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.UnidentifiedTier then
            settingsEntry.UnidentifiedTier = 1
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.UnidentifiedTier = UI.SliderInt("##unidentified_tier_" .. tostring(settingsEntry), settingsEntry.UnidentifiedTier, 1, 5)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.UnidentifiedTier))
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        local itemClassKey = itemClass:getKey()
        if Table.Contains(Conditions.RollableItemClasses, itemClassKey) then
            return true
        end

        return false
    end,
})

---
--- "Same Item in Stash Count" and "Same Item Class in Stash Count"
---

-- We maintain some cache for the stash count, so we don't have to query it every time
---@type table<string, integer>
local cachedItemsCountsInventory = {}
---@type table<string, integer>
local cachedItemCountsStash = {}
---@type table<string, integer>
local cachedItemsCountsGuildStash = {}

---@type table<string, integer>
local cachedItemClassCountInventory = {}
---@type table<string, integer>
local cachedItemClassesCountStash = {}
---@type table<string, integer>
local cachedItemClassesCountGuildStash = {}


---@return table<string, integer>, table<string, integer>, table<string, integer>
function Conditions.GetCachedItemLists()
    return cachedItemsCountsInventory, cachedItemCountsStash, cachedItemsCountsGuildStash
end

---@return table<string, integer>, table<string, integer>, table<string, integer>
function Conditions.GetCachedItemClassLists()
    return cachedItemClassCountInventory, cachedItemClassesCountStash, cachedItemClassesCountGuildStash
end

---@param item ItemActor
---@param cachedItemCounts table<string, integer>
local function processInventoryItem(item, cachedItemCounts, cachedItemClassCounts)
    local metaPath = item:getMetaPath()
    if not cachedItemCounts[metaPath] then
        cachedItemCounts[metaPath] = 0
    end

    local count = item:getCurrentStackSize()
    if count == 0 then -- non stackable items
        count = 1
    end

    cachedItemCounts[metaPath] = cachedItemCounts[metaPath] + count

    local itemClass = item:getBaseItemType():getItemClass():getKey()
    if itemClass then
        if not cachedItemClassCounts[itemClass] then
            cachedItemClassCounts[itemClass] = 0
        end

        cachedItemClassCounts[itemClass] = cachedItemClassCounts[itemClass] + count
    end
end

local function updateInventoryCache()
    cachedItemsCountsInventory = {}
    cachedItemClassCountInventory = {}

    local inventory = ServerData.getPlayerInventoryByType(EInventoryType_MainInventory)
    if inventory then
        local items = inventory:getInventoryItems()
        for _, item in pairs(items) do
            processInventoryItem(item, cachedItemsCountsInventory, cachedItemClassCountInventory)
        end
    end
end

local function updateStashCache()
    cachedItemCountsStash = {}
    cachedItemClassesCountStash = {}

    for _, inventory in pairs(ServerData.getStashInventories()) do
        if inventory then
            local items = inventory:getInventoryItems()
            for _, item in pairs(items) do
                processInventoryItem(item, cachedItemCountsStash, cachedItemClassesCountStash)
            end
        end
    end
end

local function updateGuildStashCache()
    cachedItemsCountsGuildStash = {}
    cachedItemClassesCountGuildStash = {}

    for _, inventory in pairs(ServerData.getGuildInventories()) do
        if inventory then
            local items = inventory:getInventoryItems()
            for _, item in pairs(items) do
                processInventoryItem(item, cachedItemsCountsGuildStash, cachedItemClassesCountGuildStash)
            end
        end
    end
end

local inventoryCacheDirty = true
Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnPlayerInventoryItemAdded",
    function() inventoryCacheDirty = true end
)

local function updateCache()
    if inventoryCacheDirty then
        updateInventoryCache()
        updateStashCache()
        updateGuildStashCache()
        inventoryCacheDirty = false
    end
end
Conditions.DebugUpdateCache = updateCache

---@enum OWNED_ITEM_COUNT_MODE
local OWNED_ITEM_COUNT_MODE = {
    STASH = 1,
    GUILD_STASH = 2,
    BOTH = 3,
    STASH_AND_INVENTORY = 4,
}

local OWNED_ITEM_COUNT_MODE_NAMES = { "Stash", "Guild Stash", "Stash + Guild Stash", "Stash + Inventory" }


define({
    UniqueId = "Same Item in Stash",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        updateCache()

        local metaPath = itemActor:getMetaPath()
        local mode = settingsEntry.Mode
        local count = 0
        if mode == OWNED_ITEM_COUNT_MODE.STASH then
            count = cachedItemCountsStash[metaPath] or 0
        elseif mode == OWNED_ITEM_COUNT_MODE.GUILD_STASH then
            count = cachedItemsCountsGuildStash[metaPath] or 0
        elseif mode == OWNED_ITEM_COUNT_MODE.BOTH then
            count = (cachedItemCountsStash[metaPath] or 0) + (cachedItemsCountsGuildStash[metaPath] or 0)
        elseif mode == OWNED_ITEM_COUNT_MODE.STASH_AND_INVENTORY then
            count = (cachedItemCountsStash[metaPath] or 0) + (cachedItemsCountsInventory[metaPath] or 0)
        end

        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(count, settingsEntry.Count)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.Count then
            settingsEntry.Count = 60
        end

        if not settingsEntry.Mode then
            settingsEntry.Mode = OWNED_ITEM_COUNT_MODE.STASH_AND_INVENTORY
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.Count = UI.SliderInt("##same_item_count_" .. tostring(settingsEntry), settingsEntry.Count, 1, 100)

        UI.Text("Mode: ")
        UI.SameLine()

        settingsEntry.Mode = UI.Combo("##same_item_count_mode_" .. tostring(settingsEntry), settingsEntry.Mode, OWNED_ITEM_COUNT_MODE_NAMES, nil)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.Count))
        UI.TextWrapped("Mode: ")
        UI.SameLine()
        UI.TextWrapped(OWNED_ITEM_COUNT_MODE_NAMES[settingsEntry.Mode], Color.DarkPink)
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        return true
    end,
})

define({
    UniqueId = "Same Item Class in Stash",
    ---@param itemActor ItemActor
    ---@param settingsEntry table
    EvaluateActor = function(itemActor, settingsEntry)
        updateCache()

        local itemClass = itemActor:getBaseItemType():getItemClass():getKey()
        local mode = settingsEntry.Mode
        local count = 0
        if mode == OWNED_ITEM_COUNT_MODE.STASH then
            count = cachedItemClassesCountStash[itemClass] or 0
        elseif mode == OWNED_ITEM_COUNT_MODE.GUILD_STASH then
            count = cachedItemClassesCountGuildStash[itemClass] or 0
        elseif mode == OWNED_ITEM_COUNT_MODE.BOTH then
            count = (cachedItemClassesCountStash[itemClass] or 0) + (cachedItemClassesCountGuildStash[itemClass] or 0)
        elseif mode == OWNED_ITEM_COUNT_MODE.STASH_AND_INVENTORY then
            count = (cachedItemClassesCountStash[itemClass] or 0) + (cachedItemClassCountInventory[itemClass] or 0)
        end

        local operator = Conditions.Operators[settingsEntry.Operator]
        if operator then
            return operator:Evaluate(count, settingsEntry.Count)
        else
            print("ERROR: Operator " .. tostring(settingsEntry.Operator) .. " not found")
        end

        return false
    end,

    ---@param settingsEntry table
    DrawSettings = function(settingsEntry)
        if not settingsEntry.Count then
            settingsEntry.Count = 60
        end

        if not settingsEntry.Mode then
            settingsEntry.Mode = OWNED_ITEM_COUNT_MODE.BOTH
        end

        _DrawOperatorSelector(settingsEntry)
        UI.SameLine()
        settingsEntry.Count = UI.SliderInt("##same_item_class_count_" .. tostring(settingsEntry), settingsEntry.Count, 1, 100)

        UI.Text("Mode: ")
        UI.SameLine()
        settingsEntry.Mode = UI.Combo("##same_item_class_count_mode_" .. tostring(settingsEntry), settingsEntry.Mode, OWNED_ITEM_COUNT_MODE_NAMES, nil)
    end,

    ---@param settingsEntry table
    DrawOverviewInfo = function(settingsEntry)
        UI.TextWrapped(settingsEntry.Operator .. " " .. tostring(settingsEntry.Count))
        UI.TextWrapped("Mode: ")
        UI.SameLine()
        UI.TextWrapped(OWNED_ITEM_COUNT_MODE_NAMES[settingsEntry.Mode], Color.DarkPink)
    end,

    ---@param itemClass ItemClass
    IsValidForItemClass = function(itemClass)
        return true
    end,
})

Conditions.DefineNew = define


-- Evaluate Rules
---@enum PoE2Lib.Items.Conditions.EVALUATE_RULE_RESULT
local EVALUATE_RULE_RESULT = { FALSE = 0, TRUE = 1, DOES_NOT_APPLY = 2 }
Conditions.EVALUATE_RULE_RESULT = EVALUATE_RULE_RESULT

---@param itemActor ItemActor
---@param rule table
function Conditions.EvaluateRule(itemActor, rule)
    local itemClass = itemActor:getBaseItemType():getItemClass()
    local itemName = itemActor:getItemName()
    local actorId = itemActor:getId()
    local baseMetaPath = itemActor:getBaseItemType():getMetaPath()

    local ruleApplies = false
    local itemClasses = rule.ItemClasses
    for _, requiredItemClassName in pairs(itemClasses) do
        --print("Checking " .. requiredItemClassName .. " against " .. itemClass:getKey())
        -- There are two incubator classes, and one is dead, so we do the extra check just to be sure
        if itemClass:getKey() == requiredItemClassName or requiredItemClassName == "ALLITEMS" then

            ruleApplies = true
            break
        end
    end

    if not ruleApplies then
        local itemBases = rule.ItemBases
        for _, itemBaseEntry in pairs(itemBases) do
            -- print("Checking " .. itemBaseEntry.MetaPath .. " against " .. baseMetaPath)
            if itemBaseEntry.MetaPath == baseMetaPath then
                ruleApplies = true
                break
            end
        end
    end

    if not ruleApplies then
        return EVALUATE_RULE_RESULT.DOES_NOT_APPLY
    end

    local conditions = rule.Conditions

    for uniqueId, condition in pairs(conditions) do
        local state = condition.State
        if state ~= CONDITION_STATE.DISABLED then
            local itemCondition = Conditions.Map[uniqueId]
            if itemCondition then
                local evaluation
                local function eval()
                    evaluation = itemCondition:EvaluateActor(itemActor, condition)
                end

                local status, err = pcall(eval)
                if not status then
                    print("ERROR: Condition " ..
                        tostring(uniqueId) ..
                        " failed to evaluate for item " ..
                        itemName .. " (Actor id: " .. tostring(actorId) .. ") with error: " .. err)
                    error(err)
                end

                -- print(state, "Evaluation of " .. uniqueId .. " for " .. itemClassName .. ": " .. tostring(evaluation), state == CONDITION_STATE.REQUIRED and not evaluation)

                if state == CONDITION_STATE.REQUIRED and not evaluation then
                    return EVALUATE_RULE_RESULT.FALSE
                elseif state == CONDITION_STATE.NOT and evaluation then
                    return EVALUATE_RULE_RESULT.FALSE
                end
            else
                print("ERROR: Condition " .. tostring(uniqueId) .. " not found")
            end
        end
    end

    return EVALUATE_RULE_RESULT.TRUE
end

local function getSortedRuleList(rules)
    local ruleList = {}

    for _, rule in pairs(rules) do
        table.insert(ruleList, rule)
    end

    table.sort(ruleList, function(a, b)
        -- We sort alphabetically by the ItemClasses (since order actually does not matter), however if the item class contains "ALL ITEMS", we put it at the end
        local aItemClasses = a.ItemClasses
        local bItemClasses = b.ItemClasses

        local aAllItems = Table.FindIndex(aItemClasses, "ALL ITEMS") ~= nil
        local bAllItems = Table.FindIndex(bItemClasses, "ALL ITEMS") ~= nil

        if aAllItems and not bAllItems then
            return false
        end

        if not aAllItems and bAllItems then
            return true
        end

        local aSortName = aItemClasses[1]
        if aSortName == nil then
            local aItemBase = a.ItemBases[1]
            if aItemBase then
                aSortName = aItemBase.Name
            end

            if aSortName == nil then
                aSortName = "ERROR"
            end
        end

        local bSortName = bItemClasses[1]
        if bSortName == nil then
            local bItemBase = b.ItemBases[1]
            if bItemBase then
                bSortName = bItemBase.Name
            end

            if bSortName == nil then
                bSortName = "ERROR"
            end
        end

        return aSortName < bSortName
    end)

    return ruleList
end

---@param itemActor ItemActor
---@param settings table
---@return integer result, table? rule
function Conditions.EvaluateItem(itemActor, settings)
    if not itemActor then
        return EVALUATE_RULE_RESULT.FALSE
    end

    local negativeRules = settings.NegativeRules
    if negativeRules then
        -- can be removed, but leaving it in should unexpected issues come up
        -- local sortedNegativeRules = getSortedRuleList(negativeRules)
        for _, rule in ipairs(negativeRules) do
            if Conditions.EvaluateRule(itemActor, rule) == EVALUATE_RULE_RESULT.TRUE and not (rule.Active ~= nil and not rule.Active) then
                return EVALUATE_RULE_RESULT.FALSE, rule
            end
        end
    end

    local positiveRules = settings.PositiveRules
    if positiveRules then
        -- can be removed, but leaving it in should unexpected issues come up
        -- local sortedPositiveRules = getSortedRuleList(positiveRules)
        for _, rule in ipairs(positiveRules) do
            -- print("Evaluating rule for item " .. itemActor:getItemName())
            -- print(Conditions.RuleToString(rule))
            if Conditions.EvaluateRule(itemActor, rule) == EVALUATE_RULE_RESULT.TRUE and not (rule.Active ~= nil and not rule.Active) then
                return EVALUATE_RULE_RESULT.TRUE, rule
            end
        end
    end

    return EVALUATE_RULE_RESULT.DOES_NOT_APPLY, nil
end

---@param itemActor  ItemActor
---@param settings table
---@return integer result, table<integer, RuleEditor.Rule> rules
function Conditions.EvaluateItemAllRules(itemActor, settings)
    if not itemActor then
        return EVALUATE_RULE_RESULT.FALSE, {}
    end

    local negativeRules = settings.NegativeRules
    if negativeRules then
        -- can be removed, but leaving it in should unexpected issues come up
        --local sortedNegativeRules = getSortedRuleList(negativeRules)
        for k, rule in ipairs(negativeRules) do
            if Conditions.EvaluateRule(itemActor, rule) == EVALUATE_RULE_RESULT.TRUE and not (rule.Active ~= nil and not rule.Active) then
                return EVALUATE_RULE_RESULT.FALSE, { rule }
            end
        end
    end

    local positiveRules = settings.PositiveRules
    local foundRules = {}
    if positiveRules then
        -- can be removed, but leaving it in should unexpected issues come up
        --local sortedPositiveRules = getSortedRuleList(positiveRules)

        for k, rule in ipairs(positiveRules) do
            if Conditions.EvaluateRule(itemActor, rule) == EVALUATE_RULE_RESULT.TRUE and not (rule.Active ~= nil and not rule.Active) then
                table.insert(foundRules, rule)
            end
        end
    end

    local res = #foundRules > 0 and EVALUATE_RULE_RESULT.TRUE or EVALUATE_RULE_RESULT.DOES_NOT_APPLY
    return res, foundRules
end

---@param rule table
function Conditions.RuleToString(rule)
    local result = "Item Classes:    "
    local itemClasses = rule.ItemClasses
    for _, requiredItemClassName in pairs(itemClasses) do
        result = result .. requiredItemClassName .. ", "
    end
    result = string.sub(result, 1, -3) .. "\n"

    result = result .. "Item Bases:   "
    local itemBases = rule.ItemBases
    for _, itemBaseEntry in pairs(itemBases) do
        result = result .. itemBaseEntry.Name .. ", "
    end
    result = string.sub(result, 1, -3) .. "\n"

    local conditions = rule.Conditions
    result = result .. "Conditions:  \n"
    for uniqueId, condition in pairs(conditions) do
        local itemCondition = Conditions.Map[uniqueId]
        if itemCondition then
            result = result .. "      " .. tostring(itemCondition.UniqueId) .. "\n"
        else
            result = result .. "      ERROR: Condition " .. tostring(uniqueId) .. " not found\n"
        end
    end

    return result
end

return Conditions
