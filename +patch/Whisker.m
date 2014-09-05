%{
patch.Whisker (imported) # whisker velocity and timestamps
-> patch.Recording
-----
whisker_pos        : mediumblob # whisker position
whisker_time       : mediumblob # timestamps of each framee in seconds, with same t=0 as patch and ball data
whisker_roi        : tinyblob # coordinates of rectangular image region with whiskers
whisker_mask       : mediumblob # logical mask of ROI
whisker_quality    : tinyint # 0 = unusable, 1=usable but w/ ball motion or other problem, 2=usuable with ball mask
whisker_ts = CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Whisker < dj.Relvar
    
    methods
        function makeTuples(self, key, whiskT)
        tuple = key;
        tuple.whisker_pos = zeros(size(whiskT));
        tuple.whisker_time = whiskT;
        self.insert(tuple);
        end
    end
end


