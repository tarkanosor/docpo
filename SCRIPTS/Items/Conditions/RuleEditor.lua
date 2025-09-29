---@diagnostic disable: duplicate-doc-alias, duplicate-set-field
local Class = require("CoreLib.Class")
local UI = require("CoreLib.UI")
local Conditions = require("PoE2Lib.Items.Conditions.Conditions")
local Table = require("CoreLib.Table")
local Popup = require("CoreLib.Popup")
local Color = require("CoreLib.Color")
local ItemDB = require("PoE2Lib.Items.ItemDB")

---@class RuleEditor : Class
local RuleEditor = Class()

---@class RuleEditor.Rule
---@field Active boolean
---@field Conditions table<integer, ItemCondition>
---@field ItemClasses table<integer, string>
---@field ItemBases table<integer, {Name: string, MetaPath: string}>
---@field ExtraInformation table<string, table>

---@class RuleEditor.Settings
---@field PositiveRules table<integer, RuleEditor.Rule>
---@field NegativeRules table<integer, RuleEditor.Rule>

---@enum DisplayModes
local DisplayModes = { ItemClass = 1, ItemBase = 2 }
RuleEditor.DisplayMode = DisplayModes.ItemClass

RuleEditor.IsEditMode = false

function RuleEditor:init()
end

---@type table<integer, ItemCondition>
RuleEditor.AvailableConditions = {}

function RuleEditor:UpdateAvailableConditions()
    self.AvailableConditions = {}

    for _, itemCondition in ipairs(Conditions.List) do
        local added = false
        for _, itemClass in ipairs(self.SelectedItemClasses) do
            if itemClass:getKey() == "ALLITEMS" or itemCondition:IsValidForItemClass(itemClass) then
                table.insert(self.AvailableConditions, itemCondition)
                added = true
                break
            end
        end

        if not added then
            for _, itemBase in ipairs(self.SelectedItemBases) do
                if itemCondition:IsValidForBaseItemType(itemBase) then
                    table.insert(self.AvailableConditions, itemCondition)
                    break
                end
            end
        end
    end

    -- Update the currently build rule to remove conditions that are no longer available
    if not self.CurrentlyBuildRule.Conditions then
        self.CurrentlyBuildRule.Conditions = {}
    end

    local toRemoveIds = {}
    for uniqueId, _ in pairs(self.CurrentlyBuildRule.Conditions) do
        local found = false
        for _, availableCondition in ipairs(self.AvailableConditions) do
            if availableCondition.UniqueId == uniqueId then
                found = true
                break
            end
        end

        if not found then
            table.insert(toRemoveIds, uniqueId)
        end
    end

    for _, uniqueId in ipairs(toRemoveIds) do
        self.CurrentlyBuildRule.Conditions[uniqueId] = nil
    end
end

---@type table<integer,ItemClass>
RuleEditor.SelectedItemClasses = {}
---@type table<integer, BaseItemType>
RuleEditor.SelectedItemBases = {}

function RuleEditor:SelectItemClass(itemClass)
    for k, selectedItemClass in ipairs(self.SelectedItemClasses) do
        if selectedItemClass:getKey() == itemClass:getKey() then
            table.remove(self.SelectedItemClasses, k)
            self:UpdateAvailableConditions()
            return
        end
    end

    table.insert(self.SelectedItemClasses, itemClass)
    self:UpdateAvailableConditions()
end

---@param itemBase BaseItemType
---@param updateAvailableConditions boolean? Default true
function RuleEditor:SelectItemBase(itemBase, updateAvailableConditions)
    if updateAvailableConditions == nil then
        updateAvailableConditions = true
    end

    for k, selectedItemBase in ipairs(self.SelectedItemBases) do
        if selectedItemBase:getMetaPath() == itemBase:getMetaPath() then
            table.remove(self.SelectedItemBases, k)
            if updateAvailableConditions then
                self:UpdateAvailableConditions()
            end

            return
        end
    end

    table.insert(self.SelectedItemBases, itemBase)
    if updateAvailableConditions then
        self:UpdateAvailableConditions()
    end
end

---@param itemBases table<integer, BaseItemType>
function RuleEditor:SelectMultipleItemBases(itemBases)
    for _, itemBase in ipairs(itemBases) do
        table.insert(self.SelectedItemBases, itemBase)
    end

    -- Remove duplicates
    local seen = {}
    local toDelete = {}
    for i, itemBase in ipairs(self.SelectedItemBases) do
        if seen[itemBase:getMetaPath()] then
            table.insert(toDelete, i)
        else
            seen[itemBase:getMetaPath()] = true
        end
    end

    for i = #toDelete, 1, -1 do
        table.remove(self.SelectedItemBases, toDelete[i])
    end

    self:UpdateAvailableConditions()
end

function RuleEditor:ResetSelection()
    self.SelectedItemClasses = {}
    self.SelectedItemBases = {}
    self.AvailableConditions = {}
end

RuleEditor.ExpandedItemClass = nil
---@type BaseItemType[]
RuleEditor.ExpandedItemClass_ItemBases = {}
---@type string[]
RuleEditor.ExpandedItemClass_ItemBases_Names = {}

---@param itemClass ItemClass
function RuleEditor:ExpandItemClass(itemClass)
    self.DisplayMode = DisplayModes.ItemBase
    self.ExpandedItemClass = itemClass
    self.ExpandedItemClass_ItemBases = {}
    self.ExpandedItemClass_ItemBases_Names = {}

    local t = Infinity.Win32.GetPerformanceCounter()
    for _, itemBase in pairs(ItemDB.ItemBases) do
        if itemClass:getKey() == "ALLITEMS" or itemBase:getItemClass():getKey() == itemClass:getKey() then
            table.insert(self.ExpandedItemClass_ItemBases, itemBase)
            table.insert(self.ExpandedItemClass_ItemBases_Names, ItemDB.ItemDisplayNames[itemBase:getMetaPath()] or itemBase:getName())
        end
    end
    print("ExpandItemClass took: " .. tostring(Infinity.Win32.GetPerformanceCounter() - t) .. "ms")

    -- We do not need to sort, as itemBases is already sorted
end

function RuleEditor:ResetItemClassExpansion()
    self.DisplayMode = DisplayModes.ItemClass
    self.ExpandedItemClass = nil
    self.ExpandedItemClass_ItemBases = {}
end

local SELECTED_COLOR = "B8FF0000"
local ORANGE_COLOR = "B8FFA500"

---@type {Conditions: table<integer, table>, ItemClasses: table<integer, ItemClass>, ItemBases: table<integer, {Name: string, MetaPath: string}>, ExtraInformation: table<string, table>, Active: boolean}
RuleEditor.CurrentlyBuildRule = nil
function RuleEditor:ResetCurrentlyBuildRule()
    self.CurrentlyBuildRule = nil
    self.CurrentlyBuildRule = { Conditions = {}, ItemClasses = {}, ItemBases = {}, ExtraInformation = {} }
end

RuleEditor:ResetCurrentlyBuildRule()

RuleEditor.ItemClassFilter = ""

---@param width number
---@param settings RuleEditor.Settings
function RuleEditor:DrawItemClassSelector(width, settings)
    UI.Text("Item Class", ORANGE_COLOR)

    self.ItemClassFilter = UI.InputText("Filter: ##item_class_selector_" .. tostring(self) .. "_filter", self.ItemClassFilter)

    UI.Separator()
    ImGui.BeginChild("##rule_editor_main_child_" .. tostring(self), ImVec2(width - 20, 0))
    ImGui.Columns(2, "##item_class_selector_" .. tostring(self), false)
    local nameColumnWidth = math.max(width - 75, 100)
    ImGui.SetColumnWidth(0, nameColumnWidth)
    ImGui.SetColumnWidth(1, width - nameColumnWidth)

    local lastItemCategory = nil
    local lastItemClassCategory = nil
    local reachedOther = false

    local filterLower = self.ItemClassFilter and string.lower(self.ItemClassFilter)
    for _, itemClassData in ipairs(ItemDB.ItemClasses) do
        if not filterLower or filterLower == "" or string.find(string.lower(itemClassData:getName()), filterLower) then
            ---Categorization headers
            -- local itemCategory = itemClassData.ItemCategory
            -- local itemClassCategory = itemClassData.ItemClassCategory
            -- if itemCategory == EItemCategory_Other then
            --     if lastItemClassCategory ~= itemClassCategory then
            --         local shouldDoHeader = false
            --         -- local shouldDoHeader = itemClassCategoryCounts[itemClassCategory] > 1
            --         local headerText = itemClassData.ItemClassCategoryS
            --         if not shouldDoHeader and not reachedOther then
            --             shouldDoHeader = true
            --             reachedOther = true
            --             headerText = "Other"
            --         end

            --         if shouldDoHeader then
            --             -- print("Doing header for " .. headerText .. " because " .. tostring(lastItemClassCategory) .. " ~= " .. tostring(itemClassCategory))
            --             UI.Separator()
            --             UI.WithDisable(true, function()
            --                 UI.Text(headerText, "FFF0A254")
            --             end)
            --             ImGui.NextColumn()
            --             ImGui.NextColumn()
            --         end

            --         lastItemClassCategory = itemClassCategory
            --     end
            -- else
            --     if itemCategory ~= lastItemCategory then
            --         lastItemCategory = itemCategory
            --         if itemCategory ~= -1 then
            --             -- We do special handling for "Other" and "Other2"
            --             if lastItemCategory ~= nil then
            --                 UI.Separator()
            --             end
            --             UI.WithDisable(true, function()
            --                 UI.Text(Infinity.PoE2.Enums.EItemCategory.getTextByEnum(itemCategory) or "EMPTY", "FFF0A254")
            --             end)
            --             ImGui.NextColumn()
            --             ImGui.NextColumn()
            --         end
            --     end
            -- end

            -- Actual entries
            local isSelected = false
            for _, selectedItemClass in ipairs(self.SelectedItemClasses) do
                if selectedItemClass:getKey() == itemClassData:getKey() then
                    isSelected = true
                    break
                end
            end

            local color = isSelected and SELECTED_COLOR or ORANGE_COLOR
            -- UI.Text(itemClassData:getName() .. " ( IC: " .. tostring(itemCategory) .. "| ICC:" .. tostring(itemClassCategory) .. " )", color)
            -- UI.Text("broken iclass")
            UI.Text(itemClassData:getName(), color)
            if ImGui.IsItemClicked() then
                -- print(itemClassData:getName())
                -- print(itemClassData:getKey())
                self:SelectItemClass(itemClassData)
            end

            ImGui.NextColumn()
            if UI.Button(">##item_class_selector_" .. tostring(self) .. "_" .. tostring(itemClassData:getKey()), ORANGE_COLOR) then
                self:ExpandItemClass(itemClassData)
            end
            ImGui.NextColumn()
        end
    end

    ImGui.Columns(1)
    ImGui.EndChild()
end

RuleEditor.ItemBaseFilter = ""

---@param itemBase BaseItemType
---@param displayName string
---@param filter string
---@return boolean
local function passesItemBaseFilter(itemBase, displayName, filter)
    if not filter or filter == "" then
        return true
    end

    local filterLower = filter and string.lower(filter)
    if not filterLower then
        return true
    end

    if filterLower == "" then
        return true
    end

    if string.find(string.lower(itemBase:getName()), filterLower) then
        return true
    end

    if string.find(string.lower(displayName), filterLower) then
        return true
    end

    return false
end

---@param width number
---@param settings RuleEditor.Settings
function RuleEditor:DrawItemBaseSelector(width, settings)
    UI.Text("Item Base", ORANGE_COLOR)
    if self.ExpandedItemClass then
        if UI.Button("<##item_base_selector_" .. tostring(self) .. "_reset", ORANGE_COLOR) then
            self:ResetItemClassExpansion()
            return
        end
        UI.SameLine()
        UI.Text(self.ExpandedItemClass:getName(), ORANGE_COLOR)
    end
    UI.SameLine()
    if UI.Button("Select All Visible") then
        local toSelect = {}
        for i, itemBase in ipairs(self.ExpandedItemClass_ItemBases) do
            local displayName = self.ExpandedItemClass_ItemBases_Names[i]
            if passesItemBaseFilter(itemBase, displayName, self.ItemBaseFilter) then
                table.insert(toSelect, itemBase)
            end
        end

        self:SelectMultipleItemBases(toSelect)
    end

    self.ItemBaseFilter = UI.InputText("Filter: ##item_base_selector_" .. tostring(self) .. "_filter", self.ItemBaseFilter)
    UI.Separator()
    ImGui.BeginChild("##rule_editor_item_bases_child_" .. tostring(self), ImVec2(width - 20, 0))

    for i, itemBase in ipairs(self.ExpandedItemClass_ItemBases) do
        local displayName = self.ExpandedItemClass_ItemBases_Names[i]
        if passesItemBaseFilter(itemBase, displayName, self.ItemBaseFilter) then
            local isSelected = false
            for _, selectedItemBase in ipairs(self.SelectedItemBases) do
                if selectedItemBase:getMetaPath() == itemBase:getMetaPath() then
                    isSelected = true
                    break
                end
            end

            local color = isSelected and SELECTED_COLOR or ORANGE_COLOR
            UI.Text(displayName, color)
            if ImGui.IsItemClicked() then
                self:SelectItemBase(itemBase)
            end
        end
    end

    ImGui.EndChild()
end

function RuleEditor:PrepareRule()
    if self.CurrentlyBuildRule.Active == nil then
        self.CurrentlyBuildRule.Active = true
    end
    if not self.CurrentlyBuildRule.ItemClasses then
        self.CurrentlyBuildRule.ItemClasses = {}
    end
    for _, itemClass in ipairs(self.SelectedItemClasses) do
        table.insert(self.CurrentlyBuildRule.ItemClasses, itemClass:getKey())
    end

    if not self.CurrentlyBuildRule.ItemBases then
        self.CurrentlyBuildRule.ItemBases = {}
    end

    for _, itemBase in ipairs(self.SelectedItemBases) do
        table.insert(self.CurrentlyBuildRule.ItemBases, { Name = itemBase:getName(), MetaPath = itemBase:getMetaPath() })
    end

    ---Remove disabled rules
    local toRemove = {}
    for uniqueId, condition in pairs(self.CurrentlyBuildRule.Conditions) do
        if condition.State == CONDITION_STATE.DISABLED then
            table.insert(toRemove, uniqueId)
        end
    end

    for _, uniqueId in ipairs(toRemove) do
        self.CurrentlyBuildRule.Conditions[uniqueId] = nil
    end

    -- Process custom configuration entries.
    if not self.CurrentlyBuildRule.ExtraInformation then
        self.CurrentlyBuildRule.ExtraInformation = {}
    end
    for _, custom in ipairs(self.CustomConfigurations or {}) do
        local entryName, entryTable = custom.generateFn()
        if entryName and entryTable then
            self.CurrentlyBuildRule.ExtraInformation[entryName] = entryTable
        end
    end
end

RuleEditor.LastRuleMessage = nil

---@param settings RuleEditor.Settings
function RuleEditor:AddRule(settings, callback)
    if not settings.PositiveRules then
        settings.PositiveRules = {}
    end

    self:PrepareRule()
    table.insert(settings.PositiveRules, self.CurrentlyBuildRule)
    self:ResetCurrentlyBuildRule()

    self.LastRuleMessage = "Successfully added rule!"
    if callback then
        callback.fn(table.unpack(callback.args))
    end
end

-- Add flag to allow only positive rules
RuleEditor.OnlyPositiveRules = false

---@param settings RuleEditor.Settings
function RuleEditor:AddIgnoreRule(settings)
    if self.OnlyPositiveRules then
        -- Do nothing if only positive rules are allowed
        return
    end
    if not settings.NegativeRules then
        settings.NegativeRules = {}
    end

    self:PrepareRule()
    table.insert(settings.NegativeRules, self.CurrentlyBuildRule)
    self:ResetCurrentlyBuildRule()
    self.LastRuleMessage = "Successfully added ignore rule!"
end

function RuleEditor:DrawConditions(width, settings, callback)
    UI.Text("Selected Item Classes And Bases", ORANGE_COLOR)
    UI.SameLine()
    if UI.Button("Clear Selection") then
        self:ResetSelection()
    end

    local childWidth = width - 40

    ImGui.BeginChild("##rule_editor_conditions_itemclassandbase_child_" .. tostring(self), ImVec2(childWidth, 100), ImGuiChildFlags_Borders)
    local columnWidth = width / 2 - 5
    UI.CreateColumns({ { Title = "Item Class", Width = columnWidth }, { Title = "Item Base", Width = columnWidth } })
    local selectedItemClassCount = #self.SelectedItemClasses
    local selectedItemBaseCount = #self.SelectedItemBases
    local maxI = math.max(selectedItemClassCount, selectedItemBaseCount)
    for i = 1, maxI do
        local itemClass = self.SelectedItemClasses[i]
        local itemBase = self.SelectedItemBases[i]
        if itemClass then
            UI.Text(itemClass:getName())
        else
            UI.Text("")
        end
        UI.NextColumn()
        if itemBase then
            UI.Text(itemBase:getName())
        else
            UI.Text("")
        end
        UI.NextColumn()
    end

    UI.EndColumns()
    ImGui.EndChild()
    local buttonColor = "FFA47405"

    UI.Text("Conditions", ORANGE_COLOR)
    ImGui.BeginChild("##rule_edtir_conditons_columns_child_" .. tostring(self), ImVec2(childWidth, UI.GetAvailableHeight() - 40), ImGuiChildFlags_Borders)
    ImGui.Columns(3, "##conditions_column_" .. tostring(self), true)
    ImGui.SetColumnWidth(0, 200)
    local leftOver = childWidth - 200
    ImGui.SetColumnWidth(1, math.max(leftOver * 0.40, 125))
    ImGui.SetColumnWidth(2, math.max(leftOver * 0.60, 200))

    if not self.CurrentlyBuildRule.Conditions then
        self.CurrentlyBuildRule.Conditions = {}
    end

    local ruleConditions = self.CurrentlyBuildRule.Conditions

    for _, itemCondition in ipairs(self.AvailableConditions) do
        -- Firstly we want a "Ignore", "Required" and "Not" selector
        if not ruleConditions[itemCondition.UniqueId] then
            ruleConditions[itemCondition.UniqueId] = { State = CONDITION_STATE.DISABLED }
        end

        local state = ruleConditions[itemCondition.UniqueId].State
        local enabledColor = "FF9E0505"
        if UI.Button("Ignore##ignore_button_" .. tostring(self) .. tostring(itemCondition.UniqueId), state == CONDITION_STATE.DISABLED and enabledColor or buttonColor) then
            ruleConditions[itemCondition.UniqueId].State = CONDITION_STATE.DISABLED
        end

        UI.SameLine()

        if UI.Button("Required##required_button_" .. tostring(self) .. tostring(itemCondition.UniqueId), state == CONDITION_STATE.REQUIRED and enabledColor or buttonColor) then
            ruleConditions[itemCondition.UniqueId].State = CONDITION_STATE.REQUIRED
        end

        UI.SameLine()

        if UI.Button("Prohibited##prohibited_button_" .. tostring(self) .. tostring(itemCondition.UniqueId), state == CONDITION_STATE.NOT and enabledColor or buttonColor) then
            ruleConditions[itemCondition.UniqueId].State = CONDITION_STATE.NOT
        end

        ImGui.NextColumn()
        UI.TextWrapped(itemCondition.UniqueId, ORANGE_COLOR)
        ImGui.NextColumn()
        itemCondition:DrawFurtherSettings(ruleConditions[itemCondition.UniqueId])
        ImGui.NextColumn()
        UI.Separator()
    end
    ImGui.Columns(1)

    ImGui.EndChild()

    ---Control buttons
    ImGui.BeginChild("##rule_editor_control_buttons_child_" .. tostring(self), ImVec2(childWidth, 0))
    ImGui.Dummy(ImVec2(0, 7))
    local didCreateRule = false
    if self.IsEditMode then
        if UI.Button("Save Rule", buttonColor) then
            self:PrepareRule()
            didCreateRule = true
        end
    else

        if UI.Button("Add Rule", buttonColor) then
            self:AddRule(settings, callback)
            didCreateRule = true
        end

        if not self.OnlyPositiveRules then
            UI.SameLine()

            if UI.Button("Add Ignore Rule", buttonColor) then
                self:AddIgnoreRule(settings)
                didCreateRule = true
            end
        end
    end
    ImGui.EndChild()

    return didCreateRule
end

RuleEditor.SelectorWidthPct = 0.4
RuleEditor.ItemClassWidthPct = 0.3
RuleEditor.AnimationPctStep = 0.025
RuleEditor.MinimalWidth = 450
function RuleEditor:AnimationProcessing()
    if self.DisplayMode == DisplayModes.ItemClass then
        if self.ItemClassWidthPct < (self.SelectorWidthPct - 0.1) then
            self.ItemClassWidthPct = self.ItemClassWidthPct + self.AnimationPctStep
        else
            self.ItemClassWidthPct = (self.SelectorWidthPct - 0.1)
        end
    else
        if self.ItemClassWidthPct > 0.1 then
            self.ItemClassWidthPct = self.ItemClassWidthPct - self.AnimationPctStep
        else
            self.ItemClassWidthPct = 0.1
        end
    end
end

function RuleEditor:GetAvailableWidth()
    return math.max(UI.GetAvailableWidth(), self.MinimalWidth)
end

-- Add a property and method for custom configurations
RuleEditor.CustomConfigurations = {} -- table of { renderFn = function, generateFn = function }

function RuleEditor:AddCustomConfiguration(renderFn, generateFn)
    table.insert(self.CustomConfigurations, { renderFn = renderFn, generateFn = generateFn })
end

RuleEditor.CustomSettingsHeader = "Custom Configurations"
RuleEditor.CustomSettingsHeight = 200
function RuleEditor:Draw(settings, callback)
    local callbackFn = function() end
    if not callback then
        callback = { ["fn"] = callbackFn, ["args"] = {} }
    end

    if self.LastRuleMessage then
        UI.Text(self.LastRuleMessage, "FF1CB41C")
    end

    -- New child container for custom configurations
    local customCount = #(self.CustomConfigurations or {})
    local availableWidth = self:GetAvailableWidth() - 40
    if customCount > 0 then
        ImGui.Separator()
        UI.Text(self.CustomSettingsHeader, ORANGE_COLOR)
        UI.InChild("##rule_editor_custom_settings_child_" .. tostring(self), ImVec2(availableWidth, self.CustomSettingsHeight), ImGuiChildFlags_Borders, nil, function()
            local columns = math.min(customCount, 3)
            ImGui.Columns(columns)
            for i, custom in ipairs(self.CustomConfigurations) do
                custom.renderFn() -- render the custom UI
                if (columns > 1) then
                    ImGui.NextColumn()
                end
            end
            ImGui.Columns(1)
        end)

        availableWidth = self:GetAvailableWidth() - 40
    end

    self:AnimationProcessing()
    -- We split the available width in 3 parts, 1 for the Item Class, 1 for the Item Base and 1 for Conditions
    local itemClassWidth = availableWidth * self.ItemClassWidthPct
    local itemBaseWidth = availableWidth * (self.SelectorWidthPct - self.ItemClassWidthPct)
    local conditionsWidth = availableWidth - itemClassWidth - itemBaseWidth

    local didCreateRule = false
    UI.InChild("##rule_editor_item_selection_child_" .. tostring(self), ImVec2(availableWidth, 400), ImGuiChildFlags_Borders, nil, function()
        -- Item Class Child
        UI.WithDisable(self.DisplayMode ~= DisplayModes.ItemClass, function()
            UI.InChild("##rule_editor_item_selection_itemclasses_child_" .. tostring(self), ImVec2(itemClassWidth, 0), ImGuiChildFlags_Borders, nil, function()
                self:DrawItemClassSelector(itemClassWidth, settings)
            end)
        end)

        UI.SameLine()
        -- Item Base Child
        UI.WithDisable(self.DisplayMode ~= DisplayModes.ItemBase, function()
            UI.InChild("##rule_editor_item_selection_itembases_child_" .. tostring(self), ImVec2(itemBaseWidth, 0), ImGuiChildFlags_Borders, nil, function()
                self:DrawItemBaseSelector(itemBaseWidth, settings)
            end)
        end)

        UI.SameLine()
        -- Conditions Child
        UI.InChild("##rule_editor_item_selection_conditions_child_" .. tostring(self), ImVec2(conditionsWidth, 0), ImGuiChildFlags_Borders, nil, function()
            didCreateRule = self:DrawConditions(conditionsWidth, settings, callback)
        end)
    end)

    return didCreateRule
end

---@enum
local TesterUI_MODES = { WORLDITEM = 1, INVENTORY = 2 }
local TesterUI_MODES_NAMES = { [TesterUI_MODES.WORLDITEM] = "World Item", [TesterUI_MODES.INVENTORY] = "Inventory" }

RuleEditor.TesterUI_Mode = TesterUI_MODES.INVENTORY
RuleEditor.TesterUI_Conditions = {}
RuleEditor.ItemClassesData_Lookup = nil
function RuleEditor:DrawTesterUI()
    UI.Text("Tester UI", ORANGE_COLOR)
    self.TesterUI_Mode = UI.Combo("Mode##test_mode_" .. tostring(self), self.TesterUI_Mode, TesterUI_MODES_NAMES)

    -- First we need to determine the item we want to test on
    local itemActor = nil
    -- self.TesterUI_Mode == TesterUI_MODES.WORLDITEM
    if self.TesterUI_Mode == TesterUI_MODES.WORLDITEM then
        local worldActors = Infinity.PoE2.getActorsByType(EActorType_WorldItem)
        local closestWorldItem = nil
        local closestWorldItemDistance = math.huge
        for actorId, worldActor in pairs(worldActors) do
            local distance = worldActor:getDistanceToPlayer()
            if distance < closestWorldItemDistance then
                closestWorldItemDistance = distance
                closestWorldItem = worldActor
            end
        end

        if closestWorldItem then
            itemActor = closestWorldItem:getItem()
        end
    else
        local playerInventories = Infinity.PoE2.getGameStateController():getInGameState():getServerData().getPlayerInventoriesByType(EInventoryType_MainInventory)
        if not playerInventories or #playerInventories == 0 then
            UI.Text("Could not find player inventory", "FF9E0505")
            return
        end

        local playerInventory = playerInventories[1]

        local item = playerInventory:getInventoryItemByPos(Vector2(0, 0))
        if not item then
            UI.Text("Could not find item in inventory at location (0,0)", "FF9E0505")
            return
        end

        itemActor = item
    end

    if not itemActor then
        UI.Text("Could not find item", "FF9E0505")
        return
    end

    local itemClass
    if itemActor then
        itemClass = itemActor:getBaseItemType():getItemClass()
    end

    if not itemClass then
        UI.Text("Could not find item class", "FF9E0505")
        return
    end

    if not self.ItemClassesData_Lookup then
        self.ItemClassesData_Lookup = {}
        local itemClasses = Infinity.PoE2.getFileController():getItemClassesFile():getAll()
        for _, _itemClass in pairs(itemClasses) do
            self.ItemClassesData_Lookup[_itemClass:getKey()] = _itemClass
        end
    end

    local itemClassData = self.ItemClassesData_Lookup[itemClass:getKey()]
    if not itemClassData then
        UI.Text("Could not find item class data", "FF9E0505")
        return
    end

    local ruleConditions = self.TesterUI_Conditions
    UI.CreateColumns({ { Title = "Valid For Item Class", Width = 100 }, { Title = "Condition Name", Width = 150 }, { Title = "Condition Settings", Width = 250 }, { Title = "Item Evaluation", Width = 100 } })
    for _, itemCondition in ipairs(Conditions.List) do
        -- print(itemCondition.UniqueId)
        if not ruleConditions[itemCondition.UniqueId] then
            ruleConditions[itemCondition.UniqueId] = { State = CONDITION_STATE.REQUIRED }
        end

        local valid = itemCondition:IsValidForItemClass(itemClassData)
        UI.Text(valid and "Yes" or "No", valid and "FF109410" or "FF9E0505")
        UI.NextColumn()
        UI.Text(itemCondition.UniqueId)
        UI.NextColumn()
        itemCondition:DrawFurtherSettings(ruleConditions[itemCondition.UniqueId])
        UI.NextColumn()
        if itemActor then
            local itemEvaluation = itemCondition:EvaluateActor(itemActor, ruleConditions[itemCondition.UniqueId])
            UI.Text(itemEvaluation and "Yes" or "No", itemEvaluation and "FF109410" or "FF9E0505")
        else
            UI.Text("No actor")
        end
        UI.NextColumn()
        UI.Separator()
    end
    UI.EndColumns()
end

---@type table<table, boolean>
local existingRulesPopups = {}


---@param rule RuleEditor.Rule
function RuleEditor.PopupEditorForExistingRule(rule)
    if existingRulesPopups[rule] then
        print("Already opened a popup for this rule")
        return
    end

    ---@type RuleEditor
    local ruleEditor = RuleEditor()
    ruleEditor.CurrentlyBuildRule = {}
    ruleEditor.CurrentlyBuildRule.Conditions = Table.Copy(rule.Conditions)
    ruleEditor.CurrentlyBuildRule.ItemClasses = {}
    ruleEditor.CurrentlyBuildRule.ItemBases = {}
    ruleEditor.CurrentlyBuildRule.ExtraInformation = Table.Copy(rule.ExtraInformation)
    ruleEditor.SelectedItemClasses = {}
    for _, itemClassName in pairs(rule.ItemClasses) do
        if itemClassName == "ALLITEMS" then
            table.insert(ruleEditor.SelectedItemClasses, { ID = -1, getKey = function(self) return "ALLITEMS" end, getName = function(self) return "ALL ITEMS" end, getItemClassCategory = function(self) return nil end })
        end

        local itemClass = Infinity.PoE2.getFileController():getItemClassesFile():getByKey(itemClassName)
        if itemClass then
            table.insert(ruleEditor.SelectedItemClasses, itemClass)
        else
            print("Could not find item class for key " .. itemClassName)
        end
    end

    ruleEditor.SelectedItemBases = {}
    for _, itemBaseData in pairs(rule.ItemBases) do
        local itemBase = Infinity.PoE2.getFileController():getBaseItemTypesFile():getByMetaPath(itemBaseData.MetaPath)
        if itemBase then
            table.insert(ruleEditor.SelectedItemBases, itemBase)
        else
            print("Could not find item base for meta path " .. itemBaseData.MetaPath)
        end
    end

    ruleEditor.IsEditMode = true
    ruleEditor:UpdateAvailableConditions()

    local popup = Popup.Basic(
    ---@param popup CoreLib.Popup
        function(popup)
            local width = ImGui.GetContentRegionAvailWidth()
            UI.Dummy(width - 30, 0)
            ImGui.SameLine()
            if UI.Button("X", Color.Red, ImVec2(20, 20)) then
                existingRulesPopups[rule] = false
                popup:remove()
            end
            ImGui.Separator()

            local didCreate = ruleEditor:Draw()
            if didCreate then
                -- We copy over the rule to the existing rule table in a way that doesn't break the reference
                Table.Clear(rule)
                Table.Merge(rule, ruleEditor.CurrentlyBuildRule)
                existingRulesPopups[rule] = false
                popup:remove()
            end
        end)

    popup.size = ImVec2(1200, 500)
    popup:register()

    existingRulesPopups[rule] = true
end

return RuleEditor
