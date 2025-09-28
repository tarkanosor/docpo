---@diagnostic disable: missing-return
---@class MinimapIconsFile : Object
MinimapIconsFile = {}

---@return table<number, MinimapIcon>
function MinimapIconsFile:getMinimapIcons()
end

---@param address LuaInt64
---@return MinimapIcon?
function MinimapIconsFile:getMinimapIconByAdr(address)
end

---@param index number
---@return MinimapIcon?
function MinimapIconsFile:getMinimapIconByIndex(index)
end
