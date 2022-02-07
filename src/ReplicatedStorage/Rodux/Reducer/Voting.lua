local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Cryo: table = GameFrame.loadLibrary("Cryo")
local Rodux: table = GameFrame.loadLibrary("Rodux")

local Chapters: Folder = game.ReplicatedStorage.Chapters

local chapterChildren: table = Chapters:GetChildren()
local defaultTable: table = table.create(#chapterChildren)

for index: number, map: Model in next, chapterChildren do 
    defaultTable[map.Name] = 0
end

return Rodux.createReducer(defaultTable, {
    setMapVoteCount = function(state: table, action: table): table
        return Cryo.Dictionary.join(state, {
            [action.mapName] = action.newVoteCount
        })
    end;

    clearVotes = function(state: table, action: table): table
        return defaultTable
    end;
})