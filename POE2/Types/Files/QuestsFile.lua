---@diagnostic disable: missing-return
---@class QuestsFile : Object
QuestsFile = {}

---@return table<unknown, Quest>
function QuestsFile:getQuests()
end

---@param address LuaInt64
---@return Quest?
function QuestsFile:getQuestByAdr(address)
end

---@param id string
---@return Quest?
function QuestsFile:getQuestByQuestId(id)
end
