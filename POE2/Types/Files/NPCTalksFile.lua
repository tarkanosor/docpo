---@diagnostic disable: missing-return
---@class NPCTalksFile : Object
NPCTalksFile = {}

---@return table<number, NPCTalk>
function NPCTalksFile:getNPCTalks()
end

---@param metaPath string
---@return table<number, NPCTalk>
function NPCTalksFile:getNPCTalksByNPCMetaFilePath(metaPath)
end

---@param address LuaInt64
---@return NPCTalk?
function NPCTalksFile:getNPCTalkByAdr(address)
end

---@param index number
---@return NPCTalk?
function NPCTalksFile:getNPCTalkByIndex(index)
end

---@param metaPath string
---@return table<number, NPCTalk>
function NPCTalksFile:getNPCTalksByNPCMetaFilePath(metaPath)
end
