local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Cryo = GameFrame.loadLibrary("Cryo")
local Rodux = GameFrame.loadLibrary("Rodux")

local defaultCountdownNumber: number = 15;

return Rodux.createReducer({
    State = "";
    RoundCountdown = defaultCountdownNumber;
    playersInMatch = {};
}, {
    setRoundState = function(state: table, action: table): table
        print("Setting new round state to", action.newRoundState)
        return Cryo.Dictionary.join(state, {
            State = action.newRoundState
        })
    end;

    setRoundCountdown = function(state: table, action: table): table
        if action.newRoundCountdown == "default" then
            action.newRoundCountdown = defaultCountdownNumber
        end
        return Cryo.Dictionary.join(state, {
            RoundCountdown = action.newRoundCountdown
        })
    end;

    addPlayerToMatch = function(state: table, action: table): table 
        table.insert(state.playersInMatch, action.newPlayer)
        return Cryo.Dictionary.join(state, {
            playersInMatch = state.playersInMatch
        })
    end;

    clearPlayersInMatch = function(state: table, action: table): table 
        return Cryo.Dictionary.join(state, {
            playersInMatch = {}
        })
    end
})