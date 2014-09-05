%{
slicepatch.VoltageProperties (computed) # amplitude and latency for CC volatage traces
->slicepatch.FineTraceCC
-----
res_exc        : tinyint    # true if the cell is responsive to LED stimulation, and show an excitation
res_inh        : tinyint    # true if the cell is responsive to LED stimulation, and show an inhibition
nled           : tinyint    # number of led pulses
amp_exc        : double     # peak excitation amplitude of the first stimulation
amp_inh        : double     # peak inhibition amplitude of the first stimulation
latency        : double     # latency of the response, nan if cell is not responsive
eiratio        : double     # inhibition-excitation ratio
ppr            : double     # pair pulse ratio, nan if there is only one led stimulus
cnqx           : tinyint    # true if CNQX is applied in this trace
apv            : tinyint    # true if APV is applied in this trace
ttx            : tinyint    # true if TTX is applied in this trace
picrotoxin     : tinyint    # true if picrotoxin is applied in this trace
ap4            : tinyint    # true if 4ap is applied in this trace
%}

classdef VoltageProperties < dj.Relvar & dj.AutoPopulate
	
     properties
        popRel = slicepatch.FineTraceCC
     end
     methods(Access=protected)
        
		function makeTuples(self, key)
            trace_cc = fetch(slicepatch.FineTraceCC & key,'*');
            if abs(trace_cc.finetrace(1) - trace_cc.baseline)<30
                trace = trace_cc.finetrace - trace_cc.baseline;
            else
                trace = trace_cc.finetrace;
            end
            dt = trace_cc.dt;
            time = trace_cc.time;
            % compute number of led pulses
            key.nled = sum(diff(trace_cc.led)==1);
            idx = find(diff(trace_cc.led)==1);
            % check if the cell is responsive
            noise = std(trace(1:idx(1)));
            [peak_high,max_id] = max(trace(idx(1):idx(1)+floor(35/dt)));
            [peak_low,min_id] = min(trace(idx(1)+max_id:idx(1)+floor(80/dt)));
            key.res_exc = 0;
            key.res_inh = 0;
            if peak_high>2*noise
                key.res_exc = 1;
            end
            if peak_low<-2*noise
                key.res_inh = 1;
            end
                        
            if ~key.res_exc 
                key.latency = -1;
                key.amp_exc = 0;
                key.ppr = -1;
            else
                % calculate latency: latency is defined as the x extrapolate of 20% peak and 80% peak
                trace_rel = trace(idx(1):idx(1)+max_id);
                time_rel = time(idx(1):idx(1)+max_id);
                peak_20 = 0.2*peak_high;
                peak_80 = 0.8*peak_high;
                
                time_20 = interp1(trace_rel, time_rel, peak_20, 'linear','extrap');
                time_80 = interp1(trace_rel, time_rel, peak_80, 'linear','extrap');
                
                time_latency = interp1([peak_20, peak_80], [time_20, time_80], 0, 'linear','extrap');
                
                key.latency = time_latency - time(idx(1));
                key.amp_exc = peak_high;
            end
            
            if ~key.res_inh
                key.amp_inh = 0;
            else
                key.amp_inh = -peak_low;
            end
            
            % manually monitor the correctness of amplitudes
            figure(1300)
            set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
            clf
            plot(trace_cc.time, trace, 'k'); hold on
            temp = diff(get(gca, 'Ytick'));
            plot(trace_cc.time, trace_cc.led*temp(1),'b');
            
            if key.res_exc
                h1 = plot(trace_cc.time(idx(1)+max_id), trace(idx(1)+max_id), 'rx');
                h = plot(time_latency, 0, 'cx');
            end
            if key.res_inh
                h2 = plot(trace_cc.time(idx(1)+max_id+min_id), trace(idx(1)+max_id+min_id), 'gx');
            end
            if peak_high<5;
                ylim([-5,5]);
            end
            
            amp_exc = '*';
            while ~isempty(amp_exc)
                fprintf('Responsive:%d; amp:%4.2f; latency:%4.2f\n', key.res_exc, key.amp_exc, key.latency);
                disp 'Click the excitatory peak if needed:'
                [~,amp_exc] = ginput(1);
                if strcmp(amp_exc,'redraw')
                    figure(1300)
                    set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
                    clf
                    plot(trace_cc.time, trace, 'k'); hold on
                    temp = diff(get(gca, 'Ytick'));
                    plot(trace_cc.time, trace_cc.led*temp(1),'b');
                    if peak_high<5;
                        ylim([-5,5]);
                    end
                end

                if isempty(amp_exc)
                    continue
                end
                
                if abs(amp_exc)<0.2
                    amp_exc=0;
                end

                key.amp_exc = amp_exc;
                
                if key.amp_exc==0
                    key.res_exc=0;
                    key.latency = -1;
                else
                    key.res_exc=1;
                end
                if key.res_exc
                    if exist('h1','var')
                        set(h1,'ydata',key.amp_exc);
                    end
                end
            end
            latency = '*';
            while ~isempty(latency)
                fprintf('Responsive:%d; amp:%4.2f; latency:%4.2f\n', key.res_exc, key.amp_exc, key.latency);
                disp 'Click latency if needed:'
                [latency,~] = ginput(1);
                if strcmp(latency,'redraw')
                    close all
                    figure(1300)
                    set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
                    clf
                    plot(trace_cc.time, trace, 'k'); hold on
                    temp = diff(get(gca, 'Ytick'));
                    plot(trace_cc.time, trace_cc.led*temp(1),'b');
                    if peak_high<5;
                        ylim([-5,5]);
                    end
                end

                if isempty(latency)
                    continue
                end
                latency = latency - time(idx(1));
                key.latency = latency;
                if key.res_exc
                    if exist('h','var')
                        set(h,'xdata',key.latency);
                    end
                end
            end
            
            amp_inh = '*';
            while ~isempty(amp_inh)
                fprintf('Responsive:%d; amp:%4.2f\n', key.res_inh, key.amp_inh);
                disp 'Click the inhibtory peak if needed:'
                [~,amp_inh] = ginput(1); 
                if strcmp(amp_inh,'redraw')
                    figure(1300)
                    set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
                    clf
                    plot(trace_cc.time, trace, 'k'); hold on
                    temp = diff(get(gca, 'Ytick'));
                    plot(trace_cc.time, trace_cc.led*temp(1),'b');
                    if peak_high<5;
                        ylim([-5,5]);
                    end
                end

                if isempty(amp_inh)
                    continue
                end
                
                if abs(amp_inh)<0.2
                    amp_inh=0;
                end

                key.amp_inh = abs(amp_inh);
                
                if key.amp_inh==0
                    key.res_inh =0;
                else
                    key.res_inh = 1;
                end
                if key.res_inh
                    if exist('h2','var')
                        set(h2, 'ydata', -key.amp_inh);
                    end
                end
           
            end
            
            if key.res_exc && key.res_inh
                key.eiratio = (key.amp_inh - key.amp_exc)/(key.amp_inh + key.amp_exc);
            else
                key.eiratio=-100000;
            end
           
            
            % for those trials with two led stimulations, calculate PPR
            key.ppr = -100000;
            
            if key.res_exc==1 && key.nled>1 && key.latency<10 && key.latency>0
                [peak_high2, max_id2] = max(trace(idx(2):idx(2)+15/dt));
                
                amp = '*';
                while ~isempty(amp)
                    h3 = plot(trace_cc.time(idx(2)+max_id2), trace(idx(2)+max_id2), 'rx');
                    fprintf('amp:%4.2f\n', peak_high2);
                    disp 'Click the second peak if needed:'
                    [~,amp] = ginput(1);
                    if strcmp(amp,'redraw')
                        figure(1300)
                        clf
                        plot(trace_cc.time, trace, 'k'); hold on
                        temp = diff(get(gca, 'Ytick'));
                        plot(trace_cc.time, trace_cc.led*temp(1),'b');
                        if peak_high<5;
                            ylim([-5,5]);
                        end
                    end

                    if isempty(amp)
                        continue
                    end
                    
                    if abs(amp)<0.2
                        amp = 0;
                    end

                    peak_high2 = amp;
                end
                if exist('h3','var')
                    set(h3,'ydata', amp);
                end
                key.ppr = peak_high2/key.amp_exc;
            end
            
            % drug usage from the filename
            filename = fetch1(slicepatch.TraceCC & key,'filename');            
            
            key.cnqx = 0;
            key.apv = 0;
            key.picrotoxin = 0;
            key.ttx=0;
            key.ap4 = 0;
            
            if strfind(filename, 'CNQX')
                key.cnqx = 1;
            end
            
            if strfind(filename, 'APV');
                key.apv = 1;
            end
            
            if strfind(filename, 'TTX');
                key.TTX = 1;
            end
            
            if strfind(filename, 'Picrotoxin')
                key.picrotoxin = 1;
            end
            
            if strfind(filename, '4AP')
                key.ap4 = 1;
            end
            
            if key.res_exc == 0
                key.latency=-1;
            end
            
            close 1300
            self.insert(key)
            
		end
	end

end