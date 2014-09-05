%{
patch.Ball (imported) # ball velocity and timestamps
-> patch.Recording
-----
ball_vel         : longblob # raw ball velocity
ball_time       : longblob # timestamps of each sample in seconds, with same t=0 as patch and camera data
ball_ts = CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Ball < dj.Relvar
    methods
        function makeTuples(self, key, ballV, ballT)
        tuple = key;
        tuple.ball_vel = ballV;
        tuple.ball_time = ballT;
        self.insert(tuple);
        end
    end
end


