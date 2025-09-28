---@diagnostic disable: missing-return
---@class Infinity.FileSystem
Infinity.FileSystem = {}

---@param glob string
---@return table<number, string>
function Infinity.FileSystem.GetFiles(glob)
end

---@param directory string
---@param isAbsolute? boolean
---@return table<number, string>
function Infinity.FileSystem.GetAllFiles(directory, isAbsolute)
end

---@param filePath string
---@param isAbsolute? boolean
---@return string
function Infinity.FileSystem.ReadFile(filePath, isAbsolute)
end

---@param filePath string
---@param content string
---@param isAbsolute? boolean
function Infinity.FileSystem.WriteFile(filePath, content, isAbsolute)
end

---@param filename string
---@param buffer ByteBuffer
---@param isAbsolute? boolean
function Infinity.FileSystem.WriteBinaryFile(filename, buffer, isAbsolute)
end

---@param filePath string
---@param isAbsolute? boolean
function Infinity.FileSystem.DeleteFile(filePath, isAbsolute)
end
