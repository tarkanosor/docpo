---@diagnostic disable: missing-return
---@class AtlasPrimordialAltarChoicesFile : Object
AtlasPrimordialAltarChoicesFile = {}

---@return table<number, AtlasPrimordialAltarChoice>
function AtlasPrimordialAltarChoicesFile:getAtlasPrimordialAltarChoices()
end

---@param address LuaInt64
---@return AtlasPrimordialAltarChoice?
function AtlasPrimordialAltarChoicesFile:getAtlasPrimordialAltarChoiceByAdr(address)
end

---@param index number
---@return AtlasPrimordialAltarChoice?
function AtlasPrimordialAltarChoicesFile:getAtlasPrimordialAltarChoiceByIndex(index)
end
