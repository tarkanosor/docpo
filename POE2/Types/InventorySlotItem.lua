---@diagnostic disable: missing-return
---@class InventorySlotItem : Object
InventorySlotItem = {}

---@return boolean
function InventorySlotItem:isNull()
end

---@return boolean
function InventorySlotItem:isValid()
end

---@return Actor
function InventorySlotItem:getItem()
end

---@return number
function InventorySlotItem:getId()
end

---@return number
function InventorySlotItem:getPosX()
end

---@return number
function InventorySlotItem:getPosY()
end

---@return number
function InventorySlotItem:getStashTabAffinity()
end

---@return table<number, number>
function InventorySlotItem:getStashTabAffinityContainers()
end
