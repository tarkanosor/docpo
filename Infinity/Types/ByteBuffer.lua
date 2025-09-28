---@diagnostic disable: missing-return
---@param size? number
---@return ByteBuffer
function ByteBuffer(size)
end

---@class ByteBuffer
---@field size number
ByteBuffer = {}

---@param file string
function ByteBuffer:fromFile(file)
end

---@return number pos
function ByteBuffer:getReadPos()
end

---@param pos number
function ByteBuffer:setReadPos(pos)
end

---@param length number
function ByteBuffer:skip(length)
end

---@return number pos
function ByteBuffer:getWritePos()
end

---@param pos number
function ByteBuffer:setWritePos(pos)
end

---@return ByteBuffer
function ByteBuffer:clone()
end

---@param size number
function ByteBuffer:putEmptyBytes(size)
end

---@return number[]
function ByteBuffer:getBuffer()
end

-- Get

---@return number
function ByteBuffer:get()
end

---@return number
function ByteBuffer:getInt()
end

---@return number
function ByteBuffer:getRInt()
end

---@return number
function ByteBuffer:getUInt()
end

---@return number
function ByteBuffer:getRUInt()
end

---@return number
function ByteBuffer:getShort()
end

---@return number
function ByteBuffer:getRShort()
end

---@return number
function ByteBuffer:getUShort()
end

---@return number
function ByteBuffer:getRUShort()
end

---@return number
function ByteBuffer:getLong()
end

---@return number
function ByteBuffer:getRLong()
end

---@return number
function ByteBuffer:getFloat()
end

---@return number
function ByteBuffer:getRFloat()
end

---@return number
function ByteBuffer:getDouble()
end

---@return number
function ByteBuffer:getRDouble()
end

---@return string
function ByteBuffer:getChar()
end

---@param length number
---@return string
function ByteBuffer:getString(length)
end

--- Get a null terminated string.
---@return string
function ByteBuffer:getWString()
end

-- _Get

---@param pos number
---@return number
function ByteBuffer:_get(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getInt(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRInt(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getUInt(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRUInt(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getShort(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRShort(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getUShort(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRUShort(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getLong(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRLong(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getFloat(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRFloat(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getDouble(pos)
end

---@param pos number
---@return number
function ByteBuffer:_getRDouble(pos)
end

---@param pos number
---@return string
function ByteBuffer:_getChar(pos)
end

---@param length number
---@param pos number
---@return string
function ByteBuffer:_getString(length, pos)
end

--- Get a null terminated string.
---@param pos number
---@return string
function ByteBuffer:_getWString(pos)
end

-- Put

---@param byte number
function ByteBuffer:put(byte)
end

---@param bytes number[]
function ByteBuffer:putBytes(bytes)
end

---@param int number
function ByteBuffer:putInt(int)
end

---@param int number
function ByteBuffer:putRInt(int)
end

---@param uint number
function ByteBuffer:putUInt(uint)
end

---@param uint number
function ByteBuffer:putRUInt(uint)
end

---@param short number
function ByteBuffer:putShort(short)
end

---@param short number
function ByteBuffer:putRShort(short)
end

---@param ushort number
function ByteBuffer:putUShort(ushort)
end

---@param ushort number
function ByteBuffer:putRUShort(ushort)
end

---@param long number
function ByteBuffer:putLong(long)
end

---@param long number
function ByteBuffer:putRLong(long)
end

---@param int number
function ByteBuffer:putIntAsLong(int)
end

---@param float number
function ByteBuffer:putFloat(float)
end

---@param float number
function ByteBuffer:putRFloat(float)
end

---@param double number
function ByteBuffer:putDouble(double)
end

---@param double number
function ByteBuffer:putRDouble(double)
end

---@param char string
function ByteBuffer:putChar(char)
end

---@param s string
---@param length number
function ByteBuffer:putString(s, length)
end

---@param s string
---@param length number
function ByteBuffer:putWString(s, length)
end

-- _Put

---@param byte number
---@param pos number
function ByteBuffer:_put(byte, pos)
end

---@param bytes number[]
---@param pos number
function ByteBuffer:_putBytes(bytes, pos)
end

---@param int number
---@param pos number
function ByteBuffer:_putInt(int, pos)
end

---@param int number
---@param pos number
function ByteBuffer:_putRInt(int, pos)
end

---@param uint number
---@param pos number
function ByteBuffer:_putUInt(uint, pos)
end

---@param uint number
---@param pos number
function ByteBuffer:_putRUInt(uint, pos)
end

---@param short number
---@param pos number
function ByteBuffer:_putShort(short, pos)
end

---@param short number
---@param pos number
function ByteBuffer:_putRShort(short, pos)
end

---@param ushort number
---@param pos number
function ByteBuffer:_putUShort(ushort, pos)
end

---@param ushort number
---@param pos number
function ByteBuffer:_putRUShort(ushort, pos)
end

---@param int number
---@param pos number
function ByteBuffer:_putIntAsLong(int, pos)
end

---@param long number
---@param pos number
function ByteBuffer:_putLong(long, pos)
end

---@param long number
---@param pos number
function ByteBuffer:_putRLong(long, pos)
end

---@param float number
---@param pos number
function ByteBuffer:_putFloat(float, pos)
end

---@param float number
---@param pos number
function ByteBuffer:_putRFloat(float, pos)
end

---@param double number
---@param pos number
function ByteBuffer:_putDouble(double, pos)
end

---@param double number
---@param pos number
function ByteBuffer:_putRDouble(double, pos)
end

---@param char string
---@param pos number
function ByteBuffer:_putChar(char, pos)
end

---@param s string
---@param length number
---@param pos number
function ByteBuffer:_putString(s, length, pos)
end

---@param s string
---@param length number
---@param pos number
function ByteBuffer:_putWString(s, length, pos)
end

-- TODO: Add signature
function ByteBuffer:PutWStringS(...)
end
-- TODO: Add signature
function ByteBuffer:ReadCustomSizedInt(...)
end
-- TODO: Add signature
function ByteBuffer:ReadCustomSizedUInt(...)
end
-- TODO: Add signature
function ByteBuffer:getFixedString(...)
end
-- TODO: Add signature
function ByteBuffer:getFixedWString(...)
end
-- TODO: Add signature
function ByteBuffer:putFixedString(...)
end
-- TODO: Add signature
function ByteBuffer:putFixedWString(...)
end
