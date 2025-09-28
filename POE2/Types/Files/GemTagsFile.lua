---@diagnostic disable: missing-return
---@class GemTagsFile : Object
GemTagsFile = {}

-- ---@return table<number, GemTag>
-- function GemTagsFile:getGemTags()
-- end

---@param address LuaInt64
---@return GemTag?
function GemTagsFile:getGemTagByAdr(address)
end

---@param index number
---@return GemTag?
function GemTagsFile:getGemTagByIndex(index)
end
