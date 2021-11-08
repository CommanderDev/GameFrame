local GameFrame = require(game.ReplicatedStorage.GameFrame)
local Network = GameFrame.loadLibrary("Network")

local NetworkManager = GameFrame.createManager {Name = "NetworkManager"}

function NetworkManager:init()
    self.FireRemote("TestEvent")
end

return NetworkManager