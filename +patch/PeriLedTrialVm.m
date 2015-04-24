%{
patch.PeriLedTrialVm (computed) # this table computes Vm relative to the visual stimuli onset
-> patch.PeriLedTrial
-----
peri_led_vm_vis_onset : double  # vm baseline at the visual stimulus onset
peri_led_vm_norm_vis:  longblob    # vm extracted baseline at visual stimulus onset
peri_led_stat   :  tinyint     # status of led, on or off
peri_led_time   :  longblob    # new time, 0 for LED starting point, in sec
peri_led_mean_vel : double     # mean velocity of the ball during this trial

%}

classdef PeriLedTrialVm < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.PeriLedTrial
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
            [vm, time, delay, mean_vel, stat] = fetch1(patch.PeriLedTrial & key, 'peri_led_vm','peri_led_time','peri_led_delay','peri_led_mean_vel','peri_led_stat');
            time_onset = -delay;
            vm_vis_onset = mean(vm(abs(time-time_onset)<1e-4));
            
            vm_norm = vm - vm_vis_onset;
            
            key.peri_led_vm_vis_onset = vm_vis_onset;
            key.peri_led_vm_norm_vis = vm_norm;
            key.peri_led_stat = stat;
            key.peri_led_time = time;
            key.peri_led_mean_vel = mean_vel;
            
			self.insert(key)
		end
	end

end