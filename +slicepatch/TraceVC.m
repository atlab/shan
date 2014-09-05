%{
slicepatch.TraceVC (imported) # Mean traces of a current clamp recording
-> slicepatch.Cell
trace_idx   : tinyint    # trace number
-----
filename    : varchar(255)     # name of the ascii file
trace       : longblob         # mean value of a number of sweeps of current, in pA
baseline    : double           # baseline of this trace, in pA
time        : longblob         # time of this trace, in ms
led         : longblob         # mark the on off state of led stimulation, 1 means on, 0 means off, same length as time and trace
dt          : double           # time of each data point
vm          : double           # clamping voltage, in mV
%}

classdef TraceVC < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = slicepatch.Cell
    end
	methods(Access=protected)
        function makeTuples(self, key)
            p = fetch1(slicepatch.Slice & key,'data_path');
            f = fetch1(slicepatch.Cell & key, 'cell_id');
            f = num2str(f);
            
            localpath = getLocalPath([p '/' f ' V']);
            w = dir([localpath '*']);                
            disp(['Found ' num2str(length(w)) ' file(s)']);
            if isempty(w)
                return
            end
            dt = 0.04;
            for ii = 1:length(w)
                tuple=key;
                tuple.trace_idx = ii;
                file_name = w(ii).name;
                trace = dlmread([getLocalPath(p) '/' file_name])*1e12;
                time = dt*(0:length(trace)-1);
                led = zeros(size(time));
                figure(1300)
                clf
                plot(time,trace,'k'); hold on
                temp = diff(get(gca,'YTick'));
                h = plot(time,led*temp(1)+trace(1),'b');
                fillAxes;
                linkAxes;
                xlabel('Time/ms');
                ylabel('Current/pA');
                keyTitle(tuple);
                in = '*';
                while ~isempty(in)
                    in = input([file_name ' LED (m:n,q) >>'],'s');
                    if strcmp(in,'redraw')
                        figure(1300)
                        clf
                        plot(time,trace,'k'); hold on
                        temp = diff(get(gca,'YTick'));
                        h = plot(time,led*temp(1)+trace(1),'b');
                        xlabel('Time/ms');
                        ylabel('Current/pA');
                        fillAxes;
                        linkAxes;
                        continue
                    end

                    if isempty(in)
                        continue
                    end
                    [m,n,q] = strread(in,'%d:%d,%d');
                    assert(m>=0 && m<time(end),'Start value out of range.')
                    assert(n>m,'Stop value must be greater than start value.')
                    if n>time(end)
                        n=time(end);
                        warning('Setting stop at end of file');
                    end
                    assert(q==0 || q==1,'Quality value out of range (0-3).')
                    led(m/dt+1:n/dt+1)=q;
                    set(h,'ydata',led*temp(1)+trace(1));
                end
                tuple.filename = file_name;
                tuple.dt = dt;
                tuple.time = time;
                tuple.trace = trace;
                tuple.led = led;
                tuple.baseline = mean(trace(1:100));
                temp = regexp(file_name, '[0-9]{2}', 'match');
                if isempty(temp)
                    tuple.vm = 0;
                else
                    tuple.vm = str2double(decell(temp));
                end
                             
                self.insert(tuple)
            end
			
		end
	end

end