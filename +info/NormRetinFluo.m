%{
info.NormRetinFluo (computed) # fluroscence normalized to mean of the retinotopic area
-> info.StitchSession
-----
unrel_norm      : double      # mean of fluorescence of non-retinotopically related area, normalized to that of the retinotopically related area
mean_rel        : double      # mean of fluorescence of retinotopically related area
mean_unrel      : double      # mean of fluorescence of retinotopically unrelated area

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
            fluo_rel = fetch1(info.Extract & key_rel, 'fluo_values');
            fluo_unrel = fetchn(info.Extract & key_unrel, 'fluo_values');
            
            mean_rel = mean(fluo_rel);
            mean_unrel = mean(cell2mat(fluo_unrel));
            
            tuple.mean_rel = mean_rel;
            tuple.mean_unrel = mean_unrel;
            tuple.unrel_norm = mean_unrel/mean_rel;
            
            self.insert(tuple)
		end
	end

end