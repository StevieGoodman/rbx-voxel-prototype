local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Block = require(ReplicatedStorage.Classes.Block)

export type Chunk = {
    ChunkPosition: Vector3,
    WorldPosition: Vector3,
    BlockData: {number},
    BlockParts: {Part},

    Load: (Chunk) -> (),
    Unload: (Chunk) -> (),
    BlockIndexToWorldPosition: (Chunk, blockIndex: number) -> Vector3,
    Destroy: (Chunk) -> ()
}

local Chunk = {}

Chunk.BlockSize = 16
Chunk.WorldSize = Chunk.BlockSize * Block.Size

function Chunk.new(chunkPosition: Vector3)
    local chunk = {
        ChunkPosition = chunkPosition,
        WorldPosition = Chunk.GetWorldPosition(chunkPosition),
        BlockData = table.create(math.pow(Chunk.BlockSize, 3), 0),
        BlockParts = {},
        _trove = Trove.new()
    }
    chunk._blockFolder = Instance.new("Folder")
    chunk._blockFolder.Name = `Chunk ({chunkPosition.X}, {chunkPosition.Y}, {chunkPosition.Z})`
    chunk._blockFolder.Parent = workspace
    chunk._trove:Add(chunk._blockFolder)

    setmetatable(chunk, {__index = Chunk})
    chunk:Load()
    return chunk
end

function Chunk.GetWorldPosition(chunkPosition: Vector3): Vector3
    return Vector3.new(
        math.round(chunkPosition.X) * Chunk.WorldSize,
        math.round(chunkPosition.Y) * Chunk.WorldSize,
        math.round(chunkPosition.Z) * Chunk.WorldSize
    )
end

function Chunk:CountBlocks()
    local count = 0
    for _, blockId in self.BlockData do
        if blockId == 0 then continue end
        count += 1
    end
    return count
end

function Chunk:BlockIndexToWorldPosition(blockIndex: number): Vector3
    local blockPositionOffset = Vector3.new(
        math.floor((blockIndex - 1) / math.pow(Chunk.BlockSize, 2)),
        math.floor((blockIndex - 1) / Chunk.BlockSize) % Chunk.BlockSize,
        (blockIndex - 1) % Chunk.BlockSize
    ) * Block.Size
    return self.WorldPosition + blockPositionOffset
end

function Chunk:Load()
    return Promise.try(function()
        self:Unload():await()
        for index, blockId in self.BlockData do
            if blockId == 0 then continue end
            local block = Block.new(
                self:BlockIndexToWorldPosition(index),
                blockId
            )
            block.Parent = self._blockFolder
            if index % math.pow(self.BlockSize, 2) == 0 then
                task.wait()
            end
        end
    end)
end

function Chunk:Unload()
    return Promise.try(function()
        for _, block in self.BlockParts do
            block:Destroy()
        end
    end)
end

function Chunk:Destroy()
    self._trove:Destroy()
end

return Chunk