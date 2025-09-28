---@diagnostic disable: missing-return
---@class NPCShopsFile : Object
NPCShopsFile = {}

---@return table<number, NPCShop>
function NPCShopsFile:getNPCShops()
end

---@param address LuaInt64
---@return NPCShop?
function NPCShopsFile:getNPCShopByAdr(address)
end

---@param index number
---@return NPCShop?
function NPCShopsFile:getNPCShopByIndex(index)
end
