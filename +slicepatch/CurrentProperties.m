%{
slicepatch.CurrentProperties (computed) # amplitude and latency for VC current traces
->slicepatch.FineTraceVC
-----
res            : tinyint    # true if the cell is responsive to LED stimulation, and show an excitation
nled           : tinyint    # number of led pulses
vm             : double     # clamping voltage
amp            : double     # peak excitation amplitude of the first stimulation
latency        : double     # latency of the response, nan if cell is not responsive
ppr            : double     # pair pulse ratio, nan if there is only one led stimulus
cnqx           : tinyint    # true if CNQX is applied in this trace
apv            : tinyint    # true if APV is applied in this trace
ttx            : tinyint    # true if TTX is applied in this trace
picrotoxin     : tinyint    # true if picrotoxin is applied in this trace
ap4            : tinyint    # true if 4ap is applied in this 
quality        : tinyint    # trace quality, 0 if baseline current >1000pA
%}

classdef CurrentProperties < dj.Relvar & dj.AutoPopulate
	
     properties
        popRel = slicepatch.FineTraceVC
     end
     methods(Access=protected)
        
		function makeTuples(self, key)
            trace_vc = fetch(slicepatch.FineTraceVC & key,'*');
            vm = abs(fetch1(slicepatch.TraceVC & key, 'vm'));
            filename = fetch1(slicepatch.TraceVC & key,'filename');
            trace = trace_vc.finetrace - trace_vc.baseline;

            dt = trace_vc.dt;
            time = trace_vc.time;
            
            key.quality = 0;
            if abs(trace_vc.baseline)<1000 && abs(trace_vc.baseline)>500
                key.quality = 1;
            elseif abs(trace_vc.baseline)<500
                key.quality = 2;
            end
            % compute number of led pulses
            key.nled = sum(diff(trace_vc.led)==1);
            idx = find(diff(trace_vc.led)==1);
            % check if the cell is responsive
            noise = std(trace(1:idx(1)));
            if vm == 0
                [peak, peak_idx] = max(trace(idx(1):idx(1)+floor(35/dt)));
            else 
                [peak, peak_idx] = min(trace(idx(1):idx(1)+floor(35/dt)));
            end
            key.res = 0;
            
            if abs(peak)>2*noise
                key.res = 1;
            end
                        
            if ~key.res
                key.latency = -1;
                key.amp = 0;
                key.ppr = -1;
            else
                % calculate latency: latency is defined as the x extrapolate of 20% peak and 80% peak
                trace_rel = trace(idx(1):idx(1)+peak_idx);
                time_rel = time(idx(1):idx(1)+peak_idx);
                peak_20 = 0.2*peak;
                peak_80 = 0.8*peak;
                
                time_20 = interp1(trace_rel, time_rel, peak_20, 'linear','extrap');
                time_80 = interp1(trace_rel, time_rel, peak_80, 'linear','extrap');
                
                time_latency = interp1([peak_20, peak_80], [time_20, time_80], 0, 'linear','extrap');
                

                key.latency = time_latency - time(idx(1));
                key.amp = abs(peak);
            end
            
            % manually monitor the correctness of amplitudes
            figure(1300)
            set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
            clf
            plot(trace_vc.time, trace, 'k'); hold on
            temp = diff(get(gca, 'Ytick'));
            plot(trace_vc.time, trace_vc.led*temp(1),'b');
            
            if key.res
                h = plot(trace_vc.time(idx(1)+peak_idx), trace(idx(1)+peak_idx), 'rx');
                h0 = plot(time_latency, 0, 'cx');
            end
            
            if abs(peak)<50
                ylim([-50, 50]);
            end
            
            amp = '*';
            while ~isempty(amp)
                fprintf('Responsive:%d; amp:%4.2f; latency:%4.2f; Vm:%4.0f\n', key.res, key.amp, key.latency,vm);
                filename
                disp 'Click the excitatory peak if needed:'
                [~,amp] = ginput(1);
                if strcmp(amp,'redraw')
                    figure(1300)
                    set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
                    clf
                    plot(trace_vc.time, trace, 'k'); hold on
                    temp = diff(get(gca, 'Ytick'));
                    plot(trace_vc.time, trace_vc.led*temp(1),'b');
                    if abs(peak_high)<50;
                        ylim([-50,50]);
                    end
                end

                if isempty(amp)
                    continue
                end
                
                if abs(amp)<1
                    amp=0;
                end

                key.amp = abs(amp);
                
                if key.amp==0
                    key.res=0;
                    key.latency = -1;
                else
                    key.res=1;
                end
                if key.res
                    if exist('h','var')
                        if vm == 0;
                        set(h,'ydata',key.amp);
                        else
                            set(h,'ydata',-key.amp);
                        end
                    end
                end
            end
            latency = '*';
            while ~isempty(latency)
                fprintf('Responsive:%d; amp:%4.2f; latency:%4.2f\n', key.res, key.amp, key.latency);
                disp 'Click latency if needed:'
                [latency,~] = ginput(1);
                if strcmp(latency,'redraw')
                    close all
                    figure(1300)
                    set(gcf,'Position', get(gcf, 'Position').*[1,1,1.5,1.5]);
                    clf
                    plot(trace_vc.time, trace, 'k'); hold on
                    temp = diff(get(gca, 'Ytick'));
                    plot(trace_vc.time, trace_vc.led*temp(1),'b');
                    if peak_high<50;
                        ylim([-50,50]);
                    end
                end

                if isempty(latency)
                    continue
                end
                latency = latency - time(idx(1));
                key.latency = latency;
                if key.res
                    if exist('h0','var')
                        set(h,'xdata',key.latency);
                    end
                end
            end
         
            
            % for those trials with two led stimulations, calculate PPR
            key.ppr = -100000;
            
            if key.res==1 && key.nled>1 && key.latency<10 && key.latency>0
                if vm==0
                    [peak2, peak_idx2] = max(trace(idx(2):idx(2)+35/dt));
                else
                    [peak2, peak_idx2] = min(trace(idx(2):idx(2)+35/dt));
                end
                h2 = plot(trace_vc.time(idx(2)+peak_idx2), trace(idx(2)+peak_idx2), 'rx');
                amp = '*';
                while ~isempty(amp)
                    
                    h2 = plot(trace_vc.time(idx(2)+peak_idx2), trace(idx(2)+peak_idx2), 'rx');
                    fprintf('amp:%4.2f\n', abs(peak));
                    disp 'Click the second peak if needed:'
                    [~,amp] = ginput(1);
                    if strcmp(amp,'redraw')
                        figure(1300)
                        clf
                        plot(trace_vc.time, trace, 'k'); hold on
                        temp = diff(get(gca, 'Ytick'));
                        plot(trace_vc.time, trace_vc.led*temp(1),'b');
                        if abs(peak)<50;
                            ylim([-50,50]);
                        end
                        
                        
                    end

                    if isempty(amp)
                        continue
                    end

                    peak2 = abs(amp);
                    if exist('h2','var')
                        if vm == 0
                            set(h2,'ydata', peak2);
                        else
                            set(h2,'ydata', -peak2);
                        end
                    end
                end
                
                key.ppr = peak2/key.amp;
            end
            
            % drug usage from the filename
                        
            
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
                key.ttx = 1;
            end
            
            if strfind(filename, 'Picrotoxin')
                key.picrotoxin = 1;
            end
            
            if strfind(filename, '4AP')
                key.ap4 = 1;
            end
            
            if key.res == 0
                key.latency=-1;
            end
            
            key.vm=vm;
            close 1300
            self.insert(key)
            
		end
	end

end