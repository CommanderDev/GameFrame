local GameFrame: table = require(game.ReplicatedStorage.GameFrame)

local player: Player = game.Players.LocalPlayer

local PlayerGui: PlayerGui = player:WaitForChild("PlayerGui")
local MainGUI: ScreenGui = PlayerGui:WaitForChild("MainGUI")
local Announcement: TextLabel = MainGUI:WaitForChild("Announcement")
local MapVoting: Frame = MainGUI:WaitForChild("MapVoting")
local VotingGrid: Frame = MapVoting:WaitForChild("Grid")

local ClientStore: table = GameFrame.loadLibrary("ClientStore")
local Network: table = GameFrame.loadLibrary("Network")

local switch = GameFrame.loadFunction("switch")
local GetMapVoteWinner = GameFrame.loadFunction("GetMapVoteWinner")

local RoundClientManager: table = GameFrame.createManager {Name = "RoundClientManager"}

local roundStateEventSignals: table = table.create(10)
local roundStateConnectionNames: table = table.create(10)
local roundStateBinds: table = table.create(10)

Announcement.Text = ""
Announcement.Visible = true
local roundStateChangedSwitches: table = {
    ["Intermission"] = function()
        roundStateBinds[1] = ClientStore:bindToValueChanged(function(newCountdown: number) 
            if newCountdown <= 0 then 
                return
            end
            Announcement.Text = "Game starts in "..newCountdown.." Seconds"
        end, "Round", "RoundCountdown")
    end;

    ["NotEnoughPlayers"] = function()
        Announcement.Text = "Not enough players to start round."
    end;

    ["Vote"] = function()
        Announcement.Text = "Voting..."
        print(ClientStore:getState())
        if not table.find(ClientStore:getState().Round.playersInMatch, player) then return end
        MapVoting.Visible = true
        for index: number, voteButton: ImageButton in next, VotingGrid:GetChildren() do 
            if voteButton:IsA("ImageButton") then 
                roundStateEventSignals[#roundStateEventSignals + 1] = voteButton.MouseButton1Click:Connect(function()
                    print("Voting for", voteButton.Name)
                    Network.fireServer("PlayerVoted", voteButton.Name)
                end)
                roundStateBinds[#roundStateBinds + 1] = ClientStore:bindToValueChanged(function(newVotes: number)
                    if newVotes == 0 then 
                        voteButton.Votes.Text = ""
                    else
                        voteButton.Votes.Text = newVotes
                    end
                end, "Voting", voteButton.Name)
            end
        end
    end;

    ["DetermineVoteWinner"] = function()
        MapVoting.Visible = false
        Announcement.Text = "The selected map is: "..GetMapVoteWinner()
    end;
}

local function cleanupRoundState(): ()
    for index: number, connectionName: string in next, roundStateConnectionNames do 
        Network.disconnectEvent(connectionName)
    end

    for index: number, bind: table in next, roundStateBinds do 
       ClientStore:unbindFromValueChanged(bind)
    end

    for index: number, connection: RbxScriptSignal in next, roundStateEventSignals do 
        connection:Disconnect()
    end
    table.clear(roundStateConnectionNames) 
    table.clear(roundStateBinds)
end

local function onRoundStateChanged(newState: string, oldState: string?): ()
    cleanupRoundState()
    if roundStateChangedSwitches[newState] then 
        roundStateChangedSwitches[newState]()
    end
end

function RoundClientManager:init(): ()
    ClientStore:bindToValueChanged(onRoundStateChanged, "Round", "State")
    onRoundStateChanged(ClientStore:getState().Round.State)
end

return RoundClientManager