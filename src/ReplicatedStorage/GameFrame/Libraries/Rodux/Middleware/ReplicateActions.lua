local GameFrame = require(game.ReplicatedStorage.GameFrame)
local Rodux = GameFrame.loadLibrary("Rodux")

local actionStream = Instance.new("RemoteEvent")
actionStream.Name = "ActionReplication"
actionStream.Parent = game.ReplicatedStorage

local initialStateStream = Instance.new("RemoteFunction")
initialStateStream.Name = "InitialState"
initialStateStream.Parent = game.ReplicatedStorage

local reducer = require(game.ReplicatedStorage.Rodux.Reducer) or Rodux.combineReducers({})

local replicatedStore = Rodux.Store.new(reducer,{})

local function replicationMiddleware(nextDispatch,store)
	return function(action)
		if action.replicationTarget then
			if action.replicationTarget=="all" then
				actionStream:FireAllClients(action)
				replicatedStore:dispatch(action) --update our dummy store
			else
				actionStream:FireClient(action.replicationTarget,action)
			end
		end
		nextDispatch(action)
	end
end

local function provideDefaultState(player)
	return replicatedStore:getState()
end

initialStateStream.OnServerInvoke = provideDefaultState

return replicationMiddleware