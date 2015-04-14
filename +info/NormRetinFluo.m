%{
info.NormRetinFluo (computed) # fluroscence normalized to mean of the retinotopic area
-> info.StitchSession
-----
mean_rel_norm        : double      # mean of fluorescence of reitinotopically related area, nomalized to the mean of background
mean_unrel_norm      : double      # mean of fluorescence of non-retinotopically related area, normalized the mean of background
mean_rel             : double      # mean of fluorescence of retinotopically related area
mean_unrel           : double      # mean of fluorescence of retinotopically unrelated area
rel_norm             : longblob    # normalized fluorescence of retinotopically related area, normalized to the mean of background
unrel_norm           : longblob    # normalized fluorescence of retinotopically related area, normalized to the mean of background

%}

classdef NormRetinFluo < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = info.StitchSession & (info.RetinotopyMask & 'quality>0')
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
			
            tuple = key;
            key_rel = fetch(info.RetinotopyMask & key & 'related=1');
            key_unrel = fetch(info.RetinotopyMask & key & 'related=0');
            [fluo_rel,bg] = fetch1(info.Extract & key_rel, 'fluo_values','bg_values');
            fluo_unrel = fetchn(info.Extract & key_unrel, 'fluo_values');
            
            mean_rel = mean(fluo_rel);
            mean_unrel = mean(cell2mat(fluo_unrel));
            
            tuple.mean_rel = mean_rel;
            tuple.mean_unrel = mean_unrel;
            tuple.rel_norm = fluo_rel/mean(bg);
            tuple.unrel_norm = cell2mat(fluo_unrel)/mean(bg);
            tuple.mean_rel_norm = mean_rel/mean(bg);
            tuple.mean_unrel_norm = mean_unrel/mean(bg);
            
            self.insert(tuple)
		end
	end

end