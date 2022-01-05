local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestClass = GameFrame.require("TestClass")
local Dog = GameFrame.require("Dog")

local TestManager = GameFrame.createManager {Name = script.Name; ProcessingOrder = 1}

function TestManager:init()
    self.D1 = Dog.new("Bob")

    self.D1.bark() 
    self.D1:bark() 
    self.listenForEvent("ToServer", function()
        print("Server got event!")
    end)
end

function TestManager:postinit()
    print("TestManager 1 post init!")
end

return TestManager