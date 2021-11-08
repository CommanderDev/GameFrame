
local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Class = GameFrame.loadLibrary("Class")

local Frame = Class.new(require(script.Parent))

local properties = {
    "Active";
    "Archivable";
    "Visible";
    "BackgroundColor3";
    "Position";
    "Size";
    "AnchorPoint";
    "AutomaticSize";
    "BorderColor3";
    "BorderMode";
    "BorderSizePixel";
    "LayoutOrder";
    "Name";
    "Parent";
    "Rotation";
    "Selectable";
    "SizeConstraint";
    "Style";
    "ZIndex";
    "AutoLocalize"
}


function Frame.new(frameObject, parameters)
    local self = setmetatable({properties = properties}, Frame)
    for parameterName, parameter in next, parameters do 
        self[parameterName] = parameter
    end

    for index, property in next, properties do 
        self[property] = parameters[property] or frameObject[property]
    end

    self.propertyChangedMethods = {
        Enabled = function()
            
        end
    }
    return self
end

function Frame:SetVisible(boolean)
    self.frameObject.Visible = boolean
end

return Frame