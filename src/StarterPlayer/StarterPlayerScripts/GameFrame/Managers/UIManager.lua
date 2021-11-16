local GameFrame = require(game.ReplicatedStorage.GameFrame)

local UI = GameFrame.LoadLibrary("UI")
local UIGroup = GameFrame.loadLibrary("UIGroup")

local PlayerGui = UI.getPlayerGui()

local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

local UIManager = GameFrame.CreateManager {Name = script.Name}

--[[
local Frame = UI.new(ScreenGui:WaitForChild("Frame"))
local Frame2 = UI.new(ScreenGui:WaitForChild("Frame2"))
local Frame3 = UI.new(ScreenGui:WaitForChild("Frame3"))

local MainUIGroup = UIGroup.new("Main", Frame, Frame2,Frame3)

function UIManager:init()
    while task.wait(2) do
        MainUIGroup:merge(Frame2, Frame)
        MainUIGroup:pushfront(Frame2)
        task.wait(2)
        MainUIGroup:split(Frame2, Frame)
    end
end

]]

return UIManager