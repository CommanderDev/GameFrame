local GameFrame = require(game.ReplicatedStorage.GameFrame)
local Rodux = GameFrame.loadLibrary("Rodux")

local reducer = require(game.ReplicatedStorage.Rodux.Reducer) or Rodux.combineReducers({})
local replicationMiddleware = require(script.Parent.Rodux.Middleware.ReplicateActions)

--just in case replicationmiddleware isn't included
replicationMiddleware = replicationMiddleware or function(nextDispatch,store)
	return function(action)
		nextDispatch(action)
	end
end

local store = Rodux.Store.new(reducer,{},{
	--Rodux.loggerMiddleware;
	replicationMiddleware;
})

return store