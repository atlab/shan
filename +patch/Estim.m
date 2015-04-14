%{
patch.Estim (imported) # Current injection pulses
-> patch.Recording
-> patch.Cell
estim_ind                   : int                   # estim pulse or burst index
-----
estim_on                    : float                 # pulse or burst start time (sec)
estim_dur                   : decimal(6,3)          # total duration of pulse or burst (sec)
estim_max_current           : float                 # max current in pulse (nA)
estim_isburst               : boolean               # true if this stimulation pulse is a burst
estim_burst_freq = NULL     : int                   # frequency of pulses in the burst (Hz)
estim_burst_dur = NULL      : decimal(6,4)          # duration of each pulse in the burst (sec)
estim_burst_count = NULL    : int                   # number of pulses in the burst
estim_segment               : mediumblob            # (1,:) = pulse current (2,:) = pulse voltage
estim_spike_count           : int                   # number of detected spikes during total pulse or burst (only reliable for larger segments)
estim_ts = CURRENT_TIMESTAMP : timestamp            # automatic
%}

classdef Estim < dj.Relvar
    
    properties(Constant)
        table = dj.Table('patch.Estim');
    end
    
    methods
        function makeTuples(self, key, I, V, ts)
            
            diffI = diff(I);
            thresh = 6*std(diffI);
            fs = 1/median(diff(ts));
            burstWin = 1/10; % 10Hz
            
            % find onsets and offsets of current pulses
            onInd = find(diffI>thresh);
            offInd = find(diffI<-thresh);
            
            % remove sequential samples
            onInd(diff(onInd)==1)=[];
            offInd(diff(offInd)==1)=[];
            
            % make sure we still have some
            if isempty(offInd) || isempty(onInd)
                return
            end
            
            % remove any preceeding offs
            while ~isempty(offInd) && offInd(1) < onInd(1)
                offInd(1)=[];
            end
            
            % make sure we still have some
            if isempty(offInd)
                return
            end
            
            % only keep matched offs and ons
            k=1;on=[];off=[];
            for i=1:length(onInd)
                if i<length(onInd)
                    next = onInd(i+1);
                else
                    next = length(diffI);
                end
                offs = offInd(offInd > onInd(i) & offInd < next);
                if length(offs) == 1
                    on(k) = onInd(i);
                    off(k) = offs;
                    k=k+1;
                elseif length(offs) > 1
                    on(k) = onInd(i);
                    off(k) = offs(1);
                    k=k+1;
                end
            end
            
            % remove any offs and ons separated by less than 1ms
            shorts = find(ts(off)-ts(on)<.001);
            on(shorts)=[];
            off(shorts)=[];
            
            if isempty(on)
                return
            end
            
            %% burst detection
            % also collect segments where current is high for spike detection and max current calc
            i=1;
            segPad = 2; % number of indices on either side to ignore while collecting segments
            clear isBurst burstCount burstDur burstFreq segI segV
            while i<=length(on)-1
                % check if next pulse is within burstWin
                % also check that first and second pulse are same length (i.e. the difference is within 5% of the mean)
                if ts(on(i+1))-ts(on(i)) < burstWin && abs((ts(off(i+1))-ts(on(i+1))) - (ts(off(i))-ts(on(i)))) <...
                        .05 * mean([(ts(off(i+1))-ts(on(i+1))) (ts(off(i))-ts(on(i)))])
                    isBurst(i) = 1;
                    burstCount(i) = 1;
                    burstDur(i) = round((ts(off(i))-ts(on(i)))*1000)/1000;
                    burstFreq(i) = round(1/(ts(on(i+1))-ts(on(i))));
                    segI{i}=[I(on(i)+segPad:off(i)-segPad)];
                    segV{i}=[V(on(i)+segPad:off(i)-segPad)];
                    while i<=length(on)-1 && (ts(on(i+1))-ts(on(i)) < burstWin)
                        if isBurst(i)
                            burstCount(i) = burstCount(i)+1;
                        end
                        segI{i}=[segI{i};I(on(i+1)+segPad:off(i+1)-segPad)];
                        segV{i}=[segV{i};V(on(i+1)+segPad:off(i+1)-segPad)];
                        off(i)=[];
                        on(i+1)=[];
                    end
                    % otherwise treat as individual
                else
                    isBurst(i) = 0;
                    burstCount(i) = nan;
                    burstDur(i) = nan;
                    burstFreq(i) = nan;
                    segI{i} = I(on(i)+segPad:off(i)-segPad);
                    segV{i} = V(on(i)+segPad:off(i)-segPad);
                end
                i = i+1;
            end
            
            % if there's only one pulse total or last pulse is not a burst, check for one more individual pulse
            if ~exist('isBurst') || (~isBurst(end) && length(isBurst) < length(on))
                isBurst(i) = 0;
                burstCount(i) = nan;
                burstDur(i) = nan;
                burstFreq(i) = nan;
                segI{i} = I(on(i)+segPad:off(i)-segPad);
                segV{i} = V(on(i)+segPad:off(i)-segPad);
            end
            
            %% spike detection
            spkCount=zeros(size(on));
            for i=1:length(segV)
                len=length(segV{i});
                if len/fs > 0.019 %(at least ~20ms segment)
                    x=segV{i};
                    if isBurst(i)
                        x=diff(diff(x));
                        [~,m]=sort(x);
                        m=m(1:burstCount(i)-1);
                        m=bsxfun(@plus,m,[-2:3]); 
                        m=sort(m(:));
                        m(m<1 | m>length(x))=[];
                        x(m)=[];
                        x = find(x>.003 | x>std(x)*5);
                    else
                        y=x;
                        while abs(diff(y(1:2)))-median(diff(y)) > 2*std(diff(y)) && length(y) > len-100
                           y(1)=[];
                        end
                        y = ezfilt(y,150,fs,'high');
                        x=diff(diff(x));
                        len = min([length(x) length(y)]);
                        x=x(end-len+1:end);
                        y=y(end-len+1:end);
                        x = find(x>.004 | x>std(x)*5 | y>.004 | y>std(y)*5);
                    end
                    
                    x(diff(x)==1)=[];
                    spkCount(i) = length(x);
                end
            end
            
            %% insert tuples
            for i=1:length(on)
                tuple=key;
                tuple.estim_ind = i;
                tuple.estim_on = ts(on(i));
                tuple.estim_dur = round((ts(off(i))-ts(on(i)))*1000)/1000;
                tuple.estim_max_current = max(segI{i});
                tuple.estim_isburst = isBurst(i);
                tuple.estim_burst_freq = burstFreq(i);
                tuple.estim_burst_dur = burstDur(i);
                tuple.estim_burst_count = burstCount(i);
                tuple.estim_segment = [segI{i}  segV{i}]';
                tuple.estim_spike_count = spkCount(i);

                self.insert(tuple);
            end
            
        end
    end
end



