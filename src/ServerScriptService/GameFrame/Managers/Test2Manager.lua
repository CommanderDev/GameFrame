local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Test2Manager = GameFrame.createManager {Name = script.Name, ProcessingOrder = 1}

function Test2Manager:init()
    print("Test2 Manager init!")
end

return Test2Manager