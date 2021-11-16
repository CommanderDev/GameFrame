local RunService = game:GetService("RunService")

local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Class = GameFrame.loadLibrary("Class")

local UI = Class.new()

local scriptChildren = script:GetChildren()
local validElements = table.create(#scriptChildren)

local uiClasses = {}

for index, element in next, scriptChildren do 
    validElements[index] = element.Name
end

RunService.RenderStepped:Connect(function()
    for index, class in next, uiClasses do 
        class:Update()
    end
end)

function UI:Update()
    for index, property in next, self.properties do 
        if self[property] == self.uiObject[property] then continue end
        self.uiObject[property] = self[property]
    end
end

function UI.new(uiObject, parameters)
    assert(uiObject, "UI class need a object.")

    assert(table.find(validElements, uiObject.ClassName), "Element that was passed to UI class is invalid")
    if not parameters then parameters = {} end
    local self = require(script[uiObject.ClassName]).new(uiObject, parameters)
    self.parameters = parameters
    if parameters.callbacks then 
        self.callbacks = parameters.callbacks
    else
        self.callbacks = {}
    end
    self.uiObject = uiObject
    self.uiGroup = parameters.uiGroup or "Main"
    uiClasses[uiObject] = self
    return self
end

function UI:push()

end

function UI:pull()

end

function UI:popup()
    if self.callbacks.Popup then 
        self.callbacks.Popup(self)
    else
        self:SetVisible(true)
    end
end

function UI:close()
    if self.callbacks.Close then
        self.callbacks.Close(self)
    else
        self:SetVisible(false)
    end
end

function UI.getPlayerGui()
    return game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

return UI