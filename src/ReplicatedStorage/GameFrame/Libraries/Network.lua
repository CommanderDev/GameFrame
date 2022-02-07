local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = require(script.Parent.Event)

local isServer = RunService:IsServer()

local events = {}
local callbacks = {}

local Network = {}

local remoteEvent = if isServer then Instance.new("RemoteEvent") else ReplicatedStorage:WaitForChild("RemoteEvent")
local remoteFunction = if isServer then Instance.new("RemoteFunction") else ReplicatedStorage:WaitForChild("RemoteFunction")
remoteEvent.Name = "RemoteEvent"
remoteFunction.Name = "RemoteFunction"
remoteEvent.Parent = ReplicatedStorage
remoteFunction.Parent = ReplicatedStorage

local function invokeMethodServer(playerObject: Player, callbackName: string, ...): ()
    if callbacks[callbackName] then
        return callbacks[callbackName](playerObject, ...)
    end
end

local function invokeMethodClient(callbackName: string, ...): ()
    if callbacks[callbackName] then
        return callbacks[callbackName](...)
    end
end

local event = if isServer then remoteEvent.OnServerEvent else remoteEvent.OnClientEvent
if isServer then 
    remoteFunction.OnServerInvoke = function(playerObject: Player, callbackName: string, ...)
        return invokeMethodServer(playerObject, callbackName, ...)
    end
else 
    remoteFunction.OnClientInvoke = function(callbackName, ...): ()
        return invokeMethodClient(callbackName, ...)
    end
 end

event:Connect(function(playerObject: Player, eventName: string, ...): ()
    if events[eventName] then
        events[eventName]:fire(playerObject, ...)
    end
end)


function Network.fireClient(playerObject: Player, eventName: string, ...): ()
    remoteEvent:FireClient(playerObject, eventName, ...)
end

function Network.fireAllClients(eventName: string, ...): ()
    remoteEvent:FireAllClients(eventName, ...)
end

function Network.fireServer(eventName: string, ...): ()
    remoteEvent:FireServer(eventName, ...)
end

function Network.invokeServer(callbackName: string, ...): ()
    return remoteFunction:InvokeServer(callbackName, ...)
end

function Network.invokeClient(playerObject: Player, callbackName: string, ...): ()
    return remoteFunction:InvokeClient(playerObject, callbackName, ...)
end

function Network.listenForEvent(eventName: string, func): ()
	if not events[eventName] then
		events[eventName] = Event.new()
	end
	return events[eventName]:connect(func)
end

function Network.setCallback(callbackName: string, func): ()
    callbacks[callbackName] = func
end

function Network.disconnectEvent(eventName: string): ()
    if not events[eventName] then return end
    events[eventName]:disconnect()
end

return Network