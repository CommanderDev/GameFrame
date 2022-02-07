local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Cryo: table = GameFrame.loadLibrary("Cryo")
local Rodux: table = GameFrame.loadLibrary("Rodux")

return Rodux.createReducer({}, {
    createPlayerVariables = function(state: table, action: table): table
        return Cryo.Dictionary.join(state, {
            [action.player] = action.newVariables
        })
    end;
    playerVotedMap = function(state: table, action: table): table 
        return Cryo.Dictionary.join(state, {
            [action.player] = Cryo.Dictionary.join(state, {
                playerVotedMap = action.hasVoted
            })
        })
    end;

    setPlayerRole = function(state: table, action: table): table
        return Cryo.Dictionary.join(state, {
            [action.player] = Cryo.Dictionary.join(state, {
                role = action.role
            })
        })
    end
})