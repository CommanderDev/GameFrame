local RunService = game:GetService("RunService")

local GameFrame: table = require(game.ReplicatedStorage.GameFrame)

local Store: table = if RunService:IsServer() then GameFrame.loadLibrary("ServerStore") else GameFrame.loadLibrary("ClientStore")

return function(): string
    local Votes: table = Store:getState().Voting
    local winningMaps: table = table.create(#Votes)
    for mapName: string, numberOfVotes: number in next, Votes do 
        if #winningMaps == 0 then 
            winningMaps[1] = mapName 
            continue 
        end
        if numberOfVotes > Votes[winningMaps[1]] then 
            table.clear(winningMaps)
            winningMaps[1] = mapName
        elseif numberOfVotes == Votes[winningMaps[1]] then 
            winningMaps[#winningMaps + 1] = mapName
        end
    end
    return winningMaps[math.random(1, #winningMaps)]
end