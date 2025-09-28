---@diagnostic disable: missing-return
---@class QuestManager : Object
QuestManager = {}

---@return Quest
function QuestManager:getLastAcceptedQuest()
end

---@param id string
---@return QuestWrapper
function QuestManager:getQuestWrapperByQuestId(id)
end

---@return table<number, QuestWrapper>
function QuestManager:getQuestWrappers()
end
