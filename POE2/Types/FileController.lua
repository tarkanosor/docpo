---@diagnostic disable: missing-return
---@class FileController
FileController = {}

---@return table<string, LuaInt64>
function FileController:getAllFiles()
end

-- TODO: Check params
---@param name string
---@return LuaInt64
function FileController:getFileByName(name)
end

---@return number
function FileController:getFileCount()
end

function FileController:recacheAllFiles()
end
