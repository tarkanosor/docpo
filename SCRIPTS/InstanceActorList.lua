local Class = require("CoreLib.Class")
local InstanceCache = require("PoE2Lib.InstanceCache")
local Events = require("PoE2Lib.Events")

--- InstanceActorList is a list of actors that is automatically maintained
--- when actors are seen and forgotten.
---
--- An EActorType and a filter function can be provided to filter the actors.
--- If the filter function returns false or nil, the actor is not added to the
--- list.
---
---@class PoE2Lib.InstanceActorList<T> : Class
local InstanceActorList = Class()

---@private
---@type integer? EActorType
InstanceActorList.actorType = nil

---@private
---@type (fun(actor: WorldActor):any)?
InstanceActorList.filter = nil

---@private
---@param actorType integer? EActorType
---@param filter (fun(actor: WorldActor):any)?
function InstanceActorList:init(actorType, filter)
    self.actorType = actorType
    self.filter = filter

    ---@private
    self.cache = InstanceCache {
        ---@type boolean
        instanceSeen = false,
        ---@type { [integer]: any }
        actors = {},
    }

    self:bind()
    self:rebuild()
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

-- The event handlers are stored as fields on the class so that they can be
-- unregistered.

---@private
---@type fun(actor: WorldActor)?
InstanceActorList.onNewActor = nil

---@private
---@type fun(actor: WorldActor)?
InstanceActorList.onForgetActor = nil

---@private
---@type fun()?
InstanceActorList.onCachedWorld = nil

--- Binds the events needed to keep the list up to date.
---
--- This is called automatically when the list is created.
---
---@private Marked as private until we find a use case where this is needed elsewhere.
function InstanceActorList:bind()
    if self.onNewActor == nil then
        self.onNewActor = function(actor)
            if self.actorType == nil or actor:hasActorType(self.actorType) then
                self:process(actor)
            end
        end

        Events.OnNewActor:register(self.onNewActor)
    end

    if self.onForgetActor == nil then
        self.onForgetActor = function(actor)
            self:forget(actor)
        end

        Events.OnForgetActor:register(self.onForgetActor)
    end

    if self.onCachedWorld == nil then
        self.onCachedWorld = function()
            self:rebuild()
        end

        Events.OnInstanceCacheChange:register(self.onCachedWorld)
    end
end

--- Unbinds the events needed to keep the cache up to date.
---
---@private Marked as private until we find a use case where this is needed elsewhere.
function InstanceActorList:unbind()
    if self.onNewActor ~= nil then
        Events.OnNewActor:unregister(self.onNewActor)
        self.onNewActor = nil
    end

    if self.onForgetActor ~= nil then
        Events.OnForgetActor:unregister(self.onForgetActor)
        self.onForgetActor = nil
    end

    if self.onCachedWorld ~= nil then
        Events.OnCachedWorld:unregister(self.onCachedWorld)
        self.onCachedWorld = nil
    end
end

--------------------------------------------------------------------------------
-- Actor Handling
--------------------------------------------------------------------------------

---@private
---@param actor WorldActor
---@return boolean ok
function InstanceActorList:process(actor)
    if self.filter == nil then
        self.cache.actors[actor:getActorId()] = true
        return true
    end

    local result = self.filter(actor)
    if result == false then
        result = nil
    end

    self.cache.actors[actor:getActorId()] = result
    return result ~= nil
end

---@param actor WorldActor|integer
function InstanceActorList:forget(actor)
    if type(actor) == "number" then
        self.cache.actors[actor] = nil
        return
    else
        ---@cast actor WorldActor
        self.cache.actors[actor:getActorId()] = nil
    end
end

--- Rebuilds the actor list from scratch.
function InstanceActorList:rebuild()
    -- Reset the list
    self.cache.actors = {}

    -- Process all actors
    for _, actor in pairs(self.actorType ~= nil and Infinity.PoE2.getActorsByType(self.actorType) or Infinity.PoE2.getActors()) do
        self:process(actor)
    end
end

---@param actorId integer
---@param refilter boolean
---@return WorldActor?
function InstanceActorList:getValidated(actorId, refilter)
    local actor = Infinity.PoE2.getActorByActorId(actorId)
    if actor == nil then
        self:forget(actorId)
        return nil
    end

    if self.actorType ~= nil and not actor:hasActorType(self.actorType) then
        self:forget(actor)
        return nil
    end

    if refilter then
        if not self:process(actor) then
            return nil
        end
    end

    return actor
end

---@param refilter boolean
---@param callback fun(actor: WorldActor, value: any)
function InstanceActorList:forEach(refilter, callback)
    ---@param actorId integer
    ---@param value any
    local function apply(actorId, value)
        local actor = self:getValidated(actorId, refilter)
        if actor ~= nil then
            callback(actor, value)
        end
    end

    for actorId, value in pairs(self.cache.actors) do
        apply(actorId, value)
    end
end

---@generic T
---@param refilter boolean
---@return fun(_, prevActor: WorldActor?): WorldActor?, T
---@return PoE2Lib.InstanceActorList
---@return integer?
function InstanceActorList:iter(refilter)
    local iter = function(_, prevActor)
        local k = prevActor and prevActor:getActorId()
        local value = nil
        while true do
            k, value = next(self.cache.actors, k)
            if k == nil then
                return nil, nil
            end
            local actor = self:getValidated(k, refilter)
            if actor ~= nil then
                return actor, value
            end
            -- Continue while
        end
    end
    return iter, self, nil
end

---@param actor WorldActor|integer
function InstanceActorList:contains(actor)
    if type(actor) == "number" then
        return self.cache.actors[actor] ~= nil
    else
        ---@cast actor WorldActor
        return self.cache.actors[actor:getActorId()] ~= nil
    end
end

--------------------------------------------------------------------------------
-- Typed Public Definition
--------------------------------------------------------------------------------

---@class PoE2Lib.InstanceActorListTyped<T> : {
---  forget: fun(self, actor: WorldActor|integer),
---  rebuild: fun(self),
---  forEach: fun(self, refilter: boolean, callback: fun(actor: WorldActor, value: T)),
---  iter: (fun(self, refilter: boolean): fun(self, prevActor: WorldActor?): WorldActor?, T),
---  contains: (fun(self, actor: WorldActor|integer): boolean),
---}

---@generic T
---@param actorType integer? EActorType
---@param filter (fun(actor: WorldActor):T)?
---@return PoE2Lib.InstanceActorListTyped<T>
return function(actorType, filter)
    return InstanceActorList(actorType, filter)
end
