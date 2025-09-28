---@diagnostic disable: missing-return
---@class WordsFile : Object
WordsFile = {}

---@return table<number, Word>
function WordsFile:getWords()
end

---@param address LuaInt64
---@return Word?
function WordsFile:getWordByAdr(address)
end

---@param index number
---@return Word?
function WordsFile:getWordByIndex(index)
end
