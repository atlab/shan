%{
patch.PeriLedTrialMotionSet (computed) # table to populate patch.PeriLedTrialMotion
-> patch.PeriLedTrialSet
-----

%}

classdef PeriLedTrialMotionSet < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.PeriLedTrialSet
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
			self.insert(key)
		end
	end

end