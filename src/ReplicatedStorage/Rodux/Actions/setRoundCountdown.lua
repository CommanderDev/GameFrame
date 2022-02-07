return function(newRoundCountdown, isIncrement): table
    return {
        type = "setRoundCountdown";
        newRoundCountdown = newRoundCountdown;
        replicationTarget = "all";
    }
end