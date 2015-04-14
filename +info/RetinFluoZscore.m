%{
info.RetinFluoZscore (computed) # compute the z scores of each pixel
-> info.StitchSession
-----
bg_mean              : double      # mean of background
bg_std               : double      # standard deviation of background
z_score_rel          : longblob    # z scores of each pixel of retinotopically related area, relative to background
mean_rel             : double      # mean of the z scores of retinotopically related area
var_rel              : double      # variance of z scores of retinotopically related area
z_score_unrel        : longblob    # z scores of each pixel of retinotopically unrelated area
mean_unrel           : double      # mean of the z scores of all retinotopically unrelated area
var_unrel            : double      # variance of z scores of retinotopically unrelated area

%}

classdef RetinFluoZscore < dj.Relvar & dj.AutoPopulate
    
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
            
            bg_mean = mean(bg);
            bg_std = std(bg);
            z_score_rel = (fluo_rel-bg_mean)/bg_std;
            mean_rel = mean(z_score_rel);
            var_rel = var(z_score_rel);
            
            fluo_unrel = cell2mat(fluo_unrel);
            
            z_score_unrel = (fluo_unrel-bg_mean)/bg_std;
            mean_unrel = mean(z_score_unrel);
            var_unrel = var(z_score_unrel);
            
            tuple.bg_mean = bg_mean;
            tuple.bg_std = bg_std;
            tuple.z_score_rel = z_score_rel;
            tuple.mean_rel = mean_rel;
            tuple.var_rel = var_rel;
            tuple.z_score_unrel = z_score_unrel;
            tuple.mean_unrel = mean_unrel;
            tuple.var_unrel = var_unrel;
           
            self.insert(tuple)
		end
	end

end