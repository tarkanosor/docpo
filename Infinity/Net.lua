---@diagnostic disable: missing-return
---@class Infinity.Net
Infinity.Net = {}

---@param buffer ByteBuffer
function Infinity.Net.Send(buffer)
end

---@param buffer ByteBuffer
function Infinity.Net.Receive(buffer)
end

---@return number
function Infinity.Net.getCountQueueIn()
end

---@return number
function Infinity.Net.getCountQueueOut()
end

---@param inventoryId number
---@param itemId number
---@param clickPosX number(0-255)
---@param clickPosY number(0-255)
---@param onlyOne boolean
function Infinity.Net.sendCombineItemPacket(inventoryId, itemId, clickPosX, clickPosY, onlyOne)
end

---@param inventoryId number
---@param column number
---@param row number
---@param clickPosX number(0-255)
---@param clickPosY number(0-255)
function Infinity.Net.sendPlaceItemPacket(inventoryId, column, row, clickPosX, clickPosY)
end

-- ---@return TCPSocketManager
-- ---@deprecated Doesn't seem to exist
-- function Infinity.Net.getTCPSocketManager()
-- end

-- ---@class TCPSocketManager
-- ---@deprecated Doesn't seem to exist
-- TCPSocketManager = {}

-- ---@param name string
-- ---@return SocketConnection
-- ---@diagnostic disable-next-line: deprecated
-- function TCPSocketManager:getSocketConnection(name)
-- end

-- ---@param name string
-- ---@param host string
-- ---@param port number
-- ---@param unknown boolean
-- ---@return SocketConnection
-- ---@diagnostic disable-next-line: deprecated
-- function TCPSocketManager:newConnection(name, host, port, unknown)
-- end

-- ---@param name string
-- ---@diagnostic disable-next-line: deprecated
-- function TCPSocketManager:closeConnection(name)
-- end

-- ---@class SocketConnection
-- ---@deprecated Doesn't seem to exist
-- SocketConnection = {}

-- ---@param buffer ByteBuffer
-- ---@diagnostic disable-next-line: deprecated
-- function SocketConnection:sendData(buffer)
-- end
