local FlaskStats = require('PoE2Lib.Combat.FlaskStats')
local FlaskHandler = require('PoE2Lib.Combat.FlaskHandler')

---@class PoE2Lib.Combat.FlaskHandlers.BaseFlaskHandler : PoE2Lib.Combat.FlaskHandler
---@overload fun(config: PoE2Lib.Combat.FlaskHandler.Config): PoE2Lib.Combat.FlaskHandlers.BaseFlaskHandler
local BaseFlaskHandler = FlaskHandler:extend()

BaseFlaskHandler.shortName = 'Base'

BaseFlaskHandler.description = [[
    This is a flask handler with no logic. It will use a flask when it has
    enough charges. You can still customise this with conditions.
]]

BaseFlaskHandler.settings = { --
}

BaseFlaskHandler:setCanHandle(function(flask, name, itemClass, cLocalStats)
    return false
end)

function BaseFlaskHandler:setup()
end

---@param target WorldActor?
---@return boolean ok, string? reason
function BaseFlaskHandler:canUse(target)
    local baseOk, baseReason = self:baseCanUse(target)
    if not baseOk then
        return false, baseReason
    end

    return true, nil
end

---@param key string
function BaseFlaskHandler:drawSettings(key)
    local function label(title, id)
        return ("%s##base_flask_handler_%s_%s"):format(title, id, key)
    end

    ImGui.PushItemWidth(120)

    ImGui.PopItemWidth()
end

return BaseFlaskHandler
