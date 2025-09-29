local Event = require("CoreLib.Event")
local Core_Events = require("CoreLib.Events")

---@class PoE2Lib.Events : CoreLib.Events
local Events = {}
do -- Inherit from Core_Events
    for key, event in pairs(Core_Events) do
        Events[key] = event
    end
end

Events.OnTileRecalculation = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnTileRecalculation", function()
            self:emit(nil)
        end)
    end,
}

Events.OnInvalidateInstanceCache = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnInvalidateInstanceCache", function()
            self:emit(nil)
        end)
    end,
}

--- This is emitted when the InstanceCache is changed. It happens during
--- OnCachedWorld and OnInvalidateInstanceCache, but guarantees to be fired
--- after InstanceCache has processed those events, avoiding races between
--- callbacks that use the InstanceCache and the InstanceCache itself.
---
--- This should technically be located in PoE2Lib.InstanceCache instead, but
--- that would break the automatic return type inference of the InstanceCache.
Events.OnInstanceCacheChange = Event()

do
    local prevActionTime = 0
    local wasInAction = false
    ---@type CoreLib.Event<{action: ActionWrapper?}>
    Events.OnActionChange = Event {
        hook = function(self)
            Events.OnPulse:register(function()
                local lPlayer = Infinity.PoE2.getLocalPlayer()
                if lPlayer == nil then
                    return
                end

                local action = lPlayer:getCurrentAction()
                if action == nil then
                    if wasInAction then
                        wasInAction = false
                        self:emit({ action = nil })
                    end
                    return
                end

                local startTime = action:getStartTime()
                if startTime == prevActionTime then
                    return
                end

                prevActionTime = startTime
                wasInAction = true
                self:emit({ action = action })
            end)
        end,
    }
end

---@type CoreLib.Event<{action: ActionWrapper}>
Events.OnActionExecute = Event {
    hook = function(self)
        Events.OnActionChange:register(function(data)
            if data.action == nil then
                return
            end
            self:emit(data)
        end)
    end,
}

---@type CoreLib.Event<WorldActor>
Events.OnNewActor = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnNewActor", function(actor)
            self:emit(actor)
        end)
    end,
}

---@type CoreLib.Event<WorldActor>
Events.OnForgetActor = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnForgetActor", function(actor)
            self:emit(actor)
        end)
    end,
}

---@type CoreLib.Event<{inventory: ServerInventory, item: ItemActor}>
Events.OnPlayerInventoryItemAdded = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnPlayerInventoryItemAdded", function(inventory, item)
            self:emit({ inventory = inventory, item = item })
        end)
    end,
}

---@type CoreLib.Event<{inventory: ServerInventory, item: ItemActor}>
Events.OnPlayerInventoryItemRemoved = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnPlayerInventoryItemRemoved", function(inventory, item)
            self:emit({ inventory = inventory, item = item })
        end)
    end,
}

---@type CoreLib.Event<nil>
Events.OnTeleport = Event {
    hook = function(self)
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnTeleport", function()
            self:emit(nil)
        end)
    end,
}

do
    local wasAlive = true
    ---@type CoreLib.Event<nil>
    Events.OnPlayerDeath = Event {
        ---@param self CoreLib.Event<nil>
        hook = function(self)
            Events.OnPulse:register(function()
                local alive = Infinity.PoE2.getLocalPlayer():isAlive()
                if not alive and wasAlive then
                    self:emit(nil)
                end
                wasAlive = alive
            end)
        end,
    }
end

---@type CoreLib.Event<fun(isHighDanger: boolean, id: integer, duration: integer, points: Vector3[])>
Events.OnCustomDangerPolygonQuery = Event {
    hook = function(self)
        ---@param addPolygon fun(isHighDanger: boolean, id: integer, duration: integer, points: Vector3[])
        ---@diagnostic disable-next-line: param-type-mismatch
        Infinity.Scripting.GetCurrentScript():RegisterCallback("Infinity.OnCustomDangerPolygonQuery", function(addPolygon)
            self:emit(addPolygon)
        end)
    end,
}

return Events
