local GameFrame = require(game.ReplicatedStorage.GameFrame)

local UI = GameFrame.LoadLibrary("UI")

local PlayerGui = UI.getPlayerGui()

local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

local Frame = UI.new(ScreenGui:WaitForChild("Frame"))
local UIManager = GameFrame.CreateManager {Name = script.Name}

function UIManager:init()
    Frame.Visible = true
    Frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
    print(Frame)
end

return UIManager