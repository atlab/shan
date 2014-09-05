%{
slicepatch.FineTraceVC (computed) # filter the traces in TraceCC to remove spikes and other noise. 
-> slicepatch.TraceVC
-----
finetrace   : longblob         # trace after filtering, in mV
baseline    : double           # baseline of this trace, in mV
time        : longblob         # time of this trace, in ms
led         : longblob         # mark the on off state of led stimulation, 1 means on, 0 means off, same length as time and trace
dt          : double           # time of each data point
cutfreq     : double           # cutting off frequency of the filter
%}

classdef FineTraceVC < dj.Relvar & dj.AutoPopulate
    properties
        popRel = slicepatch.TraceVC
    end
	methods(Access=protected)

		function makeTuples(self, key)
            tuple = fetch(slicepatch.TraceVC & key, '*');
            key.time = tuple.time;
            key.led = tuple.led;
            key.dt = tuple.dt;
            cutfreq = 200;
            figure(201)
            clf
            plot(tuple.time, tuple.trace); hold on
            plot(tuple.time,ezfilt(tuple.trace,cutfreq,1/tuple.dt*1000,'low'),'r');
            
            in = '*';
            while ~isempty(in)
                if strcmp(in,'redraw');
                    figure(201)
                    clf
                    plot(tuple.time, tuple.trace); hold on
                    plot(tuple.time, ezfilt(tuple.trace,cutfreq,1/tuple.dt*1000,'low'),'r')
                end
                in = input('Please enter the cutting off frequency:');
                if isempty(in)
                    continue
                end
                cutfreq = in;
                clf
                plot(tuple.time, tuple.trace); hold on
                plot(tuple.time, ezfilt(tuple.trace, cutfreq,1/tuple.dt*1000,'low'),'r');
            end
            key.cutfreq = cutfreq;
            key.finetrace = ezfilt(tuple.trace,cutfreq,1/tuple.dt*1000,'low');
            key.baseline = mean(key.finetrace(1:1000));
            self.insert(key)
		end
	end

end