local Class = require("CoreLib.Class")
local Atlas = require("PoE2Lib.Atlas.Atlas")

--- The default chunk size is the range of towers.
local CHUNK_SIZE = Atlas.TOWER_RANGE

--- Returns the x and y coordinates of the chunk that contains the given location.
---@param location Vector2
---@return integer x, integer y
local function ChunkXY(location)
    return math.floor(location.X / CHUNK_SIZE), math.floor(location.Y / CHUNK_SIZE)
end

--- Packs the x and y coordinates of a chunk into a single integer.
---@param x integer
---@param y integer
---@return integer
local function ChunkId(x, y)
    return bit.band(x, 0xFFFF) * 0x10000 + bit.band(y, 0xFFFF)
end

--- Returns the chunk id of the chunk that contains the given location.
---@param location Vector2
---@return integer
local function LocationChunkId(location)
    local x, y = ChunkXY(location)
    return ChunkId(x, y)
end

--- This is a datastructure that contains all the nodes in the Atlas, grouped
--- into chunks for faster access.
---
--- This contains references to IGUIAtlasNode and is not safe to store across
--- frames.
---
---@class PoE2Lib.Atlas.ChunkMap : Class
---@overload fun():PoE2Lib.Atlas.ChunkMap
---@diagnostic disable-next-line: assign-type-mismatch
local ChunkMap = Class()

---@private
function ChunkMap:init()
    --- The nodes in the Atlas.
    ---@type IGUIAtlasNode[]
    self.nodes = Atlas.GetAtlasPanel():getAtlasNodes()

    --- The internal chunk map. Keyed by
    ---@private
    ---@type table<integer, IGUIAtlasNode[]>
    self.map = {}

    for _, node in pairs(self.nodes) do
        local chunkId = LocationChunkId(node:getLocation())
        if self.map[chunkId] == nil then
            self.map[chunkId] = {}
        end
        table.insert(self.map[chunkId], node)
    end
end

--- Returns the nodes that are in range of the given location.
---@param location Vector2|IGUIAtlasNode
---@param range number
---@return IGUIAtlasNode[]
function ChunkMap:getNodesInRange(location, range)
    if location.getLocation ~= nil then
        ---@cast location IGUIAtlasNode
        location = location:getLocation()
        ---@cast location Vector2
    end

    local cx, cy = ChunkXY(location)
    local delta = math.floor(range / CHUNK_SIZE)
    local nodes = {}
    for x = cx - delta, cx + delta do
        for y = cy - delta, cy + delta do
            local chunkId = ChunkId(x, y)
            if self.map[chunkId] ~= nil then
                for _, node in ipairs(self.map[chunkId]) do
                    if node:getLocation():getDistance(location) <= range then
                        table.insert(nodes, node)
                    end
                end
            end
        end
    end

    return nodes
end

return ChunkMap
