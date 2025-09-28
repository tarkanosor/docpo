---@diagnostic disable: missing-return
---@class VillageJobType
VillageJobType = {}

---@return integer
function VillageJobType:getIndex()
end

---@return string
function VillageJobType:getName()
end

---@return Stat?
function VillageJobType:getStat1()
end

---@return number
function VillageJobType:getValue1()
end

---@return Stat?
function VillageJobType:getStat2()
end

---@return number

---@class VillageJobTypeWrapper
VillageJobTypeWrapper = {}

---@return VillageJobType
function VillageJobTypeWrapper:getVillageJobType()
end

---@return number
function VillageJobTypeWrapper:getRank()
end

---@class VillageJob
VillageJob = {}

---@return integer
function VillageJob:getIndex()
end

---@return VillageJobType
function VillageJob:getVillageJobType()
end

---@return Stat
function VillageJob:getStat()
end

---@return number
function VillageJob:getValue1()
end

---@return number
function VillageJob:getValue2()
end

---@return string
function VillageJob:getName()
end

---@class VillageHireWorkerData
VillageHireWorkerData = {}

---@return VillageJobTypeWrapper[]
function VillageHireWorkerData:getVillageJobTypeWrappers()
end

---@return number
function VillageHireWorkerData:getWage()
end

---@return number
function VillageHireWorkerData:getCost()
end

---@class VillageWorkerData
---@field Index integer
VillageWorkerData = {}

---@return VillageJobTypeWrapper[]
function VillageWorkerData:getVillageJobTypeWrappers()
end

---@return number
function VillageWorkerData:getWage()
end

---@return VillageJob
function VillageWorkerData:getVillageJob()
end

---@class VillageUpgradeCategory
VillageUpgradeCategory = {}

---@return integer
function VillageUpgradeCategory:getIndex()
end

---@return string
function VillageUpgradeCategory:getText()
end

---@class VillageResource
VillageResource = {}

---@return integer
function VillageResource:getIndex()
end

---@return string
function VillageResource:getName()
end

---@return integer
function VillageResource:getLevel()
end

---@class VillageUpgrade
VillageUpgrade = {}

---@return integer
function VillageUpgrade:getIndex()
end

---@return VillageUpgradeCategory
function VillageUpgrade:getCategory()
end

---@return integer
function VillageUpgrade:getLevel()
end

---@return string
function VillageUpgrade:getText()
end

---@return integer
function VillageUpgrade:getId()
end

---@return VillageResource[]
function VillageUpgrade:getRequiredResources()
end

---@return integer[]
function VillageUpgrade:getRequiredResourcesCounts()
end

---@return integer
function VillageUpgrade:getRequiredGold()
end

---@return Stat[]
function VillageUpgrade:getStats()
end

---@return integer[]
function VillageUpgrade:getStatValues()
end

---@class VillageNodeData
---@field ActorId integer
---@field Location Vector3
---@field Category VillageUpgradeCategory
---@field Stats table<Stat, integer>
---@field Level integer
---@field CurrentUpgrade VillageUpgrade?
---@field NextUpgrade VillageUpgrade?
---@field CanUpgrade boolean
---@field CurrentWorkers integer
---@field MaxWorkers integer
---@field UnlockedJobs VillageJob[]
---@field FreeJobSlots VillageJob[]
---@field FreeJobSlotsResourceBased VillageJob[]
---@field TakenJobSlots VillageJob[]
---@field AssignedWorkers VillageWorkerData[]
---@field TotalWagePerHour integer
VillageNodeData = {}

---@class ShippingData
ShippingData = {}

---@return integer
function ShippingData:getStatus()
end

---@return number
function ShippingData:getTimeCurrent()
end

---@return number
function ShippingData:getTimeTotal()
end

---@class VillageShippingPort
VillageShippingPort = {}

---@return integer
function VillageShippingPort:getIndex()
end

---@return string
function VillageShippingPort:getName()
end

---@class ShippingPortData
ShippingPortData = {}

---@return table<integer, integer>
function ShippingPortData:getFavouredResources()
end

---@return boolean
function ShippingPortData:isUnlocked()
end

---@return VillageShippingPort
function ShippingPortData:getVillageShippingPort()
end

---@class ShipStatus
ShipStatus = {}

---@return table<integer, integer>
function ShipStatus:getResources()
end

---@return VillageShippingPort
function ShipStatus:getVillageShippingPort()
end

---@class MappingData
MappingData = {}

---@return boolean
function MappingData:isRunningMaps()
end

---@return integer[]
function MappingData:getMapCompletions()
end

---@return integer
function MappingData:getCompletedMapsCount()
end

---@return boolean
function MappingData:isFinished()
end

---@return boolean
function MappingData:isSuspended()
end

---@class SettlersData : Object
SettlersData = {}

---@return VillageWorkerData[]
function SettlersData:getVillageWorkers()
end

---@return VillageWorkerData[]
function SettlersData:getUnassignedVillageWorkers()
end

---@return VillageWorkerData[]
function SettlersData:getAssignedVillageWorkers()
end

---@return VillageHireWorkerData[]
function SettlersData:getVillageHireWorkers()
end

---@return number
function SettlersData:getGold()
end

---@return number
function SettlersData:getTotalWagePerHour()
end

---@return string
function SettlersData:getTimeLeftAsText()
end

---@return integer[]
function SettlersData:getFarmPlotCropTypes()
end

---Return table indices are EVillageResource_*
---@return number[]
function SettlersData:getResources()
end

---@param resourceIndex number EVillageResource_*
---@return number
function SettlersData:getResource(resourceIndex)
end

---@return boolean
function SettlersData:isInVillage()
end

---@return table<Stat, integer>
function SettlersData:getVillageStats()
end

---@return VillageNodeData[]
function SettlersData:getVillageNodes()
end

---@return ShippingData[]
function SettlersData:getShippingData()
end

---@return ShippingPortData[]
function SettlersData:getShippingPortData()
end

---@return integer[]
function SettlersData:getFinalShipStatus()
end

---@return ShipStatus[]
function SettlersData:getShipStatus()
end

---@return MappingData[]
function SettlersData:getMappingData()
end
