local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager = GameFrame.createManager {Name = script.Name}

function TestManager:init()
    print(self)
end

return TestManager