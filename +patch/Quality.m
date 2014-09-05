%{
patch.Quality (manual) # manual description of recording quality
-> patch.Recording
-> patch.Cell
-----
quality                         : mediumblob    # vector of recording quality at 1 second resolution.
max_q                           : int           # max quality for this recording
quality_ts = CURRENT_TIMESTAMP  : timestamp     # automatic
%}

% 3: figure-quality data
% 2: useful for analysis
% 1: very poor, but potentially interesting for pilot analysis, etc.
% 0: exclude

classdef Quality < dj.Relvar & dj.AutoPopulate
    
    
    properties

        popRel = patch.Ephys;
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            [i,v,t] = fetch1(patch.Ephys & key,'current','vm','ephys_time');
            dt = mean(diff(t));
            fs = 1/dt;
            
            tuple = key;
            
            in = '*';
            
            figure(1300)
            h(1)=subplot(511);
            plot(t,i);
            legend('Current')
            h(2)=subplot(512);
            plot(t,v);
            legend('Vm')
            h(3)=subplot(513);
            plot(t,ezfilt(v,.5,fs,'low'));
            legend('Lowpass Vm')
            h(4) = subplot(514);
            plot(t,ezfilt(v,150,fs,'high'));
            legend('Highpass Vm')
            h(5)=subplot(515);
            tq = unique(floor(t));
            quality = zeros(size(tq));
            hq = plot(tq,quality,'linewidth',3);
            legend('Quality')
            set(gca,'ylim',[-0.5 3.5],'ytick',[0 1 2 3])
            fillAxes;
            linkAxes;
            
            
            while ~isempty(in)
                in = input('Quality (m:n,q) >>','s');
                if strcmp(in,'redraw')
                    figure(1300)
                    clf
                    h(1)=subplot(511);
                    plot(t,i);
                    legend('Current')
                    h(2)=subplot(512);
                    plot(t,v);
                    legend('Vm')
                    h(3)=subplot(513);
                    plot(t,ezfilt(v,.5,fs,'low'));
                    legend('Lowpass Vm')
                    h(4) = subplot(514);
                    plot(t,ezfilt(v,150,fs,'high'));
                    legend('Highpass Vm')
                    h(5)=subplot(515);
                    tq = unique(floor(t));
                    quality = zeros(size(tq));
                    hq = plot(tq,quality,'linewidth',3);
                    legend('Quality')
                    set(gca,'ylim',[-0.5 3.5],'ytick',[0 1 2 3])
                    fillAxes;
                    linkAxes;
                    continue
                end
                
                if isempty(in)
                    continue
                end
                [m,n,q] = strread(in,'%d:%d,%d');
                assert(m>=0 && m<length(quality)-1,'Start value out of range.')
                assert(n>m,'Stop value must be greater than start value.')
                if n>length(quality)-1
                    n=length(quality)-1;
                    warning('Setting stop at end of file');
                end
                assert(q>=0 && q<=3,'Quality value out of range (0-3).')
                quality(m+1:n+1)=q;
                set(hq,'ydata',quality);
            end
            tuple.quality = quality;
            tuple.max_q = max(quality);
            self.insert(tuple);
            delete(1300);
        end
    end
end
