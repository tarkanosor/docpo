---@diagnostic disable: missing-return
Infinity.Algorithm = {}
Infinity.Algorithm.TSP = {}

---@param points table<integer, Vector3>
---@param useNavMeshDistance boolean
function Infinity.Algorithm.TSP.solveAsync(points, useNavMeshDistance)
end

---@return string @state 
function Infinity.Algorithm.TSP.getAsyncState()
end

---@return table<Vector3>
function Infinity.Algorithm.TSP.getAsyncResult()
end

---@return table<integer>
function Infinity.Algorithm.TSP.getAsyncOutputMapping()
end

---@return boolean
function Infinity.Algorithm.TSP.isCurrentlySolving()
end