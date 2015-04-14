%{
patch.Threshold (computed) # compute the spike threshold for each cell during one recording
->patch.Recording
-----
threshold      : double      # mean spiking threshold for the given recording set, in Volts
%}

classdef Threshold < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.Recording & patch.Spikes & (patch.Cell & 'patch_type="whole cell"');
    end
    methods(Access=protected)

		function makeTuples(self, key)
            
            spk_thresh = fetchn(patch.Spikes & key, 'spk_thresh');
            spk_thresh = spk_thresh(spk_thresh>quantile(spk_thresh,0.1) & spk_thresh<quantile(spk_thresh, 0.9));
            key.threshold = mean(spk_thresh)/1000;
            
            % case where there is no spike, threshold is defined as the max
            % of the whole trace
            if isempty(spk_thresh)
                vm = fetch1(patch.Ephys & key, 'vm');
                key.threshold = max(vm);
            end
			self.insert(key)
		end
	end

end