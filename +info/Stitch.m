%{
info.Stitch (computed) # stitch subplots together
-> info.StitchSession
-> info.ProjOpt
-----
img_green            :longblob         # image in the green channel after stitching
img_red              :longblob         # image in the red channel after stitching
green_channel        :tinyint          # 1 indicates the existence of the channel 
red_channel          :tinyint          # 1 indicates the existence of the channel

%}

classdef Stitch < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('info.Stitch')
        popRel = info.StitchCheck*info.ProjOpt & 'valid=1'
    end
    
    methods(Access=protected)
		function makeTuples(self, key)
            file_keys = fetch(info.Stack2Img & key);
            file = fetch(info.Stack2Img & file_keys(1), '*');
            key.red_channel = file.red_channel;
            key.green_channel = file.green_channel;
            [row_num,column_num] = fetch1(info.StitchSession & key, 'row_num', 'column_num');
            img_g = zeros(file.size(1)*row_num,file.size(2)*column_num);
            img_r = zeros(size(img_g));
            for iKey = file_keys(:)'
                file = fetch(info.Stack2Img & iKey, '*');
                sz = file.size;
                [row_idx,column_idx] = fetch1(info.StitchFile & iKey,'row_idx','column_idx');
                if file.green_channel
                    img_g((row_idx-1)*sz(1)+1:row_idx*sz(1),(column_idx-1)*sz(2)+1:column_idx*sz(2)) = ...
                    file.green_img;
                end
                if file.red_channel
                    img_r((row_idx-1)*sz(1)+1:row_idx*sz(1),(column_idx-1)*sz(2)+1:column_idx*sz(2)) = ...
                    file.red_img;
                end
            end
            key.img_green = img_g;
            key.img_red = img_r;
            self.insert(key)
		end
	end

end