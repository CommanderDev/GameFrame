local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Player = game.Players.LocalPlayer
local Rodux = GameFrame.loadLibrary("Rodux")

local actionStream = game.ReplicatedStorage:WaitForChild("ActionReplication")
local initialStateStream = game.ReplicatedStorage:WaitForChild("InitialState")

local reducer = require(game.ReplicatedStorage.Rodux.Reducer) or Rodux.combineReducers({})

local initialState = initialStateStream:InvokeServer()

local store = Rodux.Store.new(reducer,initialState,{
	-- Rodux.loggerMiddleware --print changes to output
})

--replicate actions from server
actionStream.OnClientEvent:Connect(function(action)
    store:dispatch(action)
end)

return store