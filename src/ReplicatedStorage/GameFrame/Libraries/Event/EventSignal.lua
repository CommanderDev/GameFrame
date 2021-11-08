local EventSignal = {}
EventSignal.__index = EventSignal

function EventSignal:fire(...)
	self.func(...)
end

function EventSignal:disconnect()
	self.connected = false
	self.func = nil
end

EventSignal.new = function(func)
	local self = setmetatable({}, EventSignal)
	
	self.func = func	
	self.connected = true	
	
	return self
end

return EventSignal