%{
patch.Led (imported) # Led pulses
-> patch.Recording
led_ind :         int               # led pulse index
-----
led_on :                float                   # pulse start time (sec)
led_dur :               decimal(6,3)            # pulse duration (sec)
led_ts = CURRENT_TIMESTAMP : timestamp          # automatic
%}

classdef Led < dj.Relvar

    methods
        function makeTuples(self, key, led, ts, ver)
            tuple = key;
            
            % identify direction of peak
            base = sum(led<0.1);
            peak = sum(led>4.9);
            
            if base>peak
                onInd = find(diff(led)>3);
                offInd = find(diff(led)<-3);
            else
                onInd = find(diff(led)<-3);
                offInd = find(diff(led)>3);
            end
            
            if length(onInd)>length(offInd)
                N = length(onInd)-length(offInd);
                if N > 1
                    error(['Missing ' num2str(N) ' LED offsets']);
                else
                    warning('Missing one LED offset, removing last onset.');
                    onInd(end)=[];
                end
            end
            if length(offInd)>length(onInd)
                N = length(offInd)-length(onInd);
                if N > 1
                    % check whether LED signal is ramp
                    type = fetch1(patch.RecordingNote & key, 'led_type');
                    if strcmp(type,'ramp')
                        offInd1 = offInd(1);
                        led1 = led(1:offInd(1));
                        onInd1 = min(find(led1>0.001));
                        len = offInd1-onInd1;
                        onInd = offInd - len;
                    else
                        error(['Missing ' num2str(N) ' LED onsets']);
                    end
                else
                    warning('Missing one LED onset, removing first offset.');
                    offInd(1)=[];
                end
            end
            
            if ~all(offInd-onInd>0)
                tuple
                error('Found LED off before LED on.')
            end
            
            for i=1:length(onInd)
                tuple.led_ind = i;
                tuple.led_on = ts(onInd(i));
                dur = ts(offInd(i)) - ts(onInd(i));
                % round to nearest ms
                dur = round(dur*1000)/1000;
                tuple.led_dur = dur;
                self.insert(tuple);
            end
        end
    end
end



