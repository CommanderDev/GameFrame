local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager = GameFrame.createManager {Name = script.Name; ProcessingOrder = 1}

function TestManager:init()
    self.TestLibrary = self.framework.loadLibrary("TestLibrary")
    self.TestLibrary.test()
end

function TestManager:postinit()
    print("TestManager 1 post init!")
end

return TestManager