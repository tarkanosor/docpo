local UI = require("CoreLib.UI")
local Color = require("CoreLib.Color")
local ServerData = require("PoE2Lib.Proxies.ServerData")
local InGameUI = require("PoE2Lib.Proxies.InGameUI")

---@class PoE2Lib.Stashing
local Stashing = {}

---@return ServerStashTab[]
function Stashing.GetStashTabs()
    return ServerData:getStashTabs()
end

---@return ServerStashTab[]
function Stashing.GetGuildStashTabs()
    return ServerData:getGuildStashTabs()
end

---@param tab ServerStashTab
function Stashing.IsSupportedStashTab(tab)
    -- Ignore stash tabs with no name
    if tab:getName() == "" then
        return false
    end

    local type = tab:getType()
    -- Check for good types
    return type ~= EStashTabType_MapStash and type ~= EStashTabType_MapStashTab_Child and type ~= EStashTabType_Folder and type ~= EStashTabType_UniqueStash and type ~= EStashTabType_UniqueStashTab_Child and type ~= EStashTabType_Count and
        type < EStashTabType_Count
end

--------------------------------------------------------------------------------
-- Stash Interface
--------------------------------------------------------------------------------

--- Get the inventory and tab for a stash tab by name. If the inventory is not
--- loaded yet, it will request it; the inventory will be nil, but the tab will
--- be valid.
---@return  ServerStashTab? tab, ServerInventory? inventory
function Stashing.GetStashInventoryByName(name)
    for _, tab in pairs(Stashing.GetStashTabs()) do
        if tab:getName() == name then
            local inventory = tab:getPlayerInventory()
            if inventory == nil or not inventory:isCurrentlyLiveInventory() then
                if Stashing.IsStashPanelOpen() then
                    tab:requestLoadingInventory()
                end

                return tab, nil
            end

            return tab, inventory
        end
    end

    return nil, nil
end

function Stashing.IsStashPanelOpen()
    return InGameUI:getInGameUIElementByType(EInGameUIElement_Stash):isVisible()
end

function Stashing.CloseStashPanel()
    InGameUI:getInGameUIElementByType(EInGameUIElement_Stash):changeVisibility(false)
end

function Stashing.IsGuildStashPanelOpen()
    return InGameUI:getInGameUIElementByType(EInGameUIElement_GuildStash):isVisible()
end

function Stashing.CloseGuildStashPanel()
    InGameUI:getInGameUIElementByType(EInGameUIElement_GuildStash):changeVisibility(false)
end

---@return WorldActor?
function Stashing.GetStashActor()
    for _, actor in pairs(Infinity.PoE2.getActorsByMetaPath("Metadata/MiscellaneousObjects/Stash")) do
        return actor
    end
    return nil
end

---@return WorldActor?
function Stashing.GetGuildStashActor()
    for _, actor in pairs(Infinity.PoE2.getActorsByMetaPath("Metadata/MiscellaneousObjects/GuildStash")) do
        return actor
    end
    return nil
end

--------------------------------------------------------------------------------
-- UI Elements
--------------------------------------------------------------------------------

---@type table<string, string>
local StashSelectorSearchValues = {}

---@param label string
---@param current string?
---@param nillable boolean?
---@param stashList ServerStashTab[]?
---@return string?
function Stashing.SingleStashSelector(label, current, nillable, stashList)
    if not nillable and current == nil then
        ImGui.PushStyleColor(ImGuiCol_Text, Color.Red)
    end

    local open = ImGui.BeginCombo(label, current or "-- Select a stash tab --")
    if not nillable and current == nil then
        ImGui.PopStyleColor()
    end

    if open then
        UI.WithWidth(ImGui.GetContentRegionAvailWidth(), function()
            _, StashSelectorSearchValues[label] = ImGui.InputTextWithHint("##search_stash_tab_" .. label, "Search", StashSelectorSearchValues[label] or "")
        end)

        local sorted, seen, unsupported = {}, {}, {}
        for _, tab in pairs(stashList or Stashing.GetStashTabs()) do
            local name = tab:getName()
            if name ~= "" and not seen[name] and name:lower():find(StashSelectorSearchValues[label]:lower(), 1, true) then
                table.insert(sorted, name)
                seen[name] = true
                if not Stashing.IsSupportedStashTab(tab) then
                    unsupported[name] = true
                end
            end
        end
        table.sort(sorted)

        local notFound = false
        if current ~= nil and not seen[current] then
            notFound = true
            table.insert(sorted, 1, current)
            seen[current] = true
        end

        if nillable then
            if ImGui.Selectable("-- None --", current == nil) then
                current = nil
            end
            if current == nil then
                ImGui.SetItemDefaultFocus()
            end
        end

        for _, name in pairs(sorted) do
            local item = name
            if unsupported[name] then
                item = ("[NOT SUPPORTED] %s"):format(item)
            end
            if notFound and name == current then
                item = ("[NOT FOUND] %s"):format(item)
            end

            if ImGui.Selectable(item, name == current) then
                current = name
            end
            if name == current then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end

    return current
end

---@param label string
---@param current string?
---@param nillable boolean?
---@return string?
function Stashing.SingleStashSelectorGuild(label, current, nillable)
    return Stashing.SingleStashSelector(label, current, nillable, ServerData:getGuildStashTabs())
end

---@param label string
---@param current string[]
---@param stashList ServerStashTab[]?
---@return string[]
function Stashing.MultiStashSelector(label, current, stashList)
    if #current == 0 then
        ImGui.PushStyleColor(ImGuiCol_Text, Color.Red)
    end

    local open = ImGui.BeginCombo(label, #current > 0 and table.concat(current, ", ") or "-- Select stash tabs --")
    if #current == 0 then
        ImGui.PopStyleColor()
    end

    if open then
        UI.WithWidth(ImGui.GetContentRegionAvailWidth(), function()
            _, StashSelectorSearchValues[label] = ImGui.InputTextWithHint("##search_stash_tabs_" .. label, "Search", StashSelectorSearchValues[label] or "")
        end)

        local keyed = {}
        for i, name in ipairs(current) do
            keyed[name] = i
        end

        local sorted, seen, unsupported = {}, {}, {}
        for _, tab in pairs(stashList or Stashing.GetStashTabs()) do
            local name = tab:getName()
            if name ~= "" and not seen[name] and name:lower():find(StashSelectorSearchValues[label]:lower(), 1, true) then
                table.insert(sorted, name)
                seen[name] = true
                if not Stashing.IsSupportedStashTab(tab) then
                    unsupported[name] = true
                end
            end
        end

        table.sort(sorted, function(a, b)
            if keyed[a] == nil and keyed[b] ~= nil then
                return false
            end
            if keyed[a] ~= nil and keyed[b] == nil then
                return true
            end
            return a < b
        end)

        local notFound = {}
        for _, name in ipairs(current) do
            if not seen[name] then
                table.insert(sorted, 1, name)
                seen[name] = true
                notFound[name] = true
            end
        end

        for _, name in ipairs(sorted) do
            local index = keyed[name]
            local item = name
            if unsupported[name] then
                item = ("[NOT SUPPORTED] %s"):format(item)
            end
            if notFound[name] then
                item = ("[NOT FOUND] %s"):format(item)
            end
            local changed, enabled = ImGui.Checkbox(item, index ~= nil)
            if changed then
                if enabled then
                    table.insert(current, name)
                else
                    table.remove(current, index)
                end
                table.sort(current)
            end
            if index ~= nil then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end

    return current
end

---@param label string
---@param current string[]
---@return string[]
function Stashing.MultiStashSelectorGuild(label, current)
    return Stashing.MultiStashSelector(label, current, ServerData:getGuildStashTabs())
end

return Stashing
