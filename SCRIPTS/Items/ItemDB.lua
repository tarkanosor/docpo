local Table = require("CoreLib.Table")
local Conditions = require("PoE2Lib.Items.Conditions.Conditions")

---@class PoE2Lib.Items.ItemDB
local ItemDB = {
    ---@type BaseItemType[]
    ItemBases = {},

    --- Display names indexed by metapath
    ---@type table<string, string>
    ItemDisplayNames = {},

    ---@type ItemClass[]
    ItemClasses = {},

    ---@type table<string, BaseItemType[]>
    ItemBasesByClass = {},


    AllItemsClass = {
        ID = -1,
        getKey = function(self) return "ALLITEMS" end,
        getName = function(self) return "ALL ITEMS" end,
        getItemClassCategory = function(self) return nil end,
    },
}

local itemClassHasItems = {}
local itemBases_Name_Counts = {}
do
    for _, itemBase in pairs(Infinity.PoE2.getFileController():getBaseItemTypesFile():getAll()) do
        local name = itemBase:getName()
        if name and name ~= "" and not string.find(name, "UNUSED") then
            table.insert(ItemDB.ItemBases, itemBase)
            itemClassHasItems[itemBase:getItemClass():getKey()] = true
            itemBases_Name_Counts[name] = (itemBases_Name_Counts[name] or 0) + 1

            local itemClassKey = itemBase:getItemClass():getKey()
            ItemDB.ItemBasesByClass[itemClassKey] = ItemDB.ItemBasesByClass[itemClassKey] or {}
            table.insert(ItemDB.ItemBasesByClass[itemClassKey], itemBase)
        end
    end

    --- ItemBases are sorted by the engine. getBaseItemTypes() returns a sorted list so all entries in itemBases are already sorted
    -- table.sort(itemBases, function(a, b)
    --     return a.Name < b.Name
    -- end)

    -- Checking for duplicate names, and if yes, we add drop level
    for _, itemBase in ipairs(ItemDB.ItemBases) do
        local metaPath = itemBase:getMetaPath()
        local name = itemBase:getName()
        if itemBases_Name_Counts[name] > 1 then
            local metaPathEnd = metaPath:match("([^/]+)$")
            ItemDB.ItemDisplayNames[metaPath] = ("%s (%s | DL: %d)"):format(name, metaPathEnd, itemBase:getDropLevel())
        else
            ItemDB.ItemDisplayNames[metaPath] = name
        end
    end
end

-- TODO: Add ItemCategory Enum to engine and find ItemClassCategory Offset
-- local itemClassCategoryCounts = {}
do
    -- Filtering out unused item classes and making sure we can manipulate the table
    for _, itemClass in pairs(Infinity.PoE2.getFileController():getItemClassesFile():getAll()) do
        local name = itemClass:getName()
        if name and name ~= "" and not string.find(name, "UNUSED") and not string.find(name, "DONOTUSE") and not Table.FindIndex(Conditions.DeadItemClasses, itemClass:getKey()) then
            -- We do not want to display item classes that do not have any items
            if itemClassHasItems[itemClass:getKey()] then
                table.insert(ItemDB.ItemClasses, itemClass)
                -- itemClassCategoryCounts[itemClass.ItemClassCategory] = (itemClassCategoryCounts[itemClass.ItemClassCategory] or 0) + 1
            end
        end
    end

    table.sort(ItemDB.ItemClasses, function(a, b)
        -- We sort by Category, then by name
        return a:getName() < b:getName()
        -- Readd this if we want to sort by category

        -- if a.ItemCategory == b.ItemCategory then
        --     if itemClassCategoryCounts[a.ItemClassCategory] ~= itemClassCategoryCounts[b.ItemClassCategory] then
        --         return itemClassCategoryCounts[a.ItemClassCategory] > itemClassCategoryCounts[b.ItemClassCategory]
        --     end

        --     if a.ItemClassCategory == b.ItemClassCategory then
        --         return a.Name < b.Name
        --     end

        --     return a.ItemClassCategory < b.ItemClassCategory
        -- end

        -- return a.ItemCategory < b.ItemCategory
    end)

    table.insert(ItemDB.ItemClasses, 1, ItemDB.AllItemsClass)
end

return ItemDB
