%{
slicepatch.Firing (imported) # my newest table
-> slicepatch.Cell
trace_idx   : tinyint    # trace number
-----
filename    : varchar(255)     # name of the ascii file
trace       : longblob         # trace of this trial
baseline    : double           # baseline of this trace, in mV
time        : longblob         # time of this trace, in ms
ephys       : longblob         # mark the on off state of current injection
led         : longblob         # mark the on off state of led stimulation, 1 means on, 0 means off, same length as time and trace
led_stat    : tinyint          # status of LED of this trial, on or off
dt          : double           # interval of data points
spks        : longblob         # mark the onset of spikes
%}

classdef Firing < dj.Relvar & dj.AutoPopulate
    properties
        popRel = slicepatch.Cell
    end
	methods(Access=protected)

		function makeTuples(self, key)
            p = fetch1(slicepatch.Slice & key,'data_path');
            f = fetch1(slicepatch.Cell & key, 'cell_id');
            f = num2str(f);
            
            localpath = getLocalPath([p '/' f '-trace']);
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
                trace = dlmread([getLocalPath(p) '/' file_name])*1000;
                time = dt*(0:length(trace)-1);
                led = zeros(size(time));
                ephys = zeros(size(time));
                ephys(50/dt+1:350/dt+1)=1;
                spks = zeros(size(time));
                
                temp2 = regexp(file_name,'[0-9]{3}','match');
                led_start = str2double(decell(temp2));
                led_stop = led_start+20;
                led(led_start/dt+1:led_stop/dt+1)=1;
                tuple.led_stat = isempty(regexp(file_name,'off','match'));
                
                figure(1300)
                clf
                plot(time,trace,'k'); hold on
                temp = diff(get(gca,'YTick'));
                h1 = plot(time,ephys*temp(1)+trace(1),'r');
                h2 = plot(time,led*temp(1)*2+trace(1),'b');
                fillAxes;
                linkAxes;
                xlabel('Time/ms');
                ylabel('Membrane potential/mV');
                keyTitle(tuple);
                in = '*';
                
                
                while ~isempty(in)
                    in = input([file_name ' Ephys (m:n,q) >>'],'s');
                    if strcmp(in,'redraw')
                        figure(1300)
                        clf
                        plot(time,trace,'k'); hold on
                        temp = diff(get(gca,'YTick'));
                        h1 = plot(time,ephys*temp(1)+trace(1),'r');
                        h2 = plot(time,led*temp(1)*2+trace(1),'b');
                        xlabel('Time/ms');
                        ylabel('Membrane potential/mV');
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
                    assert(q==0 || q==1,'Quality value out of range (0-1).')
                    ephys(m/dt+1:n/dt+1)=q;
                    set(h1,'ydata',ephys*temp(1)+trace(1));
                end
                in='*';
                while ~isempty(in)
                    in = input([file_name ' LED (m:n,q) >>'],'s');
                    if strcmp(in,'redraw')
                        figure(1300)
                        clf
                        plot(time,trace,'k'); hold on
                        temp = diff(get(gca,'YTick'));
                        h1 = plot(time,ephys*temp(1)+trace(1),'r');
                        h2 = plot(time,led*temp(1)*2+trace(1),'b');
                        xlabel('Time/ms');
                        ylabel('Membrane potential/mV');
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
                    assert(q==0 || q==1,'Quality value out of range (0-1).')
                    led(m/dt+1:n/dt+1)=q;
                    set(h2,'ydata',led*temp(1)*2+trace(1));
                end
                % spike detection
                spkInd = patch.utils.spkDetect(time/1000,trace/1000);
                spks(spkInd)=1;
                for i = spkInd'
                    if trace(i)<-10
                        spks(i)=0;
                    end
                end
                spkInd = find(spks==1);
                
                
                h3 = plot(time(spkInd),trace(spkInd),'gx');
                in = '*';
                % manually check whether there are spikes missing
                while ~isempty(in)
                    spkInd*dt
                    in = input([file_name ' spike time(n)>>'],'s');
                    if strcmp(in,'redraw')
                        figure(1300)
                        clf
                        plot(time,trace,'k'); hold on
                        temp = diff(get(gca,'YTick'));
                        h1 = plot(time,ephys*temp(1)+trace(1),'r');
                        h2 = plot(time,led*temp(1)*2+trace(1),'b');
                        xlabel('Time/ms');
                        ylabel('Membrane potential/mV');
                        fillAxes;
                        linkAxes;
                        continue
                    end

                    if isempty(in)
                        continue
                    end
                    
                    n = strread(in,'%f');
                    q=1;
                    if n>time(end)
                        n=time(end);
                        warning('Setting stop at end of file');
                    end
                    spks(int16(n/dt)) = q;
                    spkInd = find(spks==1);
                    delete(h3);
                    h3 = plot(time(spkInd),trace(spkInd),'gx');
                end
                tuple.filename = file_name;
                tuple.dt = dt;
                tuple.time = time;
                tuple.trace = trace;
                tuple.ephys = ephys;
                tuple.led = led;
                tuple.baseline = mean(trace(1:100));
                tuple.spks = spks;
                self.insert(tuple);
                close all
            end
		
		end
	end

end