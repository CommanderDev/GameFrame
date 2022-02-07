local RunService = game:GetService("RunService")

local GameFrame = require(game.ReplicatedStorage.GameFrame)

local Rodux = GameFrame.loadLibrary("Rodux")

local sharedReducers = script
local localReducers

if RunService:IsServer() then
	localReducers = game.ServerScriptService.GameFrame.Libraries.Rodux.Reducers
else
	local player = game.Players.LocalPlayer
	localReducers = player.PlayerScripts.GameFrame.Libraries.Rodux.Reducers
end

local allReducers = {}

local function addReducers(Source)
	for _,reducer in pairs(Source:GetChildren()) do
		allReducers[reducer.Name] = require(reducer)
	end
end

addReducers(sharedReducers)
addReducers(localReducers)

local reducer = Rodux.combineReducers(allReducers)

return reducer