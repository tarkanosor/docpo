local UI = require("CoreLib.UI")
local Table = require("CoreLib.Table")
local Core_Settings = require("CoreLib.Settings")
local Vector = require("CoreLib.Vector")

local Events = require("PoE2Lib.Events")
local SkillHandlers = require("PoE2Lib.Combat.SkillHandlers")
local CombatAddons = require("PoE2Lib.Combat.CombatAddons")
local CombatUtils = require("PoE2Lib.Combat.CombatUtils")

---@class PoE2Lib.Combat.CombatManager
local CombatManager = {}

---@class PoE2Lib.Combat.Settings
local Settings = {
    Version = 1,
    FullyAutomatedSkillManagement = false,
    ---@type PoE2Lib.Combat.SkillHandler.Config[]
    SkillConfigs = {},
    ---@type PoE2Lib.Combat.CombatAddon.Config[]
    AddonConfigs = {},
}
CombatManager.Settings = Settings

-- ---@type PoE2Lib.Combat.SkillHandler[]
-- CombatManager.Handlers = {}

---@class PoE2Lib.Combat.CombatManager.State
local State = {
    LastCheckedSkillIdHash = 0,
    ---@type PoE2Lib.Combat.SkillHandler[]
    SkillHandlers = {},
    ---@type PoE2Lib.Combat.CombatAddon[]
    CombatAddons = {},
}
CombatManager.State = State

-- CombatManager.Logger = MagLib.Core.Log.NewLogger("CombatManager")
Core_Settings.AddSettingsToHandlerVersioned("CombatManager", Settings, {
    ---@param settings PoE2Lib.Combat.Settings
    [0] = function(settings)
        -- Added versioning
        settings.Version = 1
    end,
})

---@alias PoE2Lib.Combat.UnionHandler (PoE2Lib.Combat.SkillHandler|PoE2Lib.Combat.CombatAddon)

-- Init handlers from settings
local function initHandlersFromSettings()
    State.SkillHandlers = {}
    for i, config in ipairs(Settings.SkillConfigs) do
        State.SkillHandlers[i] = CombatManager.InitSkillHandlerConfig(config)
    end

    State.CombatAddons = {}
    for i, config in ipairs(Settings.AddonConfigs) do
        State.CombatAddons[i] = CombatManager.InitCombatAddonConfig(config)
    end

    State.LastCheckedSkillIdHash = 0
end

---@return PoE2Lib.Combat.SkillHandler
function CombatManager.InitSkillHandlerConfig(config)
    local handlerClass = SkillHandlers.ByName(config.handlerName)
    assert(handlerClass, "Skill handler class not found: " .. config.handlerName)

    local handler = handlerClass(config)

    -- Set to the current skill name if the name is missing from the config.
    if config.skillName == nil then
        config.skillName = handler:getDisplayedName()
    end

    return handler
end

function CombatManager.InitCombatAddonConfig(config)
    local addonClass = CombatAddons.ByName(config.addonName)
    assert(addonClass, "Combat addon class not found: " .. config.addonName)
    return addonClass(config)
end

initHandlersFromSettings()
Core_Settings.OnSettingsProfileLoaded:register(function(profileName)
    initHandlersFromSettings()
end)

--- This should be called every OnPulse. It will propagate to all the skill
--- handlers.
function CombatManager.OnPulse()
    -- CombatManager.FullyAutomatedUpdate()

    for _, addon in ipairs(State.CombatAddons) do
        addon:onPulse()
    end
    for _, handler in ipairs(State.SkillHandlers) do
        handler:onPulse()
    end
end

Events.OnActionExecute:register(function(data)
    local skillId = data.action:getSkill():getSkillIdentifier()
    for _, handler in ipairs(State.SkillHandlers) do
        if handler.skillId == skillId then
            handler:onSkillExecute()
        end
    end
end)

do
    ---@type integer?
    local prevActionSkillId = nil
    Events.OnActionChange:register(function(data)
        local currentSkillId = (data.action and data.action:getSkill():getSkillIdentifier() or nil)
        if currentSkillId ~= prevActionSkillId and prevActionSkillId ~= nil then
            for _, handler in ipairs(State.SkillHandlers) do
                if handler.skillId == prevActionSkillId then
                    handler:onSkillEnd()
                end
            end
        end
        prevActionSkillId = currentSkillId
    end)
end

Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnRenderD2D", function()
    for _, handler in ipairs(State.SkillHandlers) do
        if handler.config.enabled then
            handler:onRenderD2D()
        end
    end
end)

---@return number distance, boolean? isFlyable, PoE2Lib.Combat.SkillHandler? bestHandler
function CombatManager.GetMaxAvailableSkillDistance()
    local bestHandler = nil
    local bestHandler_MaxDistance = -1
    local bestHandler_isFlyable = nil

    for _, handler in ipairs(State.SkillHandlers) do
        if handler.config.enabled then
            local maxDst, isFlyable = handler:getCurrentMaxSkillDistance()
            if maxDst > bestHandler_MaxDistance then
                bestHandler = handler
                bestHandler_MaxDistance = maxDst
                bestHandler_isFlyable = isFlyable
            elseif maxDst == bestHandler_MaxDistance then
                -- If both distances are equal, then we want to take flyable if
                -- one of them is.
                bestHandler_isFlyable = isFlyable or bestHandler_isFlyable
            end
        end
    end

    return bestHandler_MaxDistance, bestHandler_isFlyable, bestHandler
end

---@param target WorldActor?
---@return PoE2Lib.Combat.UnionHandler? handler
function CombatManager.FindUsableHandler(target)
    for _, addon in ipairs(State.CombatAddons) do
        if addon:canUse(target) then
            return addon
        end
    end

    for _, handler in ipairs(State.SkillHandlers) do
        if handler:canUse(target) then
            return handler
        end
    end

    return nil
end

---@param target WorldActor?
---@return boolean used
---@return PoE2Lib.Combat.UnionHandler? handler
function CombatManager.TryUse(target)
    local handler = CombatManager.FindUsableHandler(target)
    if handler then
        handler:use(target)
        return true, handler
    end

    return false, nil
end

function CombatManager.StopAttacking()
    for _, handler in ipairs(State.SkillHandlers) do
        handler:stopAttacking()
    end
end

---@param target WorldActor?
function CombatManager.UpdateTarget(target)
    for _, addon in ipairs(State.CombatAddons) do
        addon:updateTarget(target)
    end
    for _, handler in ipairs(State.SkillHandlers) do
        handler:updateTarget(target)
    end
end

---@param target WorldActor?
---@return boolean
---@return PoE2Lib.Combat.SkillHandler? handler
function CombatManager.ShouldPreventMovement(target)
    for _, addon in ipairs(State.CombatAddons) do
        if addon:shouldPreventMovement(target) then
            return true, nil
        end
    end

    for _, handler in ipairs(State.SkillHandlers) do
        if handler:shouldPreventMovement(target) then
            return true, handler
        end
    end

    return false
end

---@param destination Vector3
---@return boolean success
---@return PoE2Lib.Combat.UnionHandler? handler
function CombatManager.TryMove(destination)
    for _, handler in ipairs(State.SkillHandlers) do
        if handler:tryMove(destination) then
            return true, handler
        end
    end

    return false, nil
end

---@param destination Vector3
---@param path Vector3[]
---@return boolean success
---@return PoE2Lib.Combat.UnionHandler? handler
function CombatManager.TryTravel(destination, path)
    local locations, costs, hasPath = {}, {}, false
    local navigator = Infinity.PoE2.getNavigator()

    local function getPath()
        if hasPath then
            return
        end

        hasPath = true

        if path == nil then
            local pLoc = Infinity.PoE2.getLocalPlayer():getLocation()
            path = navigator:getPath(pLoc.X, pLoc.Y, destination.X, destination.Y)
        end

        if #path == 0 then
            return nil, nil, math.huge
        end

        local finalIndex = #path
        for i, waypoint in ipairs(path) do
            if navigator:isOffmeshConnection(waypoint.X, waypoint.Y) then
                finalIndex = i
                break
            end
        end

        for i = finalIndex, 1, -1 do
            locations[i] = path[i]
            if i < finalIndex then
                costs[i] = locations[i]:getDistanceXY(locations[i + 1]) + costs[i + 1]
            else
                costs[i] = 0
            end
        end
    end

    for _, handler in ipairs(State.SkillHandlers) do
        if handler:needsPathfinding() then
            getPath()
        end

        if handler:travel(destination, locations, costs) then
            return true, handler
        end
    end

    return false, nil
end

function CombatManager.StopTravel()
    for _, handler in ipairs(State.SkillHandlers) do
        handler:stopTravel()
    end
end

---@param handler PoE2Lib.Combat.SkillHandler
---@return boolean success True if the skill ID was successfully fixed.
local function TryAutoFixSkillId(handler)
    local config = handler.config
    local foundSkill, foundName, foundSameSlot = nil, nil, false
    for _, skill in pairs(Infinity.PoE2.getLocalPlayer():getActiveSkills()) do
        local displayedName = CombatUtils.GetSkillDisplayedName(skill)
        local sameSlot = bit.band(skill:getSkillIdentifier(), 1) == bit.band(config.skillId, 1)
        if displayedName == config.skillName and skill:canBeUsedWithWeapon() then
            -- Check duplicate names
            if foundSkill == nil or (sameSlot and not foundSameSlot) then
                foundSkill, foundName, foundSameSlot = skill, displayedName, sameSlot
            elseif sameSlot == foundSameSlot then
                print(("Automatic skill ID fix failed: Found multiple skills with the name '%s'"):format(config.skillName))
                foundSkill, foundName, foundSameSlot = nil, nil, false
                break
            end
        end
    end

    if foundSkill and foundName then
        local id = foundSkill:getSkillIdentifier()
        config.skillId = id
        config.skillName = foundName
        handler.skillId = id
        return true
    else
        print('Could not automatically fix the skill ID. Please select the skill manually.')
        return false
    end
end

function CombatManager.TryAutoFixAllErrors()
    for i, config in ipairs(Settings.SkillConfigs) do
        local handler = State.SkillHandlers[i]
        if handler:getDisplayedName() ~= config.skillName then
            TryAutoFixSkillId(handler)
        end
    end
end

function CombatManager.HasError()
    -- Check handler:getDisplayedName() ~= config.skillName
    for i, config in ipairs(Settings.SkillConfigs) do
        local handler = State.SkillHandlers[i]
        if config.enabled and handler:getDisplayedName() ~= config.skillName then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- SkillHandler Drawing
--------------------------------------------------------------------------------

---@param target WorldActor? The current target, used to draw debug information.
function CombatManager.DrawSkills(target)
    -- _, Settings.FullyAutomatedSkillManagement = ImGui.Checkbox("Fully automate skill management", Settings.FullyAutomatedSkillManagement)
    -- UI.SameLine()
    -- UI.Text("(?)", "FF39F60A")
    -- UI.Tooltip(function()
    --     UI.Text("WARNING: This will remove and disable any customization.", "FFFF1D1D")
    --     UI.Text("If need anything more than just \"use all combat skills, buffs and auras\" then manual configuration is required", "FFCEB40B")
    -- end)

    -- -- Update the automatic skill management here too
    -- CombatManager.FullyAutomatedUpdate()

    UI.WithDisable(Settings.FullyAutomatedSkillManagement, function()
        CombatManager.DrawSkillList(target)
        CombatManager.DrawAddSkillSelector()
    end)

end

---@param target WorldActor? The current target, used to draw debug information.
function CombatManager.DrawSkillList(target)
    if CombatManager.HasError() then
        UI.Text("There are errors in the skill configuration. Please fix them.", "FFDD4444")
        ImGui.SameLine()
        if ImGui.Button("Auto-Fix All##combat_manager_auto_fix_all_skills") then
            CombatManager.TryAutoFixAllErrors()
        end
    end

    for i, config in ipairs(Settings.SkillConfigs) do
        local handler = State.SkillHandlers[i]
        if (not handler) then
            UI.Text("Not a known handler!", "FFDD4444")
        else
            local function header()
                local open = false
                UI.Panel("combat_manager_skill_header", {
                    background = ImVec4(0, 0, 0, 0.4),
                    spacing = ImVec2(0, 0),
                    padding = ImVec2(8, 6),
                }, function()
                    if ImGui.Button("X##combat_manager_remove_skill_" .. tostring(i)) then
                        table.remove(Settings.SkillConfigs, i)
                        table.remove(State.SkillHandlers, i)
                    end

                    ImGui.SameLine()
                    UI.WithDisable(i == 1, function()
                        if ImGui.ArrowButton('combat_manager_move_skill_up_' .. tostring(i), 2) then
                            Settings.SkillConfigs[i], Settings.SkillConfigs[i - 1] = Settings.SkillConfigs[i - 1], Settings.SkillConfigs[i]
                            State.SkillHandlers[i], State.SkillHandlers[i - 1] = State.SkillHandlers[i - 1], State.SkillHandlers[i]
                        end
                    end)

                    ImGui.SameLine()
                    UI.WithDisable(i == #State.SkillHandlers, function()
                        if ImGui.ArrowButton('combat_manager_move_skill_down_' .. tostring(i), 3) then
                            Settings.SkillConfigs[i], Settings.SkillConfigs[i + 1] = Settings.SkillConfigs[i + 1], Settings.SkillConfigs[i]
                            State.SkillHandlers[i], State.SkillHandlers[i + 1] = State.SkillHandlers[i + 1], State.SkillHandlers[i]
                        end
                    end)

                    ImGui.SameLine()
                    _, config.enabled = ImGui.Checkbox('##combat_manager_skill_enabled_' .. tostring(i), config.enabled)

                    local treeLabel = ("%s##combat_manager_skill_details_%s"):format(handler:getFullSkillTitle(), config)
                    if handler:getDisplayedName() ~= config.skillName then
                        treeLabel = "ERROR! " .. treeLabel
                    end

                    ImGui.SameLine()
                    open = ImGui.TreeNodeEx(treeLabel, ImGuiTreeNodeFlags_NoTreePushOnOpen)
                end)
                return open
            end

            UI.PanelCollapsing(("combat_manager_skill_%s"):format(config), { customHeader = header, sackground = ImVec4(0, 0, 0, 0.2) }, function()
                do -- Handler combo
                    local current = Table.FindIndex(SkillHandlers.ListLabels, handler.shortName) or 1

                    ImGui.AlignTextToFramePadding()
                    ImGui.Text('Handler:')
                    ImGui.SameLine(0, 4)
                    ImGui.SetNextItemWidth(200)
                    local changed, new = ImGui.Combo("##combat_manager_change_handler_" .. tostring(i), current, SkillHandlers.ListLabels)

                    if changed then
                        local handlerClass = SkillHandlers.List[new]
                        -- Store the new handler name in the config
                        config.handlerName = SkillHandlers.NameOf(handlerClass) --[[@as string]]
                        -- Create the new handler
                        handler = handlerClass(config)
                        -- Replace the handler
                        State.SkillHandlers[i] = handler
                    end
                end

                ImGui.SameLine()

                do -- ID combo
                    ImGui.Text('ID:')
                    ImGui.SameLine(0, 4)
                    -- We tie the current skillId and skillName to the label, so when we move the skill in the list, it
                    -- doesn't retain the value of the combo from the previous skill at that index.
                    ImGui.SetNextItemWidth(200)
                    CombatManager.DrawSkillsCombo(
                        ("##combat_manager_change_skill_id_%s_%s_%s"):format(i, config.skillId, config.skillName),
                        handler:getSkillObject() or "(Unknown)",
                        function(skill, name)
                            return name == config.skillName or (bit.band(Infinity.Win32.GetAsyncKeyState(KeyCode_LMENU), 0x8000) ~= 0)
                        end,
                        function(skill)
                            local id = skill:getSkillIdentifier()
                            config.skillId = id
                            config.skillName = CombatUtils.GetSkillDisplayedName(skill) or "(Unknown)"
                            handler.skillId = id
                        end
                    )

                    -- Auto fix ID button
                    local actualSkill = Infinity.PoE2.getLocalPlayer():getActiveSkill(config.skillId)
                    if actualSkill == nil or CombatUtils.GetSkillDisplayedName(actualSkill) ~= config.skillName then
                        ImGui.SameLine()
                        -- Assign instead of in the if-statement, because the tooltip must immediately follow the Button declaration.
                        local pressed = ImGui.Button(("Fix ID##combat_manager_auto_fix_skill_id_%s_%s_%s"):format(i, config.skillId, config.skillName))
                        UI.Tooltip("Automatically fix the skill ID by finding the skill with the same name." ..
                            " If there are multiple skills with the same name, it will not update and you will have to pick which one manually, because we cannot tell which is the correct one.")
                        if pressed then
                            TryAutoFixSkillId(handler)
                        end
                    end
                end

                -- UI.Panel(("combat_manager_skill_settings_%s"):format(config), function()
                if handler:getDisplayedName() ~= config.skillName then
                    ImGui.TextWrapped(("Error: The name '%s' of the skill on this ID no longer matches. The skill gem might have been moved. Please select the skill again in the list above."):format(handler:getDisplayedName()))
                else
                    handler:draw(("skill_%s"):format(config), target)
                end
                -- end)
            end)
        end
    end
end

function CombatManager.DrawAddSkillSelector()
    CombatManager.DrawSkillsCombo('##combat_manager_add_skill_combo', "-- Add Skill --", nil, function(skill)
        local handlerClass, err = SkillHandlers.GetDefaultSkillHandler(skill)
        if err ~= nil then
            print(err)
        end

        local handler = handlerClass({
            handlerName = tostring(SkillHandlers.NameOf(handlerClass)),
            skillId = skill:getSkillIdentifier(),
            skillName = CombatUtils.GetSkillDisplayedName(skill) or "(Unknown)",
        })

        table.insert(State.SkillHandlers, handler)
        table.insert(Settings.SkillConfigs, handler.config)
    end)
end

---@param label string
---@param preview string|SkillWrapper
---@param filter (fun(skill: SkillWrapper, name: string):boolean)?
---@param callback fun(skill: SkillWrapper)
function CombatManager.DrawSkillsCombo(label, preview, filter, callback)
    if type(preview) == "userdata" then
        ---@cast preview SkillWrapper
        preview = CombatUtils.GetFullSkillTitle(preview)
        ---@cast preview string
    end

    if ImGui.BeginCombo(label, preview) then
        -- Get a sorted skills list
        local skills = {}
        for _, skill in pairs(Infinity.PoE2.getLocalPlayer():getActiveSkills()) do
            table.insert(skills, skill)
        end
        table.sort(skills, function(a, b)
            return a:getSkillIdentifier() < b:getSkillIdentifier()
        end)

        for _, skill in ipairs(skills) do
            local name = CombatUtils.GetSkillDisplayedName(skill)
            if name and name ~= "" and not name:find("DNT") and skill:canBeUsedWithWeapon() and (filter == nil or filter(skill, name)) then
                local title = CombatUtils.GetFullSkillTitle(skill)
                if ImGui.Selectable(CombatUtils.GetFullSkillTitle(skill), (preview == title)) then
                    callback(skill)
                end
            end
        end

        ImGui.EndCombo()
    end
end

--------------------------------------------------------------------------------
-- CombatAddon Drawing
--------------------------------------------------------------------------------

---@param target WorldActor? The current target, used to draw debug information.
function CombatManager.DrawAddons(target)
    CombatManager.DrawAddonList(target)
    CombatManager.DrawAddAddonSelector()
end

---@param target WorldActor? The current target, used to draw debug information.
function CombatManager.DrawAddonList(target)
    for i, config in ipairs(Settings.AddonConfigs) do
        local addon = State.CombatAddons[i]
        if (not addon) then
            UI.Text("Not a known addon!", "FFDD4444")
        else
            if ImGui.Button("X##combat_manager_remove_addon_" .. tostring(i)) then
                table.remove(Settings.AddonConfigs, i)
                table.remove(State.CombatAddons, i)
            end

            ImGui.SameLine()
            UI.WithDisable(i == 1, function()
                if ImGui.ArrowButton('combat_manager_move_addon_up_' .. tostring(i), 2) then
                    Settings.AddonConfigs[i], Settings.AddonConfigs[i - 1] = Settings.AddonConfigs[i - 1], Settings.AddonConfigs[i]
                    State.CombatAddons[i], State.CombatAddons[i - 1] = State.CombatAddons[i - 1], State.CombatAddons[i]
                end
            end)

            ImGui.SameLine()
            UI.WithDisable(i == #State.CombatAddons, function()
                if ImGui.ArrowButton('combat_manager_move_addon_down_' .. tostring(i), 3) then
                    Settings.AddonConfigs[i], Settings.AddonConfigs[i + 1] = Settings.AddonConfigs[i + 1], Settings.AddonConfigs[i]
                    State.CombatAddons[i], State.CombatAddons[i + 1] = State.CombatAddons[i + 1], State.CombatAddons[i]
                end
            end)

            ImGui.SameLine()
            _, config.enabled = ImGui.Checkbox('##combat_manager_addon_enabled_' .. tostring(i), config.enabled)

            ImGui.SameLine()
            if ImGui.TreeNodeEx(("%s##combat_manager_addon_details_%s"):format(addon:getListTitle(), addon), ImGuiTreeNodeFlags_None) then
                addon:draw("addon_" .. i, target)

                ImGui.TreePop()
                ImGui.Separator()
            end
        end
    end
end

function CombatManager.DrawAddAddonSelector()
    if ImGui.BeginCombo("##combat_manager_add_addon_combo", "Add Addon") then
        for _, addon in ipairs(CombatAddons.List) do
            if ImGui.Selectable(addon.shortName, false) then
                ---@type PoE2Lib.Combat.CombatAddon.Config
                local config = { addonName = CombatAddons.NameOf(addon), enabled = true, settings = {}, conditions = {} }

                table.insert(Settings.AddonConfigs, config)
                table.insert(State.CombatAddons, addon(config))
            end
        end
        ImGui.EndCombo()
    end
end

return CombatManager
