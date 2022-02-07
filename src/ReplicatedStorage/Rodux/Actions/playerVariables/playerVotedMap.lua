return function(player: Player, hasVoted: boolean): table 
    return {
        type = "playerVotedMap";
        player = player;
        hasVoted = hasVoted;
    }
end