%{
patch.OriVecOpto (computed) # compute the Vm mean, Vm sd, spk mean for each direction for each cell. rotate to the preferred orientation.
-> patch.OriTuningOpto
-----
oris            : blob      # directions
pref_dir_off    : double    # prefered direction for spike, circular weighted average
pref_dir_on     : double    # prefered direction for spike, with LED on
rot             : double    # rotation angle,0-360
vm_mean_off     : blob      # vm mean vector of all the directions
vm_mean_on      : blob      # vm mean vector of all the directions, with LED on
spk_mean_off    : blob      # mean spike count vector of all the directions
spk_mean_on     : blob      # mean spike count vector of all the directions, with LED on
vm_mean_cell_off: double    # mean of vm_mean across all directions
vm_mean_cell_on : double    # mean of vm_mean across all directions, with LED on
spk_mean_cell_off: double    # mean of spk count mean across all directions
spk_mean_cell_on : double    # mean of spk count mean across all directions, with LED on
%}

classdef OriVecOpto < dj.Relvar & dj.AutoPopulate
	properties
        popRel = patch.OriTuningOpto
    end
    
    methods(Access=protected)
        
		function makeTuples(self, key)
            
            % fetch data from table patch.OriTuningOpto
            data = fetch(patch.OriTuningOpto & key, '*');
                        
            key.oris = data.oris;
            oris = key.oris*pi/180;
            % values before rotation
            vm_mean_off = cellfun(@mean, data.vm_tuning_off)';
            vm_mean_on = cellfun(@mean, data.vm_tuning_on)';
            spk_mean_off = cellfun(@mean, data.spk_tuning_off)';
            spk_mean_on = cellfun(@mean, data.spk_tuning_on)';
            
            % caculate prefered direction
            pref_dir_off = atan2(sum(spk_mean_off.*abs(sin(oris))), sum(spk_mean_off.*abs(cos(oris))));
            pref_dir_on = atan2(sum(spk_mean_on.*abs(sin(oris))), sum(spk_mean_on.*abs(cos(oris))));
            
            if pref_dir_off<0
                pref_dir_off = pref_dir_off+2*pi;
            end
            if pref_dir_on<0
                pref_dir_on = pref_dir_on+2*pi;
            end
            
            idx_ref = interp1(oris, 1:length(oris), pref_dir_off, 'nearest', 'extrap');
            key.rot = oris(idx_ref);
            
            % rotate vm and spk vector
            key.vm_mean_off(1:length(oris)-idx_ref+1) = vm_mean_off(idx_ref:end);
            key.vm_mean_off(length(oris)-idx_ref+2:length(oris)) = vm_mean_off(1:idx_ref-1);
            key.vm_mean_on(1:length(oris)-idx_ref+1) = vm_mean_on(idx_ref:end);
            key.vm_mean_on(length(oris)-idx_ref+2:length(oris)) = vm_mean_on(1:idx_ref-1);
            key.spk_mean_off(1:length(oris)-idx_ref+1) = spk_mean_off(idx_ref:end);
            key.spk_mean_off(length(oris)-idx_ref+2:length(oris)) = spk_mean_off(1:idx_ref-1);
            key.spk_mean_on(1:length(oris)-idx_ref+1) = spk_mean_on(idx_ref:end);
            key.spk_mean_on(length(oris)-idx_ref+2:length(oris)) = spk_mean_on(1:idx_ref-1);
            
            key.pref_dir_on = pref_dir_on*180/pi;
            key.pref_dir_off = pref_dir_off*180/pi;
            key.vm_mean_cell_off = mean(vm_mean_off);
            key.vm_mean_cell_on = mean(vm_mean_on);
            key.spk_mean_cell_off = mean(spk_mean_off);
            key.spk_mean_cell_on = mean(spk_mean_on);
            if any(isnan(vm_mean_off))
                key.vm_mean_cell_off = 0;
            end
            if any(isnan(vm_mean_on))
                key.vm_mean_cell_on = 0;
            end
			self.insert(key)
		end
	end

end