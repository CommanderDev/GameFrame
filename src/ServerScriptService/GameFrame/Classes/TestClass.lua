local GameFrame = require(game.ReplicatedStorage.GameFrame)
local Class = GameFrame.loadLibrary("Class")

local TestClass = Class.new()

function TestClass.new()
    local self = setmetatable({}, TestClass)
    return self
end

function TestClass:test()
    print("Testing class!!")
end

return TestClass