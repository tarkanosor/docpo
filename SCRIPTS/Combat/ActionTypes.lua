local Lazy = require("CoreLib.Lazy")

---@class PoE2Lib.Combat.ActionTypes
local ActionTypes = {}

local BasicActionIDs = Lazy.Table(function()
    ---@type table<string, integer>
    local ids = {}
    for _, actionType in pairs(Infinity.PoE2.getFileController():getActionTypesFile():getAll()) do
        if actionType:isEnabled() and actionType:isBasicActionType() then
            ids[actionType:getText()] = actionType:getId()
        end
    end
    return ids
end)

--- Gets the ID of a basic action by its name. This is the ID that is used in
--- packets for basic actions. If the action is not enabled or not a basic
--- action, this will throw an error.
---
---@param name string
---@return integer
function ActionTypes.BasicID(name)
    local id = BasicActionIDs[name]
    assert(id ~= nil, "Unknown basic action type: " .. name)
    return 0x20000000 + id
end

--- This is a utility function to easily find the name of an action by its ID.
--- It's mostly useful during development and debugging to find the
--- corresponding name of an action.
---
---@param id integer
---@return ActionType?
function ActionTypes.ByID(id)
    local short = bit.band(id, 0xFFFF)
    for _, actionType in pairs(Infinity.PoE2.getFileController():getActionTypesFile():getAll()) do
        if actionType:getId() == short then
            return actionType
        end
    end
    return nil
end

return ActionTypes
