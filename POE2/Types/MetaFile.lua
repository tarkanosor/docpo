---@diagnostic disable: missing-return
---@class MetaFile : Object
MetaFile = {}

---@return string
function MetaFile:getName()
end

---@return boolean
function MetaFile:isActorMeta()
end

---@return string[]
function MetaFile:getTags()
end

---@return boolean
function MetaFile:hasTags()
end

---@return integer
function MetaFile:getLoadingState()
end

---@return ComponentLookup
function MetaFile:getComponentLookup()
end