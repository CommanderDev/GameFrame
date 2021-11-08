local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestClass = GameFrame.require("TestClass")

local TestManager: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 1, Disabled = true}

function TestManager:init()
    self.class = TestClass.new()
    self.class:test()
end

return TestManager