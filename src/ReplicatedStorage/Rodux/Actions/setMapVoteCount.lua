return function(mapName: string, newVoteCount: number): table 
    return {
        type = "setMapVoteCount";
        mapName = mapName;
        newVoteCount = newVoteCount;
        replicationTarget = "all";
    }
end