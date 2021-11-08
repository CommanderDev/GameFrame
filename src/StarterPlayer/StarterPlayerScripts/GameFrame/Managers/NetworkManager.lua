local GameFrame = require(game.ReplicatedStorage.GameFrame)

local NetworkManager = GameFrame.createManager {Name = "NetworkManager"}

function NetworkManager:init()
    self.FireRemote("TestEvent")
end

return NetworkManager