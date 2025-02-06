local ReplicatedStorage = game:GetService("ReplicatedStorage")
local World = require(ReplicatedStorage.Classes.World)

return {
    Name        = "LoadChunk",
    Description = "Loads a specific world chunk.",
    Args        = {
        {
            Type = "vector3",
            Name = "Chunk Coordinates",
            Description = "The integer co-ordinates of the chunk to load.",
        },
    },
    ClientRun = function(_, position: Vector3)
        World:LoadChunk(position)
        return `Chunk ({position.X}, {position.Y}, {position.Z}) loaded.`
    end
}