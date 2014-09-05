%{
info.Extract (computed) # extract the fluorescence strength with the mask
-> info.RetinotopyMask
-----
vessel_correction       : tinyint     # have excluded vessels if red channel exists
fluo_values             : longblob    # extracted values inside the mask

%}

classdef Extract < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = info.RetinotopyMask
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
            tuple.vessel_correction = 0;
            % load the data of image
            img_key = fetch(info.Stitch & key, '*');
            
            img_green = img_key.img_green;
            
            % load mask
            mask = fetch1(info.RetinotopyMask & key,'retin_mask');
            values_rel = img_green.*double(mask);
            
            % remove pixles in the vessels if red channel exists
            if img_key.red_channel
                img_red = img_key.img_red;
                tuple.vessel_correction = 1;
                mask2 = img_red>quantile(img_red(:),0.5);
            end
            
            values_rel = values_rel.*mask2;
            values_rel = values_rel(:);
            values_rel = values_rel(values_rel~=0);
            tuple.fluo_values = values_rel;
            
			self.insert(tuple)
		end
	end

end