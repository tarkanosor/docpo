---@diagnostic disable: missing-return
---@class QuestStatesFile : Object
QuestStatesFile = {}

---@return table<unknown, QuestState>
function QuestStatesFile:getQuestStates()
end

---@param address LuaInt64
---@return QuestState?
function QuestStatesFile:getQuestStateByAdr(address)
end
