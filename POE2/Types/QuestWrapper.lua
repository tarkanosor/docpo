---@diagnostic disable: missing-return
---@class QuestWrapper : Object
QuestWrapper = {}

---@return Quest
function QuestWrapper:getQuest()
end

---@return boolean
function QuestWrapper:isCompleted()
end

---@return boolean
function QuestWrapper:isAccepted()
end

---@return integer
function QuestWrapper:getQuestStateRaw()
end

---@return QuestState
function QuestWrapper:getQuestState()
end
