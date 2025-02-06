local ReplicatedStorage = game:GetService("ReplicatedStorage")
local World = require(ReplicatedStorage.Classes.World)

return {
    Name        = "UnloadChunk",
    Description = "Unloads a specific world chunk.",
    Args        = {
        {
            Type = "vector3",
            Name = "Chunk Coordinates",
            Description = "The integer co-ordinates of the chunk to unload.",
        },
    },
    ClientRun = function(_, position: Vector3)
        World:UnloadChunk(position)
        return `Chunk ({position.X}, {position.Y}, {position.Z}) unloaded.`
    end
}