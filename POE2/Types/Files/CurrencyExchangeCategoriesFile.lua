---@diagnostic disable: missing-return
---@class CurrencyExchangeCategoriesFile : Object
CurrencyExchangeCategoriesFile = {}

---@return table<number, CurrencyExchangeCategory>
function CurrencyExchangeCategoriesFile:getCurrencyExchangeCategories()
end

---@param address LuaInt64
---@return CurrencyExchangeCategory?
function CurrencyExchangeCategoriesFile:getCurrencyExchangeCategoryByAdr(address)
end

---@param index number
---@return CurrencyExchangeCategory?
function CurrencyExchangeCategoriesFile:getCurrencyExchangeCategoryByIndex(index)
end
