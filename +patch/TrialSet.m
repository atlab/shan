%{
patch.TrialSet (computed) #  visual trials
-> patch.Sync
-----
%}

classdef TrialSet < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        popRel = patch.Sync
		table = dj.Table('patch.TrialSet')
    end
    
    methods(Access = protected)
        
        function makeTuples(self, key)
            self.insert(key)
            makeTuples(patch.Trial, key)
        end
        
    end
    
end