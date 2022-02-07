local GameFrame = require(game.ReplicatedStorage.GameFrame)

local ServerStore = GameFrame.loadLibrary("ServerStore")

local setPlayerRole = GameFrame.require("setPlayerRole")

return function(): () 
    local serverState = ServerStore:getState()
    local killerIndex = math.random(1, #serverState.Round.playersInMatch)
    for index: number, player: Player in next, serverState.Round.playersInMatch do 
        if index == killerIndex then 
            ServerStore:dispatch(setPlayerRole(player, "Killer"))
        else
            ServerStore:dispatch(setPlayerRole(player, "Survivor"))
        end
    end
end