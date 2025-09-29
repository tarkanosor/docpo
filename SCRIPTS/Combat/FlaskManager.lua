local UI = require("CoreLib.UI")
local Table = require("CoreLib.Table")
local Core_Settings = require("CoreLib.Settings")
local PulseCache = require("CoreLib.PulseCache")
local Events = require("CoreLib.Events")

local FlaskHandlers = require("PoE2Lib.Combat.FlaskHandlers")

---@class PoE2Lib.Combat.FlaskManager
local FlaskManager = {}

---@class PoE2Lib.Combat.FlaskManager.Settings
FlaskManager.Settings = { --
    Version = 2,
    FullyAutomated = false,
    DisableDuringGracePeriod = true,
    ---@type PoE2Lib.Combat.FlaskHandler.Config[]
    FlaskConfigs = {},
}

---@class PoE2Lib.Combat.FlaskManager.State
local State = {
    --- Used to track whether the flask inventory has changed.
    LastFlaskInvAccessCount = 0,
    ---@type PoE2Lib.Combat.FlaskHandler[]
    FlaskHandlers = {},
}
FlaskManager.State = State

-- FlaskManager.Logger = MagLib.Core.Log.NewLogger("FlaskManager")

Core_Settings.AddSettingsToHandlerVersioned("FlaskManager", FlaskManager.Settings, {
    ---@param settings PoE2Lib.Combat.FlaskManager.Settings
    [0] = function(settings)
        settings.Version = 1
    end,

})

-- Init handlers from settings
local function initHandlersFromSettings()
    State.LastFlaskInvAccessCount = 0
    State.FlaskHandlers = {}
    for i, config in ipairs(FlaskManager.Settings.FlaskConfigs) do
        local handlerClass = FlaskHandlers.ByName(config.handlerName)
        assert(handlerClass, "Flask handler class not found: " .. config.handlerName)
        State.FlaskHandlers[i] = handlerClass(config)
    end
end

initHandlersFromSettings()
Core_Settings.OnSettingsProfileLoaded:register(function(profileName)
    initHandlersFromSettings()
end)

--- This should be called every OnPulse. It will propagate to all the flask
--- handlers.
function FlaskManager.OnPulse()
    FlaskManager.FullyAutomatedUpdate()
    for _, handler in ipairs(State.FlaskHandlers) do
        handler:onPulse()
    end
end

local FlaskInventory = PulseCache(function()
    return Infinity.PoE2.getGameStateController():getInGameState():getServerData().getPlayerInventoryByType(EInventoryType_Flask)
end)

---@param flask ItemActor?
local function getFlaskName(flask)
    if flask == nil then
        return "No flask"
    end

    local uniqueName = flask:getItemName()
    if uniqueName ~= '' then
        return uniqueName
    end

    return flask:getName()
end

-- During OnCachedWorld, always trigger a full flask update. Sometimes the
-- flasks get bugged, this ensures that whenever we change world areas, we at
-- least rebuild the flask handlers once.
Events.OnCachedWorld:register(function()
    FlaskManager.State.LastFlaskInvAccessCount = 0
end)

--- Will update the flask handlers if the flask inventory has changed. Will only
--- run when FlaskManager.Settings.FullyAutomated is enabled.
function FlaskManager.FullyAutomatedUpdate()
    if not FlaskManager.Settings.FullyAutomated then
        return
    end

    local flaskInv = FlaskInventory:getValue()
    if flaskInv == nil then
        return
    end

    -- The access count changes when the flask inventory or any of the items
    -- inside it change. Hence if it's still the same, then we don't need to
    -- update.
    local accessCount = flaskInv:getAccessCount()
    if FlaskManager.State.LastFlaskInvAccessCount == accessCount then
        return
    end
    FlaskManager.State.LastFlaskInvAccessCount = accessCount

    -- When a flask is used, the access count changes as well and the flask is
    -- readded to the inventory with a new ID. So we will first check if any
    -- of the flask names are different. If they are not, then we don't need to
    -- rebuild the configs.
    do
        local function getHandlerBySlot(slot)
            for _, handler in ipairs(State.FlaskHandlers) do
                if handler.config.slot == slot then
                    return handler
                end
            end
        end

        local different = false
        for slot = 1, 5 do
            local flask = flaskInv:getInventoryItemByPos(Vector2(slot - 1, 0))
            local handler = getHandlerBySlot(slot)
            if (flask ~= nil) ~= (handler ~= nil) then
                different = true
                break
            end
            if handler and flask then
                if handler.config.flaskName ~= getFlaskName(flask) then
                    different = true
                    break
                end
            end
        end

        -- If there are no different flasks, we don't need to rebuild, so we
        -- exit the update here.
        if not different then
            return
        end
    end

    FlaskManager.Settings.FlaskConfigs = {}
    State.FlaskHandlers = {}

    for slot = 1, 5 do
        local flask = flaskInv:getInventoryItemByPos(Vector2(slot - 1, 0))
        if flask then
            local handlerClass, _ = FlaskHandlers.GetDefaultFlaskHandler(flask)

            ---@type PoE2Lib.Combat.FlaskHandler.Config
            local config = { --
                handlerName = FlaskHandlers.NameOf(handlerClass),
                slot = slot,
                flaskName = getFlaskName(flask),
                enabled = true,
                settings = {},
                conditions = {},
            }

            table.insert(FlaskManager.Settings.FlaskConfigs, config)
            table.insert(State.FlaskHandlers, handlerClass(config))
        end
    end
end

---@param target WorldActor?
---@return PoE2Lib.Combat.FlaskHandler? handler
function FlaskManager.FindUsableHandler(target)
    if FlaskManager.Settings.DisableDuringGracePeriod then
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer:hasBuff("grace_period") then
            return nil
        end
    end

    for _, handler in ipairs(State.FlaskHandlers) do
        if handler:canUse(target) then
            return handler
        end
    end
    return nil
end

---@param target WorldActor?
---@return boolean canUse
function FlaskManager.CanUse(target)
    return not not FlaskManager.FindUsableHandler(target)
end

---@param target WorldActor?
---@return boolean used
function FlaskManager.Use(target)
    local handler = FlaskManager.FindUsableHandler(target)
    if handler then
        handler:use(target)
        return true
    end
    return false
end

---@param target WorldActor?
function FlaskManager.UpdateTarget(target)
    for _, handler in ipairs(State.FlaskHandlers) do
        handler:updateTarget(target)
    end
end

--------------------------------------------------------------------------------
-- FlaskHandlers Drawing
--------------------------------------------------------------------------------

---@param target WorldActor? The current target, used to draw debug information.
function FlaskManager.DrawFlasks(target)
    _, FlaskManager.Settings.DisableDuringGracePeriod = ImGui.Checkbox("Disable during grace period", FlaskManager.Settings.DisableDuringGracePeriod)

    _, FlaskManager.Settings.FullyAutomated = ImGui.Checkbox("Fully automate flask management", FlaskManager.Settings.FullyAutomated)
    ImGui.Text('WARNING: This will remove and disable any customization.')

    -- Update here as well. This is so Kuduku UI will always have an up-to-date
    -- view. Because Kuduku will only call FlaskModule:OnPulse() when it is
    -- running.
    FlaskManager.FullyAutomatedUpdate()

    UI.WithDisable(FlaskManager.Settings.FullyAutomated, function()
        FlaskManager.DrawFlaskList(target)
        FlaskManager.DrawAddFlaskSelector()
    end)
end

---@param target WorldActor? The current target, used to draw debug information.
function FlaskManager.DrawFlaskList(target)
    for i, config in ipairs(FlaskManager.Settings.FlaskConfigs) do
        local handler = State.FlaskHandlers[i]
        if (not handler) then
            UI.Text("Not a known handler!", "FFDD4444")
        else
            -- Remove button
            if ImGui.Button("X##flask_manager_remove_flask_handler_" .. tostring(i)) then
                table.remove(FlaskManager.Settings.FlaskConfigs, i)
                table.remove(State.FlaskHandlers, i)
            end

            -- Move up button
            ImGui.SameLine()
            UI.WithDisable(i == 1, function()
                if ImGui.ArrowButton('flask_manager_move_flask_handler_up_' .. tostring(i), 2) then
                    FlaskManager.Settings.FlaskConfigs[i], FlaskManager.Settings.FlaskConfigs[i - 1] = FlaskManager.Settings.FlaskConfigs[i - 1], FlaskManager.Settings.FlaskConfigs[i]
                    State.FlaskHandlers[i], State.FlaskHandlers[i - 1] = State.FlaskHandlers[i - 1], State.FlaskHandlers[i]
                end
            end)

            -- Move down button
            ImGui.SameLine()
            UI.WithDisable(i == #State.FlaskHandlers, function()
                if ImGui.ArrowButton('flask_manager_move_flask_handler_down_' .. tostring(i), 3) then
                    FlaskManager.Settings.FlaskConfigs[i], FlaskManager.Settings.FlaskConfigs[i + 1] = FlaskManager.Settings.FlaskConfigs[i + 1], FlaskManager.Settings.FlaskConfigs[i]
                    State.FlaskHandlers[i], State.FlaskHandlers[i + 1] = State.FlaskHandlers[i + 1], State.FlaskHandlers[i]
                end
            end)

            -- Toggle checkbox
            ImGui.SameLine()
            _, config.enabled = ImGui.Checkbox('##flask_manager_flask_handler_enabled_' .. tostring(i), config.enabled)

            local treeFlags = ImGuiTreeNodeFlags_None
            -- Default the last handler to be open, so that if we add a new handler,
            -- the tree will open automatically.
            if i == #State.FlaskHandlers and not FlaskManager.Settings.FullyAutomated then
                treeFlags = bit.bor(treeFlags, ImGuiTreeNodeFlags_DefaultOpen)
            end

            local treeLabel = ("%s##flask_manager_flask_handler_details_%s"):format(handler:getListTitle(), i)

            ImGui.SameLine()
            if ImGui.TreeNodeEx(treeLabel, treeFlags) then

                ImGui.Text('Flask:')
                ImGui.SameLine()
                ImGui.PushItemWidth(200)
                FlaskManager.DrawFlaskSelector(("##flask_manager_change_flask_slot_%d"):format(i), ("[%d] %s"):format(config.slot, config.flaskName), function(slot, flask, name)
                    config.slot = slot
                    config.flaskName = name
                    handler.slot = slot
                end)
                ImGui.PopItemWidth()

                ImGui.SameLine()

                do -- Handler combo
                    local current = Table.FindIndex(FlaskHandlers.ListLabels, handler.shortName) or 1

                    ImGui.Text('Handler:')
                    ImGui.SameLine()
                    ImGui.PushItemWidth(200)
                    local changed, new = ImGui.Combo("##flask_manager_change_handler_" .. tostring(i), current, FlaskHandlers.ListLabels)
                    ImGui.PopItemWidth()

                    if changed then
                        local handlerClass = FlaskHandlers.List[new]
                        -- Store the new handler name in the config
                        config.handlerName = FlaskHandlers.NameOf(handlerClass) --[[@as string]]
                        -- Create the new handler
                        handler = handlerClass(config)
                        -- Replace the handler
                        State.FlaskHandlers[i] = handler
                    end
                end

                local actualName = handler:getFlaskName()
                if actualName ~= config.flaskName then
                    ImGui.TextWrapped(("Error: The name '%s' of the flask on this slot no longer matches. The flask might have been moved or changed. Please select the flask again in the list above and check your setup."):format(actualName))
                else
                    handler:draw("flask_" .. i, target)
                end

                ImGui.TreePop()
                ImGui.Separator()
            end
        end
    end
end

function FlaskManager.DrawAddFlaskSelector()
    ImGui.PushItemWidth(ImGui.GetContentRegionAvailWidth())
    FlaskManager.DrawFlaskSelector("##flask_manager_add_flask_combo", "Add Flask", function(slot, flask, name)
        local handler, err = FlaskHandlers.GetDefaultFlaskHandler(flask)
        if err ~= nil then
            print(err)
        end

        ---@type PoE2Lib.Combat.FlaskHandler.Config
        local config = { --
            handlerName = FlaskHandlers.NameOf(handler),
            slot = slot,
            flaskName = name,
            enabled = true,
            settings = {},
            conditions = {},
        }

        table.insert(FlaskManager.Settings.FlaskConfigs, config)
        table.insert(State.FlaskHandlers, handler(config))
    end)
    ImGui.PopItemWidth()
end

---@param label string
---@param preview string
---@param callback fun(slot: number, flask: ItemActor?, name: string | 'No flask')
function FlaskManager.DrawFlaskSelector(label, preview, callback)
    local inventory = FlaskInventory:getValue()
    if ImGui.BeginCombo(label, preview) then
        for slot = 1, 5 do
            local flask = inventory:getInventoryItemByPos(Vector2(slot - 1, 0))
            local name = getFlaskName(flask)

            if ImGui.Selectable(("[%d] %s"):format(slot, name), false) then
                callback(slot, flask, name)
            end
        end
        ImGui.EndCombo()
    end
end

return FlaskManager
