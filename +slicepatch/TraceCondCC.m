%{
slicepatch.TraceCondCC (computed) # mark the stimulus condition of the trace
->slicepatch.FineTraceCC
-----
nled         : tinyint         # number of the led stimulus of this trace

%}

classdef TraceCondCC < dj.Relvar & dj.AutoPopulate
    
    properties
       popRel = slicepatch.FineTraceCC
    end
    methods(Access=protected)
        
		function makeTuples(self, key)
            led = fetch1(slicepatch.FineTraceCC & key,'led');
            key.nled = sum(diff(led)==1);
			self.insert(key)
		end
	end

end