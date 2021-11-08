local EventSignal = require(script.EventSignal)

local Event = {}
Event.__index = Event

function Event:connect(func)
	local signal = EventSignal.new(func)	
	table.insert(self.signals, signal)	
	return signal
end

function Event:disconnect(index)
	table.remove(self.signals, index)
end

function Event:fire(...)
	for index, signal in next, self.signals do
		if signal.connected then
			coroutine.wrap(signal.fire)(signal, ...)
		else
			self:disconnect(index)		
		end
	end
end

function Event:wait()
	local returnValues
	
	local signal 
	signal = self:connect(function(...)
		returnValues = {...}
		signal:disconnect()
	end)
	while signal.connected do task.wait() end
	return unpack(returnValues)
end

Event.new = function()
	local self = setmetatable({}, Event)	

	self.signals = {}
	
	return self
end

return Event