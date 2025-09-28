---@diagnostic disable: missing-return
---@class CurrencyExchangeFile : Object
CurrencyExchangeFile = {}

---@return table<number, CurrencyExchange>
function CurrencyExchangeFile:getCurrencyExchanges()
end

---@param address LuaInt64
---@return CurrencyExchange?
function CurrencyExchangeFile:getCurrencyExchangeByAdr(address)
end

---@param index number
---@return CurrencyExchange?
function CurrencyExchangeFile:getCurrencyExchangeByIndex(index)
end
