local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestClass = GameFrame.require("TestClass")

local TestManager: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 1}

function TestManager:init()
    self.framework.WaitForAllManagersCallback(function()
        print("All managers loaded!")
    end)
end

return TestManager