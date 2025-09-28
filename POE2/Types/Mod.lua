---@diagnostic disable: missing-return
---@class Mod : Object
---@field IsPrefix boolean
---@field IsSuffix boolean
---@field IsItemCraftMod boolean
---@field IsChestMod boolean
---@field IsAnimalCharmMod boolean
Mod = {}

---@return string
function Mod:getName()
end

---@return ModType
function Mod:getModType()
end

---@return integer
function Mod:getRequiredLevel()
end

---@return string
function Mod:getAffixText()
end

---@return string
function Mod:getRealName()
end

---@return string[]
function Mod:getModFamilies()
end

---@return number
function Mod:getValueMin()
end

---@return number
function Mod:getValueMax()
end

--- Returns an array of values. The index of the value corresponds to the
--- index of the corresponding Stat in mod:getStats().
---@return number[]
function Mod:getValuesMin()
end

--- Returns an array of values. The index of the value corresponds to the
--- index of the corresponding Stat in mod:getStats().
---@return number[]
function Mod:getValuesMax()
end

---@return number EModDomain
function Mod:getDomain()
end

---@return number EModGenerationType
function Mod:getGenerationType()
end

---@return Stat[]
function Mod:getStats()
end

---@return Tag[]
function Mod:getTags()
end

--- Returns an array of weights. The index of the weight corresponds to the
--- index of the tag in `Mod:getTags()`.
---@return number[]
function Mod:getWeights()
end

--- Returns the tags added to the item by this mod.
---@return Tag[]
function Mod:getAddedTags()
end

---@return GrantedEffectsPerLevel[]
function Mod:getGrantedEffectsPerLevel()
end

---@return boolean
function Mod:isEssenceOnly()
end

---@return table<number, ItemClassData>
function Mod:getItemClasses()
end

---@return Tag[]
function Mod:getImplicitTags()
end

---@return string
function Mod:getDescription()
end