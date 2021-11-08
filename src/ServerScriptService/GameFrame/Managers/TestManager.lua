local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 2}

function TestManager:init()
    self.Network = self.frame.loadLibrary("Network")
    print(self.frame.isLibrary(self.Network))
end

return TestManager