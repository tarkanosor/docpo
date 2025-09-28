---@diagnostic disable: missing-return
Infinity = {}

--- Infinity PoE namespace
---@class Infinity.PoE2
Infinity.PoE2 = {}

---@return boolean
function Infinity.PoE2.isForeground()
end

function Infinity.PoE2.exitGame()
end

---@return WorldActor[]
function Infinity.PoE2.getActors()
end

---@return WorldActor[]
function Infinity.PoE2.getInverseSortedActors()
end

---Presorted list by distance of potential combat targets, max 50
---@return WorldActor[]
function Infinity.PoE2.getPotentialCombatTargets()
end

---Presorted list by distance of usable corpses, max 10
---@return WorldActor[]
function Infinity.PoE2.getUseableCorpses()
end

---@param actorId integer
---@return WorldActor?
function Infinity.PoE2.getActorByActorId(actorId)
end

---@param metaPath string
---@return WorldActor[]
function Infinity.PoE2.getActorsByMetaPath(metaPath)
end

---@param animatedMetaPath string
---@return WorldActor[]
function Infinity.PoE2.getActorsByAnimatedMetaPath(animatedMetaPath)
end

---@param actorType integer EActorType
---@return WorldActor[]
function Infinity.PoE2.getActorsByType(actorType)
end

---@return WorldActor
function Infinity.PoE2.getLocalPlayer()
end

---@return FileController
function Infinity.PoE2.getFileController()
end

---@return GameStateController
function Infinity.PoE2.getGameStateController()
end

---@return ConfigManager
function Infinity.PoE2.getConfigManager()
end

---@param flaskIndex integer
function Infinity.PoE2.UseFlask(flaskIndex)
end

---@return POE2Navigator
function Infinity.PoE2.getNavigator()
end

---@return GlobalUIManager
function Infinity.PoE2.getGlobalUIManager()
end

---@return boolean
function Infinity.PoE2.isGamePaused()
end

---@return integer
function Infinity.PoE2.getInstanceId()
end

---uses game's hashing function
---@param text string
---@return integer
function Infinity.PoE2.hashString(text)
end

---uses std::hash
---@param text string
---@return integer
function Infinity.PoE2._hashString(text)
end

function Infinity.PoE2.QuickDisconnect()
end

---@param openInstanceManager boolean
---@param worldAreaId integer
---@param waypointActorId integer
---@param flag integer?
function Infinity.PoE2.TeleportToWaypoint(waypointActorId, worldAreaId, openInstanceManager, flag)
end

---@param instanceId integer
function Infinity.PoE2.SelectInstance(instanceId)
end

---@param waypointActorId integer
function Infinity.PoE2.TeleportToHideout(waypointActorId)
end

function Infinity.PoE2.ReviveAtCheckpoint()
end

function Infinity.PoE2.OpenTownPortal()
end

function Infinity.PoE2.ConfirmSendChatMessage()
end

function Infinity.PoE2.Logout()
end

function Infinity.PoE2.GoToCharacterSelect()
end

---@return boolean
function Infinity.PoE2.IsAutoLoginIncludingCharacter()
end

function Infinity.PoE2.PauseGame()
end

function Infinity.PoE2.UnpauseGame()
end

---@return table<string, string>
function Infinity.PoE2.getDDSToItemNameMap()
end

---@param tutorialId integer
function Infinity.PoE2.CompleteTutorial(tutorialId)
end

---@param query string
function Infinity.PoE2.SetNextMarketSearchQueryOverride(query)
end

---@return string
function Infinity.PoE2.GetLastMarketSearchQuery()
end
