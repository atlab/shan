%{
patch.SpikeProb (computed) # my newest table
-> patch.PeriLedTrial
-----
spk_prob     : blob         # spike or not during 0-10ms,10-20ms...
spk_num      : blob         # spike number during the time period
firing_rate  : blob         # firing rate during the time period
vm_to_thresh : double       # vm relative to threshold at the led onset
time_range   : blob         # time ranges for spk counting
%}

classdef SpikeProb < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.PeriLedTrial
    end
    
    methods(Access=protected)
        
		function makeTuples(self, key)
            
            [time, spk, vm_to_thresh] = fetch1(patch.PeriLedTrial & key, 'peri_led_time','peri_led_spk','peri_led_vm_to_thresh');
            time_range = linspace(0,0.1,11);
            spk_prob = zeros(1,length(time_range)-1);
            spk_num = zeros(1,length(spk_prob));
            firing_rate = zeros(1,length(spk_prob));
            for ii = 1:length(spk_prob)
                idx_rel = time<time_range(ii+1) & time>time_range(ii);
                spk_prob(ii) = logical(sum(spk(idx_rel)));
                spk_num(ii) = sum(spk(idx_rel));
                firing_rate = spk_num/(time_range(2)-time_range(1));
            end
            key.spk_prob = spk_prob;
            key.spk_num = spk_num;
            key.firing_rate = firing_rate;
            key.vm_to_thresh = vm_to_thresh;
            key.time_range = time_range;
            
			self.insert(key)
		end
	end

end