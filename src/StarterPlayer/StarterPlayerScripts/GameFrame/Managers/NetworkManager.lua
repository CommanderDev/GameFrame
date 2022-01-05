local GameFrame = require(game.ReplicatedStorage.GameFrame)

local NetworkManager = GameFrame.createManager {Name = script.Name}

function NetworkManager:init()
    self.FireRemote("ToServer")
end

return NetworkManager