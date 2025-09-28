---@diagnostic disable: missing-return
---@class InstanceActorCache_Lists
---@field All InstanceActorCache_Lists_ActorCache
---@field MetaPath table<string, InstanceActorCache_Lists_ActorCache>
---@field Monsters_All InstanceActorCache_Lists_ActorCache
---@field Monsters_Bosses InstanceActorCache_Lists_ActorCache
---@field Monsters_Normal InstanceActorCache_Lists_ActorCache
---@field Monsters_Magic InstanceActorCache_Lists_ActorCache
---@field Monsters_MinMagic InstanceActorCache_Lists_ActorCache
---@field Monsters_Rare InstanceActorCache_Lists_ActorCache
---@field Monsters_MinRare InstanceActorCache_Lists_ActorCache
---@field Monsters_Unique InstanceActorCache_Lists_ActorCache
---@field Monsters_DeliriumSpawner InstanceActorCache_Lists_ActorCache
---@field Monsters_DeliriumMonsters InstanceActorCache_Lists_ActorCache
---@field Monsters_Harvest InstanceActorCache_Lists_ActorCache
---@field Monsters_LegionMonsters InstanceActorCache_Lists_ActorCache
---@field Monsters_Summoned InstanceActorCache_Lists_ActorCache
---@field Monsters_HarbingerMinions InstanceActorCache_Lists_ActorCache
---@field Monsters_Harbingers InstanceActorCache_Lists_ActorCache
---@field Monsters_Bestiary InstanceActorCache_Lists_ActorCache
---@field Players InstanceActorCache_Lists_ActorCache
---@field NPCs InstanceActorCache_Lists_ActorCache
---@field WorldItems InstanceActorCache_Lists_ActorCache
---@field Blockages InstanceActorCache_Lists_ActorCache
---@field Shrines InstanceActorCache_Lists_ActorCache
---@field Chests InstanceActorCache_Lists_ActorCache
---@field Portals InstanceActorCache_Lists_ActorCache
---@field BlightTowers InstanceActorCache_Lists_ActorCache
---@field Waypoints InstanceActorCache_Lists_ActorCache
---@field AreaTransitions InstanceActorCache_Lists_ActorCache
---@field RecipeUnlocks InstanceActorCache_Lists_ActorCache
---@field DeliriumMirrors InstanceActorCache_Lists_ActorCache
---@field BlightPumps InstanceActorCache_Lists_ActorCache
---@field EssenceMonoliths InstanceActorCache_Lists_ActorCache
---@field LegionMonoliths InstanceActorCache_Lists_ActorCache
---@field BreachPortals InstanceActorCache_Lists_ActorCache
---@field BreachChests InstanceActorCache_Lists_ActorCache
---@field ExpeditionChests InstanceActorCache_Lists_ActorCache
---@field ExpeditionDetonator InstanceActorCache_Lists_ActorCache
---@field LegionChests InstanceActorCache_Lists_ActorCache
---@field TribalChests InstanceActorCache_Lists_ActorCache
---@field HeistChests InstanceActorCache_Lists_ActorCache
---@field BlightChests InstanceActorCache_Lists_ActorCache
---@field SentinelChest InstanceActorCache_Lists_ActorCache
---@field LeversAndSwitches InstanceActorCache_Lists_ActorCache
---@field DelveMineralChests InstanceActorCache_Lists_ActorCache
---@field MapDevices InstanceActorCache_Lists_ActorCache
---@field SimulacrumNPCs InstanceActorCache_Lists_ActorCache
---@field HarvestIrrigators InstanceActorCache_Lists_ActorCache
---@field HarvestExtractors InstanceActorCache_Lists_ActorCache
---@field NecropolisCorpseMarkers InstanceActorCache_Lists_ActorCache
---@field SettlersNodes InstanceActorCache_Lists_ActorCache
InstanceActorCache_Lists = {}

---@alias InstanceActorCache_Lists_ActorCache table<number, ActorWrapper>

---@return number
function InstanceActorCache_Lists:getClosestMobDistance()
end

---@param actorId number
---@return ActorWrapper?
function InstanceActorCache_Lists:getActorWrapperByActorId(actorId)
end

---@param metaPath string
---@return InstanceActorCache_Lists_ActorCache, ActorWrapper?
function InstanceActorCache_Lists:getActorWrappersByMetaPath(metaPath)
end

---@param metaPath string
---@return ActorWrapper?
function InstanceActorCache_Lists:getClosestAliveMonsterWrapperByMetaPathSubString(metaPath)
end

---@param metaPath string
---@return ActorWrapper?
function InstanceActorCache_Lists:getClosestAliveActorWrapperByMetaPathSubString(metaPath)
end

---@param metaPaths table<string>
---@return ActorWrapper?
function InstanceActorCache_Lists:getClosestAliveActorWrapperByMetaPathSubStrings(metaPaths)
end

---@param actorType EActorType
---@return ActorWrapper?
function InstanceActorCache_Lists:getClosestActorWrapperByActorType(actorType)
end

---@param mobsToConsiderAmount number
---@param maxRangeCells number
---@param maxLOSDistanceFromTarget number
---@param allowBarrels boolean
---@return table<number, ActorWrapper>
function InstanceActorCache_Lists:getPotentialCombatTargets(mobsToConsiderAmount, maxRangeCells, maxLOSDistanceFromTarget, allowBarrels)
end

function InstanceActorCache_Lists:recalculateBlightTowerTags()
end
