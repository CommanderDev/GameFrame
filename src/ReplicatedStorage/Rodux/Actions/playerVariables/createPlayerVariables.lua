return function(player: Player, newVariables: table): table
    return {
        type = "createPlayerVariables";
        newVariables = newVariables;
        player = player;
        replicationTarget = player;
    }
end