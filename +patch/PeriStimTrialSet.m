%{
patch.PeriStimTrialSet (computed) # to populate patch.PeriStimTrial
-> patch.Sync
-----
%}

classdef PeriStimTrialSet < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = patch.Sync & (patch.Recording & 'has_led=true') & (patch.RecordingNote & 'recording_purpose="temporal sharpening"') & patch.Spikes & patch.Quality
    end
    
    methods(Access = protected)
        
        function makeTuples(self, key)
            self.insert(key)
            makeTuples(patch.PeriStimTrial, key)
        end
        
    end
    
end