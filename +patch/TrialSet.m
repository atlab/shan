%{
patch.TrialSet (computed) #  visual trials
-> patch.Sync
-----
%}

classdef TrialSet < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = patch.Sync & patch.Spikes & patch.Quality
		
    end
    
    methods(Access = protected)
        
        function makeTuples(self, key)
            self.insert(key)
            makeTuples(patch.Trial, key)
        end
        
    end
    
end