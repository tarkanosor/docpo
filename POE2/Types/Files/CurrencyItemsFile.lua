---@diagnostic disable: missing-return
---@class CurrencyItemsFile : Object
CurrencyItemsFile = {}

---@return table<number, CurrencyItem>
function CurrencyItemsFile:getCurrencyItems()
end

---@param address LuaInt64
---@return CurrencyItem?
function CurrencyItemsFile:getCurrencyItemByAdr(address)
end

---@param index number
---@return CurrencyItem?
function CurrencyItemsFile:getCurrencyItemByIndex(index)
end
