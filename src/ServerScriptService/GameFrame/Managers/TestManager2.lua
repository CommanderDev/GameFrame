local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager2: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 2}

function TestManager2:init()
    print("TestManager 2 ran")
end

return TestManager2
