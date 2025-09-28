---@diagnostic disable: missing-return
---@class POENavigator
POENavigator = {}


---@param endLocation Vector3
---@param radius number
---@return boolean
---@overload fun(self, endLocation: Vector2):boolean
function POENavigator:isLocationReachable(endLocation, radius)
end

function POENavigator:forceClearTempObstacles()
end

---@param startX number
---@param startY number
---@param maxRange number
---@return Vector2
function POENavigator:getClosestWalkableCellLocation(startX, startY, maxRange)
end

---@param cell Vector2
---@return number
function POENavigator:getRealDistanceToCellFromPlayer(cell)
end

---@param cell Vector2
---@return number
function POENavigator:getRealDistanceToCellFromPlayer_Quick(cell)
end

---@param pos Vector3
---@return number
function POENavigator:getRealDistanceToWorldPosFromPlayer(pos)
end

---@param startCell Vector2
---@param endCell Vector2
---@param costLimit? number
---@return number
function POENavigator:getRealDistanceBetweenTwoCells(startCell, endCell, costLimit)
end

---@param pos Vector3
---@return number
function POENavigator:getRealDistanceToWorldPosFromPlayer_Quick(pos)
end

---@param x number
---@param y number
---@param flyable boolean
---@return number
function POENavigator:getCellValue(x, y, flyable)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param oneDirection boolean
---@param blockRecalculation? boolean
function POENavigator:addOffmeshConnection(x1, y1, x2, y2, oneDirection, blockRecalculation)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param blockRecalculation? boolean
function POENavigator:removeOffmeshConnection(x1, y1, x2, y2, blockRecalculation)
end

function POENavigator:clearOffmeshConnections()
end

function POENavigator:forceRecalculateReachability()
end

function POENavigator:recalcNavMesh()
end

---@param range number
function POENavigator:setEvadeMonsterDistanceRange(range)
end

---@param state boolean
function POENavigator:setEvadeMonsters(state)
end

---@param state boolean
function POENavigator:setEvadeGroundEffects(state)
end

---@param state boolean
function POENavigator:setEvadeProjectiles(state)
end

---@param state boolean
function POENavigator:setEvadeSkills(state)
end

---@param location Vector3
---@return boolean
function POENavigator:isLocationInHighDanger(location)
end

---@param location Vector3
---@return boolean
function POENavigator:isLocationInDanger(location)
end

---@param location Vector3
---@return Vector3
function POENavigator:getClosestSafeLocation(location)
end

---@param location Vector3
---@param target Vector3
---@param range number? @default 100
---@param isTargetMonster boolean? @default false
---@return Vector3
function POENavigator:getClosestSafeLocationWithLineOfSightTo(location, target, range, isTargetMonster)
end
