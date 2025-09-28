---@diagnostic disable: missing-return
---@class BaseItemTypeData : Object
---@field MetaPath string
---@field MetaPathHash number
---@field Name string
---@field Width number
---@field Height number
---@field DropLevel number
---@field ItemClassData ItemClassData
---@field CraftableMods table<number, Mod>
BaseItemTypeData = {}

---@return table<number, Tag>
function BaseItemTypeData:getTags()
end

---@return table<number, string>
function BaseItemTypeData:getMetaTags()
end

---@return table<number, Mod>
function BaseItemTypeData:getCraftableMods()
end
