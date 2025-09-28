---@diagnostic disable: missing-return
---@class ServerStashTab
---@field Id number
ServerStashTab = {}

---@return number
function ServerStashTab:getPlayerInventoryId()
end

---@return integer
function ServerStashTab:getId()
end

---@return string
function ServerStashTab:getName()
end

---@return number
function ServerStashTab:getVisibleIndex()
end

---@return number
function ServerStashTab:getTabType()
end

---@return string
function ServerStashTab:getTabTypeS()
end

---@return boolean
function ServerStashTab:getAffinitiesEnabled()
end

---@return number
function ServerStashTab:getAffinitiesBitMask()
end

---@param flag number
---@return boolean
function ServerStashTab:hasStashTabAffinity(flag)
end

---@return table<number, number>
function ServerStashTab:getStashTabAffinities()
end

---@return boolean
function ServerStashTab:isLoaded()
end

---@return boolean
function ServerStashTab:isRemoveOnly()
end

---@return integer
function ServerStashTab:getMemberPermissionFlag()
end

---@return integer
function ServerStashTab:getOfficerPermissionFlag()
end

---@return integer
function ServerStashTab:getLinkedParentId()
end

---@return integer
function ServerStashTab:getInventoryTabMapSeries()
end

---@return integer
function ServerStashTab:getInventoryTabFlags()
end

