---@diagnostic disable: missing-return
---@class ItemExperiencePerLevelFile : Object
ItemExperiencePerLevelFile = {}

---@return table<number, ItemExperiencePerLevel>
function ItemExperiencePerLevelFile:getItemExperiencePerLevels()
end

---@param address LuaInt64
---@return ItemExperiencePerLevel?
function ItemExperiencePerLevelFile:getItemExperiencePerLevelByAdr(address)
end

---@param index number
---@return ItemExperiencePerLevel?
function ItemExperiencePerLevelFile:getItemExperiencePerLevelByIndex(index)
end
