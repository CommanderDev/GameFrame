local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Signal = require(script.Parent.Signal)
local NoYield = require(script.Parent.NoYield)

local Store = {}

-- This value is exposed as a private value so that the test code can stay in
-- sync with what event we listen to for dispatching the Changed event.
-- It may not be Heartbeat in the future.
Store._flushEvent = RunService.Heartbeat

Store.__index = Store

local function getDictionaryPath(dictionary,...)
	local path = {...}
	local currentDirectory = dictionary
	for _,index in ipairs(path) do
		if typeof(currentDirectory) == "table" then
			currentDirectory = currentDirectory[index]
		else
			--return nil
		end
	end
	return currentDirectory
end
--[[
	Create a new Store whose state is transformed by the given reducer function.

	Each time an action is dispatched to the store, the new state of the store
	is given by:

		state = reducer(state, action)

	Reducers do not mutate the state object, so the original state is still
	valid.
]]

function Store.new(reducer, initialState, middlewares)
	assert(typeof(reducer) == "function", "Bad argument #1 to Store.new, expected function.")
	assert(middlewares == nil or typeof(middlewares) == "table", "Bad argument #3 to Store.new, expected nil or table.")

	local self = {}

	self._reducer = reducer
	self._state = reducer(initialState, {
		type = "@@INIT",
	})
	self._lastState = self._state

	self._mutatedSinceFlush = false
	self._connections = {}

	self.changed = Signal.new()

	self._changedBinds = {}

	setmetatable(self, Store)

	local connection = self._flushEvent:Connect(function()
		self:flush()
	end)
	table.insert(self._connections, connection)

	self._changedBindsProcessor = self.changed:connect(function(newState,oldState)
		for _,bind in pairs(self._changedBinds) do
			local newValue = getDictionaryPath(newState,unpack(bind.path))
			local oldValue = getDictionaryPath(oldState,unpack(bind.path))
			if newValue~=oldValue then
				coroutine.wrap(bind.callback)(newValue,oldValue)
			end
		end
	end)

	if middlewares then
		local unboundDispatch = self.dispatch
		local dispatch = function(...)
			return unboundDispatch(self, ...)
		end

		for i = #middlewares, 1, -1 do
			local middleware = middlewares[i]
			dispatch = middleware(dispatch, self)
		end

		self.dispatch = function(self, ...)
			return dispatch(...)
		end
	end

	return self
end

--[[
	Get the current state of the Store. Do not mutate this!
]]
function Store:getState()
	return self._state
end

--[[
	Dispatch an action to the store. This allows the store's reducer to mutate
	the state of the application by creating a new copy of the state.

	Listeners on the changed event of the store are notified when the state
	changes, but not necessarily on every Dispatch.
]]
function Store:dispatch(action)
	if typeof(action) == "table" then
		if action.type == nil then
			error("action does not have a type field", 2)
		end

		self._state = self._reducer(self._state, action)
		self._mutatedSinceFlush = true
	else
		error(("actions of type %q are not permitted"):format(typeof(action)), 2)
	end
end

--[[
	Marks the store as deleted, disconnecting any outstanding connections.
]]
function Store:destruct()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = nil
end

--[[
	Flush all pending actions since the last change event was dispatched.
]]
function Store:flush()
	if not self._mutatedSinceFlush then
		return
	end

	self._mutatedSinceFlush = false

	-- On self.changed:fire(), further actions may be immediately dispatched, in
	-- which case self._lastState will be set to the most recent self._state,
	-- unless we cache this value first
	local state = self._state

	-- If a changed listener yields, *very* surprising bugs can ensue.
	-- Because of that, changed listeners cannot yield.
	NoYield(function()
		self.changed:fire(state, self._lastState)
	end)

	self._lastState = state
end

--[[
	Fires the given function when the given value is changed
]]
function Store:bindToValueChanged(callback,...): table
	local path = {...}
	path = if type(path[1]) == "table" then path[1] else path
	local handle = HttpService:GenerateGUID(false)
	self._changedBinds[handle] = {
		callback = callback;
		path = path;
	}
	return handle
end

function Store:unbindFromValueChanged(handle): boolean
	if self._changedBinds[handle] then
		self._changedBinds[handle] = nil
		return true
	end
	return false
end

return Store
