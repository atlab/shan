%{
info.RetinotopyMask (imported) # manually mark out the retinotopic related area and unrelated areas
-> info.Stitch
mask_id                : tinyint             # index of mask
-----
retin_mask             : longblob            # mask of the retinotopic related or unrelated area
related                : tinyint             # related or unrelated
quality                : tinyint             # quality of the stitch, 0-2

%}

classdef RetinotopyMask < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = info.Stitch & 'proj_id=1'
    end
    
    methods(Access=protected)
        
		function makeTuples(self, key)
			
            for ii = 1:4
                tuple = key;
                tuple.mask_id=ii;
                % show the plots of intrinsic imaging and stitching
                % fluorescence
                opt.plots.SpotMapMerge(['animal_id=' num2str(tuple.animal_id)]);
                info.plots.Stitch(0.99,tuple);

                tuple.retin_mask = [];
                tuple = info.utils.drawRetinMask(tuple);

                tuple.related = input('Please enter the related or not (1/0):');
                tuple.quality = input('Please enter the quality of the image (0-2):');
                self.insert(tuple)
                close all
            end
		end
	end

end