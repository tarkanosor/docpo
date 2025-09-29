local Class = require("CoreLib.Class")
local Atlas = require("PoE2Lib.Atlas.Atlas")

---@param node IGUIAtlasNode
---@return integer
local function MapId(node)
    local location = node:getLocation()
    return bit.band(location.X, 0xFFFF) * 0x10000 + bit.band(location.Y, 0xFFFF)
end

---@class PoE2Lib.Atlas.MapIslands : Class
---@overload fun():PoE2Lib.Atlas.MapIslands
---@diagnostic disable-next-line: assign-type-mismatch
local MapIslands = Class()

---@class PoE2Lib.Atlas.MapIslands.Island
---@field locations Vector2[]
---@field reachable boolean

function MapIslands:init()
    ---@type PoE2Lib.Atlas.MapIslands.Island[]
    self.islands = {}

    ---@type table<integer, PoE2Lib.Atlas.MapIslands.Island>
    self.map = {}

    self:build()
end

---@private
function MapIslands:build()
    for _, node in pairs(Atlas.GetAtlasPanel():getAtlasNodes()) do
        if self.map[MapId(node)] == nil then
            table.insert(self.islands, self:generate(node))
        end
    end
end

---@private
---@param start IGUIAtlasNode
---@return PoE2Lib.Atlas.MapIslands.Island
function MapIslands:generate(start)
    ---@type PoE2Lib.Atlas.MapIslands.Island
    local island = { locations = {}, reachable = false }

    local visited, stack = { [MapId(start)] = true }, { start }
    while true do
        ---@type IGUIAtlasNode
        local node = table.remove(stack)
        if node == nil then
            break
        end

        self.map[MapId(node)] = island

        table.insert(island.locations, node:getLocation())
        if node:isTraversable() then
            island.reachable = true
        end

        for _, connection in pairs(node:getConnections()) do
            local cid = MapId(connection)
            if not visited[cid] then
                visited[cid] = true
                table.insert(stack, connection)
            end
        end
    end

    return island
end

---@param node IGUIAtlasNode
---@return PoE2Lib.Atlas.MapIslands.Island?
function MapIslands:getIsland(node)
    return self.map[MapId(node)]
end

---@param node IGUIAtlasNode
---@return boolean
function MapIslands:isReachable(node)
    local island = self:getIsland(node)
    if island == nil then
        return false
    end
    return island.reachable
end

return MapIslands
