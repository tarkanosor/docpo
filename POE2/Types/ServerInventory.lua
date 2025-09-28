---@diagnostic disable: missing-return
---@class ServerInventory : Object
---@field Id number
ServerInventory = {}

---@return boolean
function ServerInventory:isNull()
end

---@return number EInventorySlot
function ServerInventory:getInventorySlot()
end

---@return string
function ServerInventory:getInventorySlotS()
end

---@return number EInventoryType
function ServerInventory:getInventoryType()
end

---@return string
function ServerInventory:getInventoryTypeS()
end

---@return number
function ServerInventory:getColumns()
end

---@return number
function ServerInventory:getRows()
end

---@return number
function ServerInventory:getAccessCount()
end

---@param requestedSize Vector2
---@return boolean
function ServerInventory:hasFreeSlots(requestedSize)
end

---@param item Actor
---@return boolean
function ServerInventory:canFitItem(item)
end

---@param requestedSize Vector2
---@return Vector2 pos @ -1,-1 if no free slot found
function ServerInventory:getFreeSlotPos(requestedSize)
end

---@return number
function ServerInventory:getInventorySlotItemCount()
end

---@return table<number, InventorySlotItem>
function ServerInventory:getInventorySlotItems()
end

---@param itemCategory number EItemCategory
---@return table<number, InventorySlotItem>
function ServerInventory:getInventorySlotItemsByItemCategory(itemCategory)
end

---@param itemClass number EItemClass
---@return table<number, InventorySlotItem>
function ServerInventory:getInventorySlotItemsByItemClass(itemClass)
end

---@param pos Vector2
---@return InventorySlotItem?
function ServerInventory:getInventorySlotItemByPos(pos)
end

---@param itemId integer
---@return InventorySlotItem?
function ServerInventory:getInventorySlotItemById(itemId)
end

---@param name string
---@return InventorySlotItem?
function ServerInventory:getInventorySlotItemByName(name)
end

---@param hash number
---@return InventorySlotItem?
function ServerInventory:getInventorySlotItemByMetaHash(hash)
end
