%{
patch.LedSet (imported) # overall LED trace
-> patch.Recording
-----
led_trace :             longblob                # pulse start time (sec)
led_time  :             longblob                # time stamp, same as ephys time
%}

classdef LedSet < dj.Relvar

    methods
        function makeTuples(self, key, led, ts)
                tuple = key;
                tuple.led_trace = led;
                tuple.led_time = ts;
                self.insert(tuple);

        end
    end
end


