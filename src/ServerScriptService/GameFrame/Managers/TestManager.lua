local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 2}

function TestManager:init()
    print(self)
    self.listenForEvent("TestEvent", function()
        print("Test event successfully retrieved!")
    end)
end

return TestManager