%{
info.RetinotopyMask (imported) # manually mark out the retinotopic related area and unrelated areas
-> info.Stitch
mask_id                : tinyint             # index of mask
-----
retin_mask             : longblob            # mask of the retinotopic related or unrelated area
related                : tinyint             # related or unrelated
bg_mask                : longblob            # mask of background area, as reference
quality                : tinyint             # quality of the stitch, 0-2

%}

classdef RetinotopyMask < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = info.Stitch & 'proj_id=1'
    end
    
    methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            opt.plots.SpotMapMerge(['animal_id=' num2str(key.animal_id)]);
            info.plots.Stitch(0.99,'green', key);
            tuple_bg = key;
            tuple_bg.retin_mask = [];
            tuple_bg = info.utils.drawRetinMask(tuple_bg);
			tuple.bg_mask = tuple_bg.retin_mask;
            
            for ii = 1:4
                tuple.mask_id=ii;
                % show the plots of intrinsic imaging and stitching
                % fluorescence
                info.plots.Stitch(0.99,'red',tuple);

                tuple.retin_mask = [];
                tuple = info.utils.drawRetinMask(tuple);

                tuple.related = input('Please enter the related or not (1/0):');
                tuple.quality = input('Please enter the quality of the image (0-2):');
                self.insert(tuple)
            end
            close all
		end
	end

end