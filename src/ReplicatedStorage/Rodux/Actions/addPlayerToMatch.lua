return function(newPlayer: Player): table
    return {
        type = "addPlayerToMatch";
        newPlayer = newPlayer;
        replicationTarget = "all";
    }
end