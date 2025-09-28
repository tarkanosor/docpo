---@diagnostic disable: missing-return
---@class ComponentLookup : Object
ComponentLookup = {}

---@return integer
function ComponentLookup:getComponentCount()
end

---@return boolean
function ComponentLookup:hasComponentList()
end

---@return integer[]
function ComponentLookup:getComponentTypes()
end

---@param type integer
---@return integer index
function ComponentLookup:getComponentIndex(type)
end