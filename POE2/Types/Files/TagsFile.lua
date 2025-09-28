---@diagnostic disable: missing-return
---@class TagsFile : Object
TagsFile = {}

---@return table<number, Tag>
function TagsFile:getTags()
end

---@param address LuaInt64
---@return Tag?
function TagsFile:getTagByAdr(address)
end

---@param index number
---@return Tag?
function TagsFile:getTagByIndex(index)
end
