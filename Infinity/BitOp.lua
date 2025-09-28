---@diagnostic disable: missing-return
--- Bitwise operatinos for signed 32-bit integers.
---@class BitOp
---@see http://bitop.luajit.org/index.html
bit = {}

--- Normalizes a number to the numeric range for bit operations and returns it.
--- This function is usually not needed since all bit operations already normalize
--- all of their input arguments. Check the operational semantics for details.
---@param x number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.tobit(x)
end

--- Converts its first argument to a hex string. The number of hex digits is
--- given by the absolute value of the optional second argument. Positive
--- numbers between 1 and 8 generate lowercase hex digits. Negative numbers
--- generate uppercase hex digits. Only the least-significant 4*|n| bits are
--- used. The default is to generate 8 lowercase hex digits.
---@param x number
---@param n? number
---@return string
---@see http://bitop.luajit.org/api.html
function bit.tohex(x, n)
end

--- Returns the bitwise **not** of its argument.
---@param x number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.bnot(x)
end

--- Returns the bitwise **or** of all of its arguments. Note that more than two
--- arguments are allowed.
---@vararg number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.bor(...)
end

--- Returns the bitwise **and** of all of its arguments. Note that more than two
--- arguments are allowed.
---@vararg number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.band(...)
end

--- Returns the bitwise **xor** of all of its arguments. Note that more than two
--- arguments are allowed.
---@vararg number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.bxor(...)
end

--- Returns the bitwise **xor** of all of its arguments. Note that more than two
--- arguments are allowed.
---@vararg number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.bxor(...)
end

--- Returns the bitwise **logical left-shift** of its first argument by the
--- number of bits given by the second argument.
---
--- Logical shifts treat the first argument as an unsigned number and shift in
--- 0-bits. Arithmetic right-shift treats the most-significant bit as a sign bit
--- and replicates it.
--- Only the lower 5 bits of the shift count are used (reduces to the range
--- [0..31]).
---@param x number
---@param n number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.lshift(x, n)
end

--- Returns the bitwise **logical right-shift** of its first argument by the
--- number of bits given by the second argument.
---
--- Logical shifts treat the first argument as an unsigned number and shift in
--- 0-bits. Arithmetic right-shift treats the most-significant bit as a sign bit
--- and replicates it.
--- Only the lower 5 bits of the shift count are used (reduces to the range
--- [0..31]).
---@param x number
---@param n number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.rshift(x, n)
end

--- Returns the bitwise **arithmetic right-shift** of its first argument by the
--- number of bits given by the second argument.
---
--- Logical shifts treat the first argument as an unsigned number and shift in
--- 0-bits. Arithmetic right-shift treats the most-significant bit as a sign bit
--- and replicates it.
--- Only the lower 5 bits of the shift count are used (reduces to the range
--- [0..31]).
---@param x number
---@param n number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.arshift(x, n)
end

--- Returns the bitwise **left rotation** of its first argument by the number of
--- bits given by the second argument. Bits shifted out on one side are shifted
--- back in on the other side.
--- Only the lower 5 bits of the rotate count are used (reduces to the range
--- [0..31]).
---@param x number
---@param n number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.rol(x, n)
end

--- Returns the bitwise **right rotation** of its first argument by the number
--- of bits given by the second argument. Bits shifted out on one side are
--- shifted back in on the other side.
--- Only the lower 5 bits of the rotate count are used (reduces to the range
--- [0..31]).
---@param x number
---@param n number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.ror(x, n)
end

--- Swaps the bytes of its argument and returns it. This can be used to convert
--- little-endian 32 bit numbers to big-endian 32 bit numbers or vice versa.
---@param x number
---@return number
---@see http://bitop.luajit.org/api.html
function bit.swap(x)
end
