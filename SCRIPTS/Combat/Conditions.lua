local UI = require("CoreLib.UI")
local Table = require("CoreLib.Table")

---@class PoE2Lib.Combat.Conditions
local Conditions = {}

---@alias PoE2Lib.Combat.Conditions.HandlerUnion (PoE2Lib.Combat.SkillHandler|PoE2Lib.Combat.CombatAddon|PoE2Lib.Combat.FlaskHandler)

---@class PoE2Lib.Combat.Conditions.Definition
---@field label string
---@field default any
---@field evaluate fun(value: any, target?: WorldActor, handler?: PoE2Lib.Combat.Conditions.HandlerUnion): boolean
---@field draw? (fun(key: string, value: any):boolean, any)

---@class PoE2Lib.Combat.Conditions.Config
---@field label string
---@field value any

--- This is a map indexed by the condition labels for quick access.
---@type table<string, PoE2Lib.Combat.Conditions.Definition>
Conditions.Map = {}

--- List of labels for drawing the UI.
---@type string[]
Conditions.Labels = {}

--- Indexed map of labels and indices for getting the index of a label.
---@type table<string, number>
Conditions.Index = {}

---@param condition PoE2Lib.Combat.Conditions.Definition
local function Define(condition)
    Conditions.Map[condition.label] = condition
    table.insert(Conditions.Labels, condition.label)
    Conditions.Index[condition.label] = #Conditions.Labels
end

---@param definition? PoE2Lib.Combat.Conditions.Definition
---@return PoE2Lib.Combat.Conditions.Config config
function Conditions.NewConfig(definition)
    if definition == nil then
        -- Default to the first definition.
        return Conditions.NewConfig(Conditions.Map[Conditions.Labels[1]])
    end
    return { label = definition.label, value = Table.Copy(definition.default) }
end

---@param config PoE2Lib.Combat.Conditions.Config
---@param target WorldActor?
---@param handler PoE2Lib.Combat.Conditions.HandlerUnion
---@return boolean ok
function Conditions.Check(config, target, handler)
    assert(Conditions.Map[config.label], ("Condition with label '%s' does not exist"):format(config.label))
    return Conditions.Map[config.label].evaluate(config.value, target, handler)
end

---@return boolean changed
function Conditions.Draw(key, config)
    local currentIndex = Conditions.Index[config.label]

    ImGui.PushItemWidth(150)
    local labelChanged, newIndex = ImGui.Combo("##condition_label_" .. key, currentIndex, Conditions.Labels)
    ImGui.PopItemWidth()

    if labelChanged then
        config.label = Conditions.Labels[newIndex]
        config.value = Table.Copy(Conditions.Map[config.label].default)
    end

    local definition = Conditions.Map[config.label]
    local valueChanged = false
    if definition.draw then
        ImGui.SameLine()
        valueChanged, config.value = definition.draw(key, config.value)
    end
    return labelChanged or valueChanged
end

--- This is the default condition, which is empty and does nothing.
Define {
    label = '---',
    default = true,
    evaluate = function(value, target, handler)
        return true
    end,
    draw = function(key, value)
        ImGui.Text('Select a condition')
        return false, value
    end,
}

Define {
    label = 'AND',
    default = { Conditions.NewConfig(), Conditions.NewConfig() },
    evaluate = function(value, target, handler)
        for _, config in ipairs(value) do
            if not Conditions.Check(config, target, handler) then
                return false
            end
        end
        return true
    end,
    draw = function(key, value)
        local changed = false
        if ImGui.Button('Add##condition_and_add_' .. key) then
            table.insert(value, Conditions.NewConfig())
            changed = true
        end
        ImGui.Indent()
        for i, config in ipairs(value) do
            local childKey = key .. '_c' .. i
            if ImGui.Button('X##condition_and_remove_' .. childKey) then
                table.remove(value, i)
            end
            ImGui.SameLine()
            if Conditions.Draw(childKey, config) then
                changed = true
            end
        end
        ImGui.Unindent()
        return changed, value
    end,
}

Define {
    label = 'OR',
    default = { Conditions.NewConfig(), Conditions.NewConfig() },
    evaluate = function(value, target, handler)
        for _, config in ipairs(value) do
            if Conditions.Check(config, target, handler) then
                return true
            end
        end
        return false
    end,
    draw = function(key, value)
        local changed = false
        if ImGui.Button('Add##condition_or_add_' .. key) then
            table.insert(value, Conditions.NewConfig())
            changed = true
        end
        ImGui.Indent()
        for i, config in ipairs(value) do
            local childKey = key .. '_c' .. i
            if ImGui.Button('X##condition_or_remove_' .. childKey) then
                table.remove(value, i)
                changed = true
            end
            ImGui.SameLine()
            if Conditions.Draw(childKey, config) then
                changed = true
            end
        end
        ImGui.Unindent()
        return changed, value
    end,
}

Define {
    label = 'Player Life >= %',
    default = 0,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getHpPercentage() >= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_life_ge_" .. key, value)
    end,
}

Define {
    label = 'Player Life <= %',
    default = 100,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getHpPercentage() <= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_life_le_" .. key, value)
    end,
}

Define {
    label = 'Player Mana >= %',
    default = 0,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getMpPercentage() >= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_mana_ge_" .. key, value)
    end,
}

Define {
    label = 'Player Mana <= %',
    default = 100,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getMpPercentage() <= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_mana_le_" .. key, value)
    end,
}

Define {
    label = 'Player ES >= %',
    default = 0,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getEsPercentage() >= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_es_ge_" .. key, value)
    end,
}

Define {
    label = 'Player ES <= %',
    default = 100,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        return lPlayer:getEsPercentage() <= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_es_le_" .. key, value)
    end,
}

Define {
    label = 'Player Rage >=',
    default = 0,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        for _, buff in pairs(lPlayer:getBuffs()) do
            if buff:getKey() == 'rage' then
                return buff:getCharges() >= value
            end
        end
        return false
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_rage_ge_" .. key, value)
    end,
}

Define {
    label = 'Player Rage <=',
    default = 50,
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        for _, buff in pairs(lPlayer:getBuffs()) do
            if buff:getKey() == 'rage' then
                return buff:getCharges() <= value
            end
        end
        return true
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_player_rage_le_" .. key, value)
    end,
}

Define {
    label = 'Player has buff',
    default = { name = '', checkCharges = 'ignore', charges = 0, checkTimeLeft = 'ignore', timeLeft = 0 },
    evaluate = function(value, target, handler)
        local hasCharges = false
        local hasTimeLeft = false
        local charges = 0
        for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
            if buff:getKey() == value.name then
                hasCharges = value.checkCharges == 'ignore'
                hasTimeLeft = value.checkTimeLeft == 'ignore' or value.checkTimeLeft == nil
                if value.checkCharges ~= 'ignore' then
                    charges = charges + buff:getCharges()
                end
                if value.checkTimeLeft == '>=' then
                    hasTimeLeft = buff:getTimeLeft() >= value.timeLeft
                elseif value.checkTimeLeft == '<=' then
                    hasTimeLeft = buff:getTimeLeft() <= value.timeLeft
                end
            end
        end
        if value.checkCharges == '>=' then
            hasCharges = charges >= value.charges
        elseif value.checkCharges == '<=' then
            hasCharges = charges <= value.charges
        end
        return hasCharges and hasTimeLeft
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(200)
        _, value.name = ImGui.InputText("##condition_player_has_buff_" .. key, value.name)
        ImGui.PopItemWidth()

        ImGui.Indent()
        ImGui.Text('Charges:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_player_has_buff_check_charges_" .. key, Table.FindIndex(labels, value.checkCharges) or 1, labels)
        if changed then
            value.checkCharges = labels[new]
        end
        ImGui.PopItemWidth()

        ImGui.SameLine()
        UI.WithDisable(value.checkCharges == 'ignore', function()
            ImGui.PushItemWidth(100)
            _, value.charges = ImGui.InputInt("##condition_player_has_buff_charges_" .. key, value.charges)
            ImGui.PopItemWidth()
        end)
        ImGui.Text('Time left:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_player_has_buff_check_time_left_" .. key, Table.FindIndex(labels, value.checkTimeLeft) or 1, labels)
        if changed then
            value.checkTimeLeft = labels[new]
        end
        ImGui.PopItemWidth()
        ImGui.SameLine()
        UI.WithDisable(value.checkTimeLeft == 'ignore' or value.checkTimeLeft == nil, function()
            ImGui.PushItemWidth(100)
            _, value.timeLeft = ImGui.InputInt("##condition_player_has_buff_time_left_" .. key, value.timeLeft or 0)
            ImGui.PopItemWidth()
        end)
        ImGui.Unindent()

        return false, value
    end,
}

Define {
    label = 'Player not has buff',
    default = { name = '', checkCharges = 'ignore', charges = 0, checkTimeLeft = 'ignore', timeLeft = 0 },
    evaluate = function(value, target, handler)
        local hasCharges = false
        local hasTimeLeft = false
        local charges = 0
        for _, buff in pairs(Infinity.PoE2.getLocalPlayer():getBuffs()) do
            if buff:getKey() == value.name then
                hasCharges = value.checkCharges == 'ignore'
                hasTimeLeft = value.checkTimeLeft == 'ignore' or value.checkTimeLeft == nil
                if value.checkCharges ~= 'ignore' then
                    charges = charges + buff:getCharges()
                end
                if value.checkTimeLeft == '>=' then
                    hasTimeLeft = buff:getTimeLeft() >= value.timeLeft
                elseif value.checkTimeLeft == '<=' then
                    hasTimeLeft = buff:getTimeLeft() <= value.timeLeft
                end
            end
        end
        if value.checkCharges == '>=' then
            hasCharges = charges >= value.charges
        elseif value.checkCharges == '<=' then
            hasCharges = charges <= value.charges
        end
        return not (hasCharges and hasTimeLeft)
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(200)
        _, value.name = ImGui.InputText("##condition_player_not_has_buff_" .. key, value.name)
        ImGui.PopItemWidth()

        ImGui.Indent()
        ImGui.Text('Charges:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_player_not_has_buff_check_charges_" .. key, Table.FindIndex(labels, value.checkCharges) or 1, labels)
        if changed then
            value.checkCharges = labels[new]
        end
        ImGui.PopItemWidth()

        ImGui.SameLine()
        UI.WithDisable(value.checkCharges == 'ignore', function()
            ImGui.PushItemWidth(100)
            _, value.charges = ImGui.InputInt("##condition_player_not_has_buff_charges_" .. key, value.charges)
            ImGui.PopItemWidth()
        end)

        ImGui.Text('Time left:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_player_not_has_buff_check_time_left_" .. key, Table.FindIndex(labels, value.checkTimeLeft) or 1, labels)
        if changed then
            value.checkTimeLeft = labels[new]
        end
        ImGui.PopItemWidth()

        ImGui.SameLine()
        UI.WithDisable(value.checkTimeLeft == 'ignore' or value.checkTimeLeft == nil, function()
            ImGui.PushItemWidth(100)
            _, value.timeLeft = ImGui.InputInt("##condition_player_not_has_buff_time_left_" .. key, value.timeLeft or 0)
            ImGui.PopItemWidth()
        end)
        ImGui.Unindent()

        return false, value
    end,
}

-- define {
--     label = 'Player is in danger',
--     default = {highDanger = false},
--     evaluate = function(value, target, handler)
--         if value.highDanger then
--             return Infinity.PoE2.WorldManager.getNavigator():isLocationInHighDanger(Infinity.PoE2.getLocalPlayer():getPosition():getLocation())
--         else
--             return Infinity.PoE2.WorldManager.getNavigator():isLocationInDanger(Infinity.PoE2.getLocalPlayer():getPosition():getLocation())
--         end
--     end,
--     draw = function(key, value)
--         _, value.highDanger = ImGui.Checkbox("High danger only##condition_player_in_danger_highdanger_" .. key, value.highDanger)
--         return false, value
--     end,
-- }

Define {
    label = 'Player is moving',
    default = true,
    evaluate = function(value, target, handler)
        return Infinity.PoE2.getLocalPlayer():isMoving()
    end,
    -- draw = function(key, value)
    --     return false, value
    -- end
}

Define {
    label = 'Player is not moving',
    default = true,
    evaluate = function(value, target, handler)
        return not Infinity.PoE2.getLocalPlayer():isMoving()
    end,
    -- draw = function(key, value)
    --     return false, value
    -- end
}

-- define {
--     label = 'Player MS >= %',
--     default = 0,
--     evaluate = function(value, target, handler)
--         local lPlayer = Infinity.PoE2.getLocalPlayer()
--         local cstats = lPlayer and lPlayer:getComponent_Stats()
--         local ms = cstats and cstats:getStatValue(StatsEnum.MovementSpeed)
--         return ms ~= nil and ms >= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_player_ms_ge_" .. key, value)
--     end,
-- }

-- define {
--     label = 'Player MS <= %',
--     default = 300,
--     evaluate = function(value, target, handler)
--         local lPlayer = Infinity.PoE2.getLocalPlayer()
--         local cstats = lPlayer and lPlayer:getComponent_Stats()
--         local ms = cstats and cstats:getStatValue(StatsEnum.MovementSpeed)
--         return ms ~= nil and ms <= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_player_es_le_" .. key, value)
--     end,
-- }

Define {
    label = "Player mob count",
    default = { operator = '>=', count = 1, range = 30, checkLoS = false, flyable = false },
    evaluate = function(value, target, handler)
        if value.operator == '>=' then
            return Infinity.PoE2.getLocalPlayer():getCloseAttackableEnemyCount(value.range, value.checkLoS, value.flyable) >= value.count
        elseif value.operator == '<=' then
            return Infinity.PoE2.getLocalPlayer():getCloseAttackableEnemyCount(value.range, value.checkLoS, value.flyable) <= value.count
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_player_mob_count_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.count = ImGui.InputInt("##condition_player_mob_count_count" .. key, value.count)
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.Text("within")
        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.range = ImGui.InputInt("range##condition_player_mob_count_range" .. key, value.range)
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.Text("with line of sight:")
        ImGui.SameLine()
        _, value.checkLoS = ImGui.Checkbox("##condition_player_mob_count_los" .. key, value.checkLoS)

        ImGui.SameLine()
        ImGui.Text("flyable:")
        ImGui.SameLine()
        _, value.flyable = ImGui.Checkbox("##condition_player_mob_count_flyable" .. key, value.flyable)

        return false, value
    end,
}

Define {
    label = 'Not in hideout',
    default = true,
    evaluate = function(value, target, handler)
        return not Infinity.PoE2.getGameStateController():getInGameState():getInGameData():getCurrentWorldArea():isHideout()
    end,
    draw = function(key, value)
        return false, value
    end,
}

Define {
    label = 'Target Life >= %',
    default = 0,
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return target:getHpPercentage() >= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_target_life_ge_" .. key, value)
    end,
}

Define {
    label = 'Target Life <= %',
    default = 100,
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return target:getHpPercentage() <= value
    end,
    draw = function(key, value)
        return ImGui.InputInt("##condition_target_life_le_" .. key, value)
    end,
}

-- define {
--     label = 'Target Mana >= %',
--     default = 0,
--     evaluate = function(value, target, handler)
--         if target == nil then
--             return false
--         end
--         return MagLib.PoE.Player.getLocalPlayerManaPercentage(target) >= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_target_mana_ge_" .. key, value)
--     end
-- }

-- define {
--     label = 'Target Mana <= %',
--     default = 100,
--     evaluate = function(value, target, handler)
--         if target == nil then
--             return false
--         end
--         return MagLib.PoE.Player.getLocalPlayerManaPercentage(target) <= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_target_mana_le_" .. key, value)
--     end
-- }

-- define {
--     label = 'Target ES >= %',
--     default = 0,
--     evaluate = function(value, target, handler)
--         if target == nil then
--             return false
--         end
--         return MagLib.PoE.Player.getLocalPlayerEnergyShieldPercentage(target) >= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_target_es_ge_" .. key, value)
--     end
-- }

-- define {
--     label = 'Target ES <= %',
--     default = 100,
--     evaluate = function(value, target, handler)
--         if target == nil then
--             return false
--         end
--         return MagLib.PoE.Player.getLocalPlayerEnergyShieldPercentage(target) <= value
--     end,
--     draw = function(key, value)
--         return ImGui.InputInt("##condition_target_es_le_" .. key, value)
--     end
-- }

Define {
    label = 'Target has buff',
    default = { name = '', checkCharges = 'ignore', charges = 0 },
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end

        if value.checkCharges == 'ignore' then
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    return true
                end
            end
            return false
        elseif value.checkCharges == '>=' then
            local count = 0
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    count = count + buff:getCharges()
                end
            end
            return count >= value.charges
        elseif value.checkCharges == '<=' then
            local count = 0
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    count = count + buff:getCharges()
                end
            end
            return count <= value.charges
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(200)
        _, value.name = ImGui.InputText("##condition_target_has_buff_" .. key, value.name)
        ImGui.PopItemWidth()

        ImGui.Indent()
        ImGui.Text('Charges:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_target_has_buff_check_charges_" .. key, Table.FindIndex(labels, value.checkCharges) or 1, labels)
        if changed then
            value.checkCharges = labels[new]
        end
        ImGui.PopItemWidth()

        ImGui.SameLine()
        UI.WithDisable(value.checkCharges == 'ignore', function()
            ImGui.PushItemWidth(100)
            _, value.charges = ImGui.InputInt("##condition_target_has_buff_charges_" .. key, value.charges)
            ImGui.PopItemWidth()
        end)
        ImGui.Unindent()

        return false, value
    end,
}

Define {
    label = 'Target not has buff',
    default = { name = '', checkCharges = 'ignore', charges = 0 },
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end

        if value.checkCharges == 'ignore' then
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    return false
                end
            end
            return true
        elseif value.checkCharges == '>=' then
            local count = 0
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    count = count + buff:getCharges()
                end
            end
            return count < value.charges
        elseif value.checkCharges == '<=' then
            local count = 0
            for _, buff in pairs(target:getBuffs()) do
                if buff:getKey() == value.name then
                    count = count + buff:getCharges()
                end
            end
            return count > value.charges
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(200)
        _, value.name = ImGui.InputText("##condition_target_not_has_buff_" .. key, value.name)
        ImGui.PopItemWidth()

        ImGui.Indent()
        ImGui.Text('Charges:')
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        local labels = { "ignore", ">=", "<=" }
        local changed, new = ImGui.Combo("##condition_target_not_has_buff_check_charges_" .. key, Table.FindIndex(labels, value.checkCharges) or 1, labels)
        if changed then
            value.checkCharges = labels[new]
        end
        ImGui.PopItemWidth()

        ImGui.SameLine()
        UI.WithDisable(value.checkCharges == 'ignore', function()
            ImGui.PushItemWidth(100)
            _, value.charges = ImGui.InputInt("##condition_target_not_has_buff_charges_" .. key, value.charges)
            ImGui.PopItemWidth()
        end)
        ImGui.Unindent()

        return false, value
    end,
}

Define {
    label = 'Target rarity >=',
    default = "White",
    ---@param target WorldActor
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return target:getRarity() >= Infinity.PoE2.Enums.ERarity.getEnumByText(value)
    end,
    draw = function(key, value)
        local labels = { "White", "Magic", "Rare", "Unique" }
        local current = Table.FindIndex(labels, value) or 1
        local changed, new = ImGui.Combo("##condition_target_rarity_ge" .. key, current, labels)
        return changed, labels[new]
    end,
}

Define {
    label = 'Target rarity <=',
    default = "Unique",
    ---@param target WorldActor
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return target:getRarity() <= Infinity.PoE2.Enums.ERarity.getEnumByText(value)
    end,
    draw = function(key, value)
        local labels = { "White", "Magic", "Rare", "Unique" }
        local current = Table.FindIndex(labels, value) or 1
        local changed, new = ImGui.Combo("##condition_target_rarity_le" .. key, current, labels)
        return changed, labels[new]
    end,
}

Define {
    label = 'Target distance',
    default = { operator = '>=', distance = 0 },
    ---@param target WorldActor
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        if value.operator == '>=' then
            return target:getDistanceToPlayer() >= value.distance
        elseif value.operator == '<=' then
            return target:getDistanceToPlayer() <= value.distance
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_target_distance_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.distance = ImGui.InputInt("##condition_target_distance_distance" .. key, value.distance)
        ImGui.PopItemWidth()

        return false, value
    end,
}

Define {
    label = "Target mob count",
    default = { operator = '>=', count = 1, range = 30, checkLoS = false, flyable = false },
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        if value.operator == '>=' then
            return target:getCloseAttackableEnemyCount(value.range, value.checkLoS, value.flyable) >= value.count
        elseif value.operator == '<=' then
            return target:getCloseAttackableEnemyCount(value.range, value.checkLoS, value.flyable) <= value.count
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_target_mob_count_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.count = ImGui.InputInt("##condition_target_mob_count_count" .. key, value.count)
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.Text("within")
        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.range = ImGui.InputInt("range##condition_target_mob_count_range" .. key, value.range)
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.Text("with line of sight:")
        ImGui.SameLine()
        _, value.checkLoS = ImGui.Checkbox("##condition_target_mob_count_los" .. key, value.checkLoS)

        ImGui.SameLine()
        ImGui.Text("flyable:")
        ImGui.SameLine()
        _, value.flyable = ImGui.Checkbox("##condition_target_mob_count_flyable" .. key, value.flyable)

        return false, value
    end,
}

Define {
    label = "Target Cullable",
    default = true,
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        local thresholds = { --
            [ERarity_White] = 30,
            [ERarity_Magic] = 20,
            [ERarity_Rare] = 10,
            [ERarity_Unique] = 5,
        }
        local threshold = thresholds[target:getRarity()] or 0
        local cullable = target:getHpPercentage() <= threshold
        return value == cullable
    end,
    draw = function(key, value)
        local labels = { "Yes", "No" }
        local current = value and 1 or 2
        local changed, new = ImGui.Combo("##condition_target_cullable" .. key, current, labels)
        return changed, new == 1
    end,
}


Define {
    label = "Target Primed For Stun",
    default = true,
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return value == target:isPrimedForStun()
    end,

    draw = function(key, value)
        local labels = { "Yes", "No" }
        local current = value and 1 or 2
        local changed, new = ImGui.Combo("##condition_target_primedForStun" .. key, current, labels)
        return changed, new == 1
    end,
}

Define {
    label = 'Target is moving',
    default = true,
    evaluate = function(value, target, handler)
        if target == nil then
            return false
        end
        return target:isMoving()
    end,
    draw = function(key, value)
        local labels = { "Yes", "No" }
        local current = value and 1 or 2
        local changed, new = ImGui.Combo("##condition_target_is_moving" .. key, current, labels)
        return changed, new == 1
    end,
}

Define {
    label = 'Time since last use >=',
    default = 1.0,
    evaluate = function(value, target, handler)
        if handler == nil then
            return false
        end
        local since = (Infinity.Win32.GetTickCount() - (handler.lastExecuteTick or handler.lastUseTick))
        return since > (value * 1000)
    end,
    draw = function(key, value)
        return ImGui.InputFloat("seconds##condition_time_last_use_ge_" .. key, value)
    end,
}

Define {
    label = "Skill charges",
    default = { operator = '>=', charges = 1 },
    evaluate = function(value, target, handler)
        if handler.getSkillObject == nil then
            return false
        end
        ---@cast handler PoE2Lib.Combat.SkillHandler
        local skill = handler:getSkillObject()
        if skill == nil then
            return false
        end
        if value.operator == '>=' then
            return skill:getCharges() >= value.charges
        elseif value.operator == '<=' then
            return skill:getCharges() <= value.charges
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_skill_charges_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.charges = ImGui.InputInt("##condition_skill_charges_charges" .. key, value.charges)
        ImGui.PopItemWidth()

        return false, value
    end,
}

Define {
    label = "Flask charges",
    default = { operator = '>=', charges = 1 },
    evaluate = function(value, target, handler)
        if handler.getFlask == nil then
            return false
        end
        ---@cast handler PoE2Lib.Combat.FlaskHandler
        local flask = handler:getFlask()
        if flask == nil then
            return false
        end
        if value.operator == '>=' then
            return flask:getCurrentCharges() >= value.charges
        elseif value.operator == '<=' then
            return flask:getCurrentCharges() <= value.charges
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_flask_charges_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.charges = ImGui.InputInt("##condition_flask_charges_charges" .. key, value.charges)
        ImGui.PopItemWidth()

        return false, value
    end,
}

Define {
    label = "Unleash seals",
    default = { operator = '>=', charges = 1 },
    evaluate = function(value, target, handler)
        if handler.getSkillObject == nil then
            return false
        end
        ---@cast handler PoE2Lib.Combat.SkillHandler
        local skill = handler:getSkillObject()
        if skill == nil then
            return false
        end
        if value.operator == '>=' then
            local count = 0
            for _, buff in pairs(handler:getAssociatedBuffs()) do
                if buff:getKey() == 'anticipation' then
                    count = count + buff:getCharges()
                end
            end
            return count >= value.charges
        elseif value.operator == '<=' then
            local count = 0
            for _, buff in pairs(handler:getAssociatedBuffs()) do
                if buff:getKey() == 'anticipation' then
                    count = count + buff:getCharges()
                end
            end
            return count <= value.charges
        else
            return false
        end
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(60)
        value.operator, _ = UI.StringCombo("##condition_unleash_seals_operator" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()

        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.charges = ImGui.InputInt("##condition_unleash_seals_charges" .. key, value.charges)
        ImGui.PopItemWidth()

        return false, value
    end,
}

Define {
    label = 'Have summoned/deployed',
    default = { metaPath = '', count = 1, operator = '>=' },
    ---@param value {metaPath: string, count: integer, operator: '>='|'<='}
    evaluate = function(value, target, handler)
        local lPlayer = Infinity.PoE2.getLocalPlayer()
        if lPlayer == nil then
            return false
        end
        local count = 0
        for _, deployedObject in pairs(lPlayer:getDeployedObjects()) do
            if deployedObject:getMetaPath():find(value.metaPath) then
                count = count + 1
            end
        end
        if value.operator == '>=' then
            return count >= value.count
        elseif value.operator == '<=' then
            return count <= value.count
        else -- Should not happen
            return false
        end
    end,
    ---@param value {metaPath: string, count: integer, operator: '>='|'<='}
    draw = function(key, value)
        -- Empty text to break line
        ImGui.Text('')

        ImGui.Indent()

        ImGui.PushItemWidth(300)
        _, value.metaPath = ImGui.InputText("Metapath##condition_have_summoned_metapath_" .. key, value.metaPath)
        UI.Tooltip("The metapath of the summonable. Can be a partial match.")
        ImGui.PopItemWidth()

        ImGui.PushItemWidth(50)
        value.operator = UI.StringCombo("##condition_have_summoned_metapath_" .. key, value.operator, { ">=", "<=" })
        ImGui.PopItemWidth()
        ImGui.SameLine()
        ImGui.PushItemWidth(80)
        _, value.count = ImGui.InputInt("Count##condition_have_summoned_metapath_" .. key, value.count)
        ImGui.PopItemWidth()

        ImGui.Unindent()

        return false, value
    end,
}

Define {
    label = "Key is pressed",
    default = KeyCode_SPACE,
    evaluate = function(value, target, handler)
        return bit.band(Infinity.Win32.GetAsyncKeyState(value), 0x8000) ~= 0
    end,
    draw = function(key, value)
        ImGui.PushItemWidth(200)
        local new, changed = UI.KeySelector("##condition_key_pressed_" .. key, value)
        ImGui.PopItemWidth()
        return changed, new
    end,
}

return Conditions
