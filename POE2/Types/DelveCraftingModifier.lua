---@diagnostic disable: missing-return
---@class DelveCraftingModifier : Object
DelveCraftingModifier = {}

---@return BaseItemTypeData
function DelveCraftingModifier:getBaseItemType()
end

---@return Mod[]
function DelveCraftingModifier:getAddedMods()
end

---@return Tag[]
function DelveCraftingModifier:getNegativeWeightTags()
end

---@return integer[]
function DelveCraftingModifier:getNegativeWeightValues()
end

---@return Mod[]
function DelveCraftingModifier:getForcedAddedMods()
end

-- ---@return DelveCraftingTag[]
-- function DelveCraftingModifier:getForbiddenDelveCraftingTags()
-- end

-- ---@return DelveCraftingTag[]
-- function DelveCraftingModifier:getAllowedDelveCraftingTags()
-- end

---@return boolean
function DelveCraftingModifier:canMirrorItem()
end

---@return integer
function DelveCraftingModifier:getCorruptedEssenceChance()
end

---@return boolean
function DelveCraftingModifier:canImproveQuality()
end

---@return boolean
function DelveCraftingModifier:hasLuckyRolls()
end

---@return Mod[]
function DelveCraftingModifier:getSellPriceMods()
end

---@return boolean
function DelveCraftingModifier:canRollWhiteSockets()
end

---@return Tag[]
function DelveCraftingModifier:getWeightTags()
end

---@return integer[]
function DelveCraftingModifier:getWeightValues()
end

-- ---@return DelveCraftingModifierDescription[]
-- function DelveCraftingModifier:getDelveCraftingModifierDescriptions()
-- end

-- ---@return DelveCraftingModifierDescription[]
-- function DelveCraftingModifier:getBlockedDelveCraftingModifierDescriptions()
-- end

