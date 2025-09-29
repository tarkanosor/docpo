local FlaskHandlers = PoE2Lib.Combat.FlaskHandlers

--- This is a list of flask handers. Generic handlers are logically ordered at
--- the top. Specific handlers are alphabetically ordered after that.
---@type PoE2Lib.Combat.FlaskHandler[]
PoE2Lib.Combat.FlaskHandlerList = {}

local FIXED_HANDLER_ORDER = { --
    [FlaskHandlers.BaseFlaskHandler] = 1,
    [FlaskHandlers.LifeFlaskHandler] = 2,
    [FlaskHandlers.ManaFlaskHandler] = 3,
    [FlaskHandlers.HybridFlaskHandler] = 4,
    [FlaskHandlers.UtilityFlaskHandler] = 5,
    [FlaskHandlers.WrithingJarFlaskHandler] = 7,
}

--- A map of table<name, handler> that we can use to deserialize configs and
--- lookup handlers classes by their full names.
---@type table<PoE2Lib.Combat.FlaskHandler, string>
PoE2Lib.Combat.FlaskHandlersNameMap = {}

---@type table<string, PoE2Lib.Combat.FlaskHandler>
PoE2Lib.Combat.FlaskHandlersShortNameMap = {}

---@type string[]
PoE2Lib.Combat.FlaskHandlersShortNames = {}

do
    for k, handler in pairs(PoE2Lib.Combat.FlaskHandlers) do
        PoE2Lib.Combat.FlaskHandlersNameMap[handler] = k
        PoE2Lib.Combat.FlaskHandlersShortNameMap[handler.shortName] = handler
        table.insert(PoE2Lib.Combat.FlaskHandlerList, handler)
    end

    table.sort(PoE2Lib.Combat.FlaskHandlerList, function(a, b)
        local fixedA = (FIXED_HANDLER_ORDER[a] or math.huge)
        local fixedB = (FIXED_HANDLER_ORDER[b] or math.huge)
        if fixedA ~= fixedB then
            return fixedA < fixedB
        end
        return a.shortName < b.shortName
    end)

    for i, handler in ipairs(PoE2Lib.Combat.FlaskHandlerList) do
        PoE2Lib.Combat.FlaskHandlersShortNames[i] = handler.shortName
    end
end

---@param name string
---@return PoE2Lib.Combat.FlaskHandler?
function PoE2Lib.Combat.FlaskHandlerByName(name)
    return FlaskHandlers[name]
end

--- Try to find the name of the combat addons. Only works for the classes, not
--- for instances.
---@param handlerClass PoE2Lib.Combat.FlaskHandler
---@return string? name
function PoE2Lib.Combat.NameOfFlaskHandler(handlerClass)
    return PoE2Lib.Combat.FlaskHandlersNameMap[handlerClass]
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
function PoE2Lib.Combat.GetDefaultFlaskHandler(flask)
    if flask == nil then
        return FlaskHandlers.BaseFlaskHandler, "PoE2Lib.Combat.LifeFlaskHandler: Flask is nil"
    end

    local itemClass = flask:getItemClass()
    local name = flask:getName()
    local cMods = flask:getComponent_Mods()
    if cMods ~= nil then
        local uniqueName = cMods:getUniqueName()
        if uniqueName ~= '' then
            name = uniqueName
        end
    end

    local cLocalStats = flask:getComponent_LocalStats()
    if cLocalStats == nil then
        return FlaskHandlers.BaseFlaskHandler, "PoE2Lib.Combat.GetDefaultHandler: Flasks's LocalStats component is nil"
    end

    -- We check the handler list in descending order of specificity, which is
    -- the inverse of the logical order in which we display the handlers (for
    -- the most part).
    for i = #PoE2Lib.Combat.FlaskHandlerList, 1, -1 do
        local handlerClass = PoE2Lib.Combat.FlaskHandlerList[i]
        if handlerClass.canHandle(flask, name, itemClass, cLocalStats) then
            return handlerClass, nil
        end
    end

    return FlaskHandlers.BaseFlaskHandler, nil
end
