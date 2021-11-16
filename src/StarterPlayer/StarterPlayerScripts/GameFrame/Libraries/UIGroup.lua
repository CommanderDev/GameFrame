local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Class = GameFrame.loadLibrary("Class")

local UIGroup = Class.new()

local groups = {}

function UIGroup.new(groupName: string, ...)
    local uiInGroup = {...}
    local self = setmetatable({uiInGroup = uiInGroup, groupName = groupName;}, UIGroup)
    groups[groupName] = self
    self.frontUIs = {}
    self.primaryFrontUI = nil
    self:UpdateUI()
    return self
end

function UIGroup:push(UI)
    local indexBeingPushed = table.find(self.uiInGroup, UI)
    assert(indexBeingPushed, "UI is not valid in given group.")
    for index, ui in next, self.uiInGroup do 
        if index == indexBeingPushed then 
            self:pushfront()
        else
            self:pushback(UI)
        end
    end
end

function UIGroup:UpdateUI()
    print(self.frontUIs)
    for index, UI in next, self.uiInGroup do 
        if table.find(self.frontUIs, UI) then 
            UI:popup()
        else
            UI:close()
        end
    end
end

function UIGroup:push(UI, index)
    local indexBeingPushed = table.find(self.uiInGroup, UI)
    assert(indexBeingPushed, "UI is not valid in given group.")
    table.remove(self.uiInGroup, indexBeingPushed)
    table.insert(self.uiInGroup, index, UI)
    if index == 1 then 
        self.frontUIs = {}
        self.primaryFrontUI = UI
        table.insert(self.frontUIs, UI)
        for index, mergedUi in next, UI.mergedUIs do 
            table.insert(self.frontUIs, mergedUi)
        end
    end
    self:UpdateUI()
end

function UIGroup:pushfront(UI)
    self:push(UI, 1)
end

function UIGroup:pushto(UI, index)
    self:push(UI, index)
end

function UIGroup:pushback(UI)
    self:push(UI, #self.uiInGroup)
end

function UIGroup:merge(UI, ...)
    local uisToMerge = {...}
    if not UI.uisToMerge then 
        UI.mergedUIs = {}
    end
    for index, uiToMerge in next, uisToMerge do 
        if not uiToMerge.mergedUIs then 
            uiToMerge.mergedUIs = {}
        end
        table.insert(uiToMerge.mergedUIs, UI)
        table.insert(UI.mergedUIs, uiToMerge)
    end
end

function UIGroup:split(UI, ...)
    local uisToSplit = {...}
    if not UI.mergedUIs then return end
    for index, mergedUI in next, UI.mergedUIs do 
        local uiIndex = table.find(mergedUI.mergedUIs, UI)
        table.remove(mergedUI.mergedUIs, uiIndex)
        table.remove(UI.mergedUIs, index)
    end
    for index, ui in next, self.frontUIs do 
        if self.primaryFrontUI == ui then continue end
        table.remove(self.frontUIs, ui)
    end

    self:UpdateUI()
end

function UIGroup:addToGroup(UI)
    table.insert(self.uiInGroup, UI)
end

function UIGroup.getGroup(groupName: string)
    return groups[groupName]
end

return UIGroup