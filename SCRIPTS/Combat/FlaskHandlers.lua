---@class PoE2Lib.Combat.FlaskHandlers
local FlaskHandlers = {}

--- This is an ordered list of handler classes including short titles for
--- drawing the UI. It's logically ordered, so generic handlers appear on top.
FlaskHandlers.HandlerNames = { --
    "LifeFlaskHandler",
    "ManaFlaskHandler",
    -- Flask specific handlers should be alphabetically sorted. Hypothetically they
    -- all have the same specificity, so this should be fine. But alphabetically
    -- sorting it makes it easier for the user to find a handler in the list.
    "BaseFlaskHandler",
}

do
    ---@type PoE2Lib.Combat.FlaskHandler[]
    FlaskHandlers.List = {}

    --- A map of table<name, handler> that we can use to deserialize configs
    --- and lookup handlers classes by their full names.
    ---@type table<string, PoE2Lib.Combat.FlaskHandler>
    FlaskHandlers.NameMap = {}

    ---@type table<PoE2Lib.Combat.FlaskHandler, string>
    FlaskHandlers.NamesByHandler = {}

    ---@type string[]
    FlaskHandlers.ListLabels = {}

    for _, handlerName in ipairs(FlaskHandlers.HandlerNames) do
        local handler = require("PoE2Lib.Combat.FlaskHandlers." .. handlerName)
        table.insert(FlaskHandlers.List, handler)
        FlaskHandlers.NameMap[handlerName] = handler
        FlaskHandlers.NamesByHandler[handler] = handlerName
        table.insert(FlaskHandlers.ListLabels, handler.shortName)
    end
end

---@param name string
---@return PoE2Lib.Combat.FlaskHandler?
function FlaskHandlers.ByName(name)
    return FlaskHandlers.NameMap[name]
end

--- Try to find the name of the skill handler. Only works for the classes, not
--- for instances.
---@param handlerClass PoE2Lib.Combat.FlaskHandler
---@return string? name
function FlaskHandlers.NameOf(handlerClass)
    return FlaskHandlers.NamesByHandler[handlerClass]
end

--- Gets the default handler class for a flask based on the properties of the
--- flask.
---
--- A default handler will always be returned, so the user will get a suggested
--- handler in every case. The caller should decide whether to present it or not
--- based on the error message.
---
---@param flask? ItemActor
---@return PoE2Lib.Combat.FlaskHandler
---@return string? error
function FlaskHandlers.GetDefaultFlaskHandler(flask)
    if flask == nil then
        return FlaskHandlers.NameMap.BaseFlaskHandler, "PoE2Lib.Combat.LifeFlaskHandler: Flask is nil"
    end

    local flaskType = flask:getFlaskType()
    local uniqueName = flask:getItemName()
    local name = uniqueName ~= "" and uniqueName or flask:getName()
    local localStats = flask:getStatsLocal()

    -- We check the handler list in descending order of specificity, which is
    -- the inverse of the logical order in which we display the handlers (for
    -- the most part).
    for i = #FlaskHandlers.List, 1, -1 do
        local handlerClass = FlaskHandlers.List[i]
        if handlerClass.canHandle(flask, name, flaskType, localStats) then
            return handlerClass, nil
        end
    end

    return FlaskHandlers.NameMap.BaseFlaskHandler, nil
end

return FlaskHandlers
