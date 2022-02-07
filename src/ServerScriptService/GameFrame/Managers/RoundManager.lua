local CollectionService = game:GetService("CollectionService")

local GameFrame = require(game.ReplicatedStorage.GameFrame)

local joinButtonConnections: table = {}
local RoundManager = GameFrame.createManager {Name = "RoundManager"}

local ServerStore = GameFrame.loadLibrary("ServerStore")
local Network = GameFrame.loadLibrary("Network")

local switch = GameFrame.loadFunction("switch")

local setRoundState = GameFrame.require("setRoundState")
local setRoundCountdown = GameFrame.require("setRoundCountdown")
local setMapVoteCount = GameFrame.require('setMapVoteCount')
local clearVotes = GameFrame.require("clearVotes")
local addPlayerToMatch = GameFrame.require("addPlayerToMatch")
local clearPlayersInMatch = GameFrame.require("clearPlayersInMatch")
local playerVotedMap = GameFrame.require("playerVotedMap")
local createPlayerVariables = GameFrame.require("createPlayerVariables")

local Chapters = game.ReplicatedStorage.Chapters

local GetMapVoteWinner = GameFrame.loadFunction("GetMapVoteWinner")
local joinButtons: table = CollectionService:GetTagged("JoinButton")


local minRequired: number = 1

local map: Model? = nil
local RoundModule: table? = GameFrame.require("Survivor")
local function disconnectJoinButton(joinButton: BasePart): ()
    joinButtonConnections[joinButton]:Disconnect()
end

local function disconnectAllJoinButtons(): ()
    for index: number, joinButton: BasePart in next, joinButtons do 
        disconnectJoinButton(joinButton)
    end
end

local function connectJoinButton(joinButton: BasePart): ()
    joinButtonConnections[joinButton] = joinButton.Touched:Connect(function(hit: BasePart)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent) or game.Players:GetPlayerFromCharacter(hit.Parent.Parent)
        if not player or table.find(ServerStore:getState().Round.playersInMatch, player) then return end
        disconnectJoinButton(joinButton)
        ServerStore:dispatch(addPlayerToMatch(player))
        joinButton.BrickColor = BrickColor.new("Bright red")
    end)
end

local function connectAllJoinButtons(): ()
    for index: number, joinButton: BasePart in next, joinButtons do 
        connectJoinButton(joinButton)
    end
end

local function cleanupPreviousRound()
    for index: number, joinButton: BasePart in next, joinButtons do 
        joinButton.BrickColor = BrickColor.new("Medium stone grey")
    end

    for index: number, player: Player in next, ServerStore:getState().Round.playersInMatch do 
        ServerStore:dispatch(clearPlayersInMatch())
        ServerStore:dispatch(createPlayerVariables(player, {
            playerVotedMap = false;
        }))
    end
    map.Parent = Chapters
end
function RoundManager:init(): ()
    local roundStateNetworkConnectionNames: table = table.create(10)
    local roundStateSwitches: table = {
        ["Intermission"] = function(): ()
            cleanupPreviousRound()
            connectAllJoinButtons()
            ServerStore:dispatch(setRoundCountdown("default"))
            while ServerStore:getState().Round.RoundCountdown > 0 and task.wait(1) do 
                ServerStore:dispatch(setRoundCountdown(ServerStore:getState().Round.RoundCountdown - 1, true))
            end
            if #ServerStore:getState().Round.playersInMatch >= minRequired then 
                ServerStore:dispatch(setRoundState("Vote"))
            else
                ServerStore:dispatch(setRoundState("NotEnoughPlayers"))
                task.wait(5)
                ServerStore:dispatch(setRoundState("Intermission"))
            end
        end;

        ["Vote"] = function(): ()
            disconnectAllJoinButtons()
            ServerStore:dispatch(clearVotes())
            roundStateNetworkConnectionNames[1] = "PlayerVoted"
            Network.listenForEvent("PlayerVoted", function(player: Player, mapName: string)
                local serverState = ServerStore:getState()
                local currentMapVoteCount: number? = serverState.Voting[mapName]
                local currentPlayerVotedMap: string? = serverState.playerVariables[player].playerVotedMap
                if not currentMapVoteCount or currentPlayerVotedMap == mapName then 
                    return
                end
                if currentPlayerVotedMap then
                    ServerStore:dispatch(setMapVoteCount(currentPlayerVotedMap, serverState.Voting[currentPlayerVotedMap] - 1))
                end
                currentMapVoteCount += 1
                ServerStore:dispatch(playerVotedMap(player, mapName))
                ServerStore:dispatch(setMapVoteCount(mapName, currentMapVoteCount))
            end)
            task.wait(5)
            local mapWinner = GetMapVoteWinner()
            print(mapWinner)
            ServerStore:dispatch(setRoundState("DetermineVoteWinner"))
            map = Chapters[mapWinner]
            map.Parent = workspace
            task.wait(5)
            ServerStore:dispatch(setRoundState("StartRound"))
        end;

        ["StartRound"] = function()
            RoundModule()
        end;
    }

    local function cleanupRoundState(): () 
        for index: number, connectionName: string in next, roundStateNetworkConnectionNames do 
            Network.disconnectEvent(connectionName)
        end
    end
    ServerStore:bindToValueChanged(function(newRoundState: string): ()
        cleanupRoundState()
        if roundStateSwitches[newRoundState] then 
            roundStateSwitches[newRoundState]()
        end
    end, "Round", "State")
    ServerStore:dispatch(setRoundState("Intermission"))

    local function onPlayerAdded(player: Player): ()
        ServerStore:dispatch(createPlayerVariables(player, {
            playerVotedMap = false;
        }))
    end

    for index: number, player: Player in next, game.Players:GetPlayers() do 
        onPlayerAdded(player)
    end
    game.Players.PlayerAdded:Connect(onPlayerAdded)
end

return RoundManager