local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockTypes = require(ReplicatedStorage.Configuration.BlockTypes)

local Block = {}

Block.Size = 4
Block.DefaultBlockId = 1

function Block.new(unsnappedPosition: Vector3, blockId: number?)
    blockId = blockId or Block.DefaultBlockId
    local block = Instance.new("Part")
    block.Size = Vector3.new(Block.Size, Block.Size, Block.Size)
    block.Position = Block.GetSnappedPosition(unsnappedPosition)
    block.Anchored = true
    block.Material = Enum.Material.SmoothPlastic
    block.Parent = workspace
    for propertyName, propertyValue in BlockTypes[blockId] do
        block[propertyName] = propertyValue
    end
    return block
end

function Block.GetSnappedPosition(unsnappedPosition: Vector3): Vector3
    return Vector3.new(
        math.round(unsnappedPosition.X / Block.Size),
        math.round(unsnappedPosition.Y / Block.Size),
        math.round(unsnappedPosition.Z / Block.Size)
    ) * Block.Size
end

return Block