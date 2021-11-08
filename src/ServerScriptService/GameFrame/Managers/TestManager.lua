local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestClass = GameFrame.require("TestClass")

local TestManager: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 1}

function TestManager:init()
    self.TestManager2 = self.framework.getManager("TestManager2")
    print(self.TestManager2)
    print(self.framework.waitForLocalManagersLoaded())
    print("All Managers were loaded!")
end

return TestManager