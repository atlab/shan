%{
info.Stack2Img (imported) # convert stack into img for scanimage4
-> info.Stack
-> info.ProjOpt
-----
red_img          :longblob     # image matrix in red channel
green_img        :longblob     # image matrix in green channel. If the channel was not saved, the field will be a zero matrix
red_channel      :tinyint      # 1 indicates red channel exists
green_channel    :tinyint      # 1 indicates green channel exists
size             :tinyblob     # image size, height*width

%}

classdef Stack2Img < dj.Relvar & dj.AutoPopulate
	
    properties(Constant)
        table = dj.Table('info.Stack2Img')
        popRel = info.Stack * info.ProjOpt 
    end
    methods(Access=protected)

		function makeTuples(self, key)
            tic
            file = fetch(info.Stack & key,'*');
            toc
            if length(file.size)==4
                if file.green_channel
                    file.green_mat = squeeze(mean(file.green_mat,4));
                end
                if file.red_channel
                    file.red_mat = squeeze(mean(file.red_mat,4));
                end
            end
            % convert the image
            switch key.proj_id
                case 1
                    if file.green_channel
                        green_proj = squeeze(max(file.green_mat,[],3));
                        key.green_img = fliplr(rot90(green_proj));           
                    end
                    if file.red_channel
                        red_proj = squeeze(max(file.red_mat,[],3));
                        key.red_img = fliplr(rot90(red_proj));               
                    end
                case 2
                    if file.green_channel
                        green_proj = squeeze(mean(file.green_mat,3));
                        key.green_img = fliplr(rot90(green_proj));
                    end
                    if file.red_channel
                        red_proj = squeeze(mean(file.red_mat,3));
                        key.red_img = fliplr(rot90(red_proj));
                    end     
            end
            key.red_channel = file.red_channel;
            key.green_channel = file.green_channel;
            key.size = file.size(1:2);
            toc
            self.insert(key)
            
		end
	end

end