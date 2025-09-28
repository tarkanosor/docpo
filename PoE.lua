---@diagnostic disable: missing-return
--- Infinity PoE namespace
---@class Infinity.PoE
Infinity.PoE2 = {}


---@return table<integer, Actor>
function Infinity.PoE2.getActors()
end

---@return table<integer, Actor>
function Infinity.PoE2.getInverseSortedActors()
end

---@return table<integer, Actor>
---@param metaPath string
function Infinity.PoE2.getActorsByMetaPath(metaPath)
end

---@return table<integer, Actor>
---@param actorType integer
function Infinity.PoE2.getActorsByType(actorType)
end

---@return Actor
function Infinity.PoE2.getLocalPlayer()
end

---@return FileController
function Infinity.PoE2.getFileController()
end

---@return GameStateController
function Infinity.PoE2.getGameStateController()
end

---@param flaskIndex integer 
function Infinity.PoE2.UseFlask(flaskIndex)
end