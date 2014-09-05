%{
slicepatch.PeriLedOff (computed) # Cut the trace around the persumable LED stimulation, for comparison
-> slicepatch.Firing
-----
peri_led_win :      tinyblob    # positive peri window durations [w1 w2](-w1:+w2) in ms
peri_led_spk :      longblob    # binary spike train around led onset
peri_led_led :      longblob    # persumable binary time series indicating led status: 1 = led on, 0 = led off
peri_led_time:      longblob    # new time, 0 for LED starting point, in ms
peri_led_on_time:   double      # absolute time of led on, in ms
peri_led_dur :      double      # duration of LED stimulation, in ms
peri_led_delay:     double      # delay time between LED and ephys, in ms
%}

classdef PeriLedOff < dj.Relvar & dj.AutoPopulate
    properties
        popRel = slicepatch.Firing & 'led_stat=0'
    end
	methods(Access=protected)

		function makeTuples(self, key)
			trace = fetch(slicepatch.Firing & key, '*');
            led_on_idx = find(diff(trace.led)==1);
            led_on_time = trace.time(led_on_idx);
            led_off_idx = find(diff(trace.led)==-1);
            led_off_time = trace.time(led_off_idx);
            led_dur = led_off_time - led_on_time;
            
            ephys_on_idx = find(diff(trace.ephys)==1);
            ephys_on_time = trace.time(ephys_on_idx);
            ephys_off_idx = find(diff(trace.ephys)==-1);
            ephys_off_time = trace.time(ephys_off_idx);
            w1 = led_on_time - ephys_on_time;
            w2 = ephys_off_time - led_on_time;
            
            key.peri_led_time = trace.time(ephys_on_idx+1:ephys_off_idx)-led_on_time;
            key.peri_led_spk = trace.spks(ephys_on_idx+1:ephys_off_idx);
            key.peri_led_led = trace.led(ephys_on_idx+1:ephys_off_idx);
            key.peri_led_win = [w1,w2];
            key.peri_led_on_time = led_on_time;
            key.peri_led_dur = led_dur;
            key.peri_led_delay = w1;
            self.insert(key)
		end
	end

end