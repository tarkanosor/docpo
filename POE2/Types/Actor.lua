---@diagnostic disable: missing-return
---@class Actor : Object
Actor = {}

---@return integer
function Actor:getActorId()
end

---@return integer
function Actor:getMillisecondsSinceLastSeen()
end

---@return boolean
function Actor:isAwakeObject()
end

---@return boolean
function Actor:isHostile()
end

---@return boolean
function Actor:isCurrentlyInActorList()
end

---@return MetaFile?
function Actor:getMetaFile()
end

---@return string
function Actor:getMetaPath()
end

---@return table<integer, LuaInt64>
function Actor:getComponentsRaw()
end


-------
-- Positioned
-------

---@return boolean
function Actor:isMinion()
end

---@return number
function Actor:getObjectSize()
end

---@return integer[]
function Actor:getStateFlag()
end

---@return boolean
function Actor:isFlipped()
end

---@return boolean
function Actor:isCollidable()
end

---@return boolean
function Actor:hasLockedOrientation()
end

---@return boolean
function Actor:hasLockedScale()
end

---@return Vector3
function Actor:getDestination()
end

---@return number
function Actor:getMomentum()
end

---@return boolean
function Actor:isMoving()
end 

---@return number
function Actor:getRotation()
end

---@return Vector3
function Actor:getLocation()
end

---@return Vector3
function Actor:getWorld()
end

---@return Vector3
function Actor:getGrid()
end

-------
-- ObjectMagicProperties
-------

---@return integer 
function Actor:getRarity()
end

-------
-- Life
-------

---@return boolean
function Actor:isAlive()
end

---@return number
function Actor:getHp()
end

---@return number
function Actor:getMaxHp()
end

---@return number
function Actor:getHpPercentage()
end

---@return number
function Actor:getMana()
end

---@return number
function Actor:getMaxMana()
end

---@return number
function Actor:getManaPercentage()
end

---@return number
function Actor:getEs()
end

---@return number
function Actor:getMaxEs()
end

---@return number
function Actor:getEsPercentage()
end

---@return number
function Actor:getSpirit()
end

---@return number
function Actor:getMaxSpirit()
end

---@return number
function Actor:getSpiritPercentage()
end