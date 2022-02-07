return function(player: Player, role: string): table 
    return {
        type = "setPlayerRole";
        player = player;
        role = role;
        replicationTarget = player;
    }
end