%{
patch.PeriLedTrialVm (computed) # this table compute the mean Vm for both excitation window 0-40ms and inhibition window 40-150ms
-> patch.PeriLedTrial
-----
peri_led_time     :  longblob     # 0 for LED onset, in sec, inherit from table patch.PeriLedTrial
peri_led_win_exc  :  tinyblob     # time window or excitation, [0,0.04]
peri_led_win_inh  :  tinyblob     # time window for inhibition, [0.04,0.15]
peri_led_vm_exc   :  double       # mean vm during the excitation window,in Volts
peri_led_vm_inh   :  double       # mean vm during the inhibition window in Volts

%}

classdef PeriLedTrialVm < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.PeriLedTrial
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
            [vm, time] = fetch1(patch.PeriLedTrial & key, 'peri_led_vm_norm','peri_led_time');
            
            key.peri_led_time = time;
            key.peri_led_win_exc = [0,0.04];
            key.peri_led_win_inh = [0.04,0.15];
            key.peri_led_vm_exc = mean(vm(time<0.04 & time>0));
            key.peri_led_vm_inh = mean(vm(time>0.04 & time<0.15));
            
			self.insert(key)
		end
	end

end