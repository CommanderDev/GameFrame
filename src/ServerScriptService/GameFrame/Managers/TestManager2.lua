local GameFrame = require(game.ReplicatedStorage.GameFrame)

local TestManager2: table = GameFrame.createManager {Name = script.Name, ProcessingOrder = 2}

function TestManager2:init()

end

return TestManager2
