---@diagnostic disable: missing-return
---@class PartyMember
---@field PartyStatus number
PartyMember = {}

---@return string
function PartyMember:getAccount()
end

---@return string
function PartyMember:getUnknown()
end

---@return string
function PartyMember:getCharacter()
end

---@return string
function PartyMember:getLeague()
end

---@return string
function PartyMember:getWorldAreaId()
end

---@return WorldArea
function PartyMember:getWorldArea()
end

---@return boolean
function PartyMember:isSameZone()
end

---@return boolean
function PartyMember:canTeleport()
end
