local Class = require("CoreLib.Class")
local UI = require("CoreLib.UI")
local Table = require("CoreLib.Table")
local Conditions = require("PoE2Lib.Items.Conditions.Conditions")
local RuleEditor = require("PoE2Lib.Items.Conditions.RuleEditor")

---@class RuleOverview : Class
---Draws the overview of the rules created by the RuleEditor
local RuleOverview = Class()
RuleOverview.Name = "RuleOverview"

-- Add flag to only show positive rules
RuleOverview.PositiveRulesOnly = false
function RuleOverview:init(name)
    self.Name = name
end

---@type table<string, fun(table)>
RuleOverview.ExtraInformationRenderers = {}
RuleOverview.ExtraInformationHeader = "Extra Information"
function RuleOverview:AddExtraInformationRenderer(uniqueId, renderer)
    self.ExtraInformationRenderers[uniqueId] = renderer
end

function RuleOverview:DrawRuleList(ruleList)
    local availableWidth = UI.GetAvailableWidth()
    local hasExtraInfo = Table.Length(self.ExtraInformationRenderers) > 0
    local BUTTONS_COLUMN_WIDTH = 160
    local MATCH_COLUMN_WIDTH = (availableWidth - BUTTONS_COLUMN_WIDTH - 10) / (hasExtraInfo and 3 or 2)
    local CONDITIONS_COLUMN_WIDTH = (availableWidth - BUTTONS_COLUMN_WIDTH - 10) / (hasExtraInfo and 3 or 2)
    local EXTRA_INFO_COLUMN_WIDTH = (availableWidth - BUTTONS_COLUMN_WIDTH - 10) / (hasExtraInfo and 3 or 2)

    local columns = { { Title = "Match", Width = MATCH_COLUMN_WIDTH }, { Title = "Conditions", Width = CONDITIONS_COLUMN_WIDTH }, { Title = "Control", Width = BUTTONS_COLUMN_WIDTH } }
    if hasExtraInfo then
        table.insert(columns, 3, { Title = self.ExtraInformationHeader, Width = EXTRA_INFO_COLUMN_WIDTH })
    end

    UI.CreateColumns(columns,
        { Id = "##rule_overview_column_" .. tostring(self) })

    local firstDone = false
    local toRemoveIndex = nil
    for k, rule in ipairs(ruleList) do
        if firstDone then
            UI.Separator()
        end

        firstDone = true
        if rule.Active == nil then
            rule.Active = true
        end

        if not rule.Active then
            ImGui.PushStyleColor(ImGuiCol_Text, ImVec4(0.3, 0.3, 0.3, 0.5))
        end

        -- What the rule matches
        if Table.Length(rule.ItemClasses) > 0 then
            local itemClassesString = ""
            for _, itemClass in pairs(rule.ItemClasses) do
                itemClassesString = itemClassesString .. itemClass .. ", "
            end
            itemClassesString = itemClassesString:sub(1, -3)

            UI.TextWrapped("Item Classes: " .. itemClassesString)
        end

        if Table.Length(rule.ItemBases) > 0 then
            local itemBasesString = ""
            for _, itemBase in pairs(rule.ItemBases) do
                itemBasesString = itemBasesString .. itemBase.Name .. ", "
            end
            itemBasesString = itemBasesString:sub(1, -3)
            UI.TextWrapped("Item Bases: " .. itemBasesString)
        end

        UI.NextColumn()

        -- The conditions
        local conditions = rule.Conditions
        for uniqueId, entry in pairs(conditions) do
            local state = entry.State
            local stateString = "Is"
            local color = "FF9F9F1B"
            if state == CONDITION_STATE.NOT then
                stateString = "Not"
                color = "FF9F1B1B"
            elseif state == CONDITION_STATE.DISABLED then
                stateString = "Disabled (ERROR)"
                color = "FFFF0000"
            end

            UI.TextWrapped(stateString, color)
            UI.SameLine()
            UI.TextWrapped(uniqueId)

            local itemCondition = Conditions.Map[uniqueId]
            if itemCondition and itemCondition._DrawOverviewInfo then
                UI.SameLine()
                itemCondition:DrawOverviewInfo(entry)
            end
        end

        --- Extra infos
        if hasExtraInfo then
            UI.NextColumn()
            for uniqueId, extraInfoRenderer in pairs(self.ExtraInformationRenderers) do
                local extraInfo = rule.ExtraInformation[uniqueId]
                if extraInfo then
                    extraInfoRenderer(extraInfo)
                end
            end
        end

        -- Controller
        UI.NextColumn()

        if not rule.Active then
            ImGui.PopStyleColor()
        end
        local changed, state = ImGui.Checkbox("##rule_overview_active" .. tostring(k), rule.Active)
        if changed then
            rule.Active = state
        end

        UI.SameLine()
        -- up arrow button
        if ImGui.ArrowButton("^##rule_overview_up" .. tostring(k) .. "_" .. tostring(rule), 2) then
            if k > 1 then
                local temp = ruleList[k - 1]
                ruleList[k - 1] = rule
                ruleList[k] = temp
            end
        end
        UI.SameLine()
        -- down arrow button
        if ImGui.ArrowButton("v##rule_overview_down" .. tostring(k) .. "_" .. tostring(rule), 3) then
            if k < #ruleList then
                local temp = ruleList[k + 1]
                ruleList[k + 1] = rule
                ruleList[k] = temp
            end
        end
        UI.SameLine()
        -- Remove button
        if UI.Button("X##rule_overview_remove" .. tostring(k) .. "_" .. tostring(rule), "FFB92106") then
            toRemoveIndex = k
        end

        UI.SameLine()

        if UI.Button("Edit##rule_overview_edit" .. tostring(k) .. "_" .. tostring(rule), "FF2B88DF") then
            RuleEditor.PopupEditorForExistingRule(rule)
        end

        UI.NextColumn()
    end

    if toRemoveIndex then
        table.remove(ruleList, toRemoveIndex)
    end

    UI.EndColumns()
end

function RuleOverview:Draw(settings)
    if settings.PositiveRules == nil then
        settings.PositiveRules = {}
    end

    if settings.NegativeRules == nil then
        settings.NegativeRules = {}
    end

    local width, nextElement = UI.DistributeWidth(self.PositiveRulesOnly and 1 or 2, 9, 500)

    UI.PanelWithHeader("Rules", {
        width = width,
        minHeight = 200,
        maxHeight = 400,
        customLabel = function(label)
            UI.Text(label, "FF40DB40")
        end,
    }, function()
        self:DrawRuleList(settings.PositiveRules)
    end)

    if not self.PositiveRulesOnly then
        nextElement()
        UI.PanelWithHeader("Ignore Rules", {
            width = width,
            minHeight = 200,
            maxHeight = 400,
            customLabel = function(label)
                UI.Text(label, "FFFF5050")
            end,
        }, function()
            self:DrawRuleList(settings.NegativeRules)
        end)
    end
end

return RuleOverview
