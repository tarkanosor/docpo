---@diagnostic disable: missing-return
---@class Infinity.Pricing
Infinity.PoE.Pricing = {}

--- Returns the base price of an item based on recent trades
---@param name string
---@param variant string
---@param leagueName string
---@return number chaosValue
function Infinity.PoE.Pricing.getBasePrice(name, variant, leagueName)
end

---@param modName string
---@return string tftModName
function Infinity.PoE.Pricing.getTFTModNameFromGameModName(modName)
end

---@param tftModName string
---@return string modName
function Infinity.PoE.Pricing.getGameModNameFromTFTModName(tftModName)
end
