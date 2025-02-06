local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local BlockTypes = require(ReplicatedStorage.Configuration.BlockTypes)
local Chunk = require(ReplicatedStorage.Classes.Chunk)
local Block = require(ReplicatedStorage.Classes.Block)

local World = {
    Chunks = {},
}

World.NoiseStretch = 0.02
World.DirtDepth = 3 * Block.Size

function World.DefaultGenerationPredicate(blockCoordinates: Vector3): BlockTypes.BlockId
    local groundHeight = math.noise(
        blockCoordinates.X * World.NoiseStretch,
        0,
        blockCoordinates.Z * World.NoiseStretch
    )
    groundHeight += 1
    groundHeight /= 2
    groundHeight *= 10 * 2

    if blockCoordinates.Y > groundHeight then
        return 0
    elseif blockCoordinates.Y > groundHeight - Block.Size then
        return 3
    elseif blockCoordinates.Y < groundHeight - World.DirtDepth then
        return 1
    elseif blockCoordinates.Y < groundHeight then
        return 2
    end
end

function World:LoadChunk(chunkCoordinates: Vector3)
    local chunk = self.Chunks[chunkCoordinates] or Chunk.new(chunkCoordinates)
    self.Chunks[chunkCoordinates] = chunk
    return self:GenerateBlockData(chunk, World.DefaultGenerationPredicate)
    :andThen(function(blockData)
        chunk.BlockData = blockData
        return chunk:Load()
    end)
end

function World:UnloadChunk(chunkCoordinates: Vector3)
    local chunk = self.Chunks[chunkCoordinates]
    if chunk == nil then return end
    self.Chunks[chunkCoordinates] = nil
    return chunk:Unload()
end

function World:GenerateBlockData(chunk: Chunk.Chunk, predicate: (chunkGridPosition: Vector3) -> number)
    return Promise.try(function()
        local blockData = {}
        for blockIndex = 1, math.pow(Chunk.BlockSize, 3) do
            blockData[blockIndex] = predicate(chunk:BlockIndexToWorldPosition(blockIndex))
        end
        return blockData
    end)
end

local radius = 2
for x = -radius, radius-1 do
    for y = -radius, radius-1 do
        for z = -radius, radius-1 do
            World:LoadChunk(Vector3.new(x, y, z)):await()
        end
    end
end

local count = 0
for _, chunk in World.Chunks do
    count += chunk:CountBlocks()
end
print(`There are {count} blocks in the world!`)

return World