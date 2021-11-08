local GameFrame = require(game.ReplicatedStorage.GameFrame)

local NetworkManager = GameFrame.createManager {Name = "NetworkManager"}

function NetworkManager:init()
    print(self)
    self.TestFunction = self.frame.loadFunction("TestFunction")
    self.TestFunction()
    print(self.TestFunction)
end

return NetworkManager