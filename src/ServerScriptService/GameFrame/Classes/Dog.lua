local GameFrame = require(game.ReplicatedStorage.GameFrame)
local Class = GameFrame.loadLibrary("Class")

local Dog = Class.new()

function Dog.new(dogName)
    local self = setmetatable({}, Dog)
    self.dogName = dogName
    return self
end

function Dog:bark()
    print(self)
    if self then 
        print(self.dogName)
    end
end

return Dog