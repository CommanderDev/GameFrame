return function(newRoundState: string): table 
    return {
        type = "setRoundState";
        newRoundState = newRoundState;
        replicationTarget = "all";
    }
end