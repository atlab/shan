%{
slicepatch.FineTraceCCAlign (computed) # align the traces to the onset of the led stimulus
-> slicepatch.FineTraceCC
-----
win         : blob             # [w1,w2], time window -w1:w2 collected from around the onset of led stimulus, in ms
finetrace   : longblob         # trace aligned to led onset, also substracted with vm onset, in mV
baseline    : double           # baseline of this trace, in mV
vm_onset    : double           # membrane potential at the led onset, in mV
time        : longblob         # time of this trace, in ms, aligned to led onset
led         : longblob         # mark the on off state of led stimulation, 1 means on, 0 means off, same length as time and trace
dt          : double           # time of each data point
%}

classdef FineTraceCCAlign < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = slicepatch.FineTraceCC & 'baseline<-55' & 'baseline>-65';
    end
	methods(Access=protected)

		function makeTuples(self, key)
            
            % fetch data from table FineTraceCC
            [finetrace, baseline, time, led, dt] = fetch1(slicepatch.FineTraceCC & key, 'finetrace', 'baseline','time','led','dt');
            
            
            ledDiff = diff(led);
            
            idx_on = find(ledDiff==1) + 1;
            
            if length(idx_on)==1
                win = [50,200];
            else
                win = [50,300];
            end
            
            idx_start = idx_on(1) - round(win(1)/dt);
            idx_end = idx_on(1) + round(win(2)/dt);
            
            key.vm_onset = finetrace(idx_on(1));
            key.finetrace = finetrace(idx_start:idx_end) - key.vm_onset;
            key.time = time(idx_start:idx_end) - time(idx_on(1));
            key.win = win;
            key.baseline = baseline;
            key.led = led(idx_start:idx_end);
            key.dt = dt;
           
			self.insert(key)
		end
	end

end