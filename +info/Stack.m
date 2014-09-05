%{
info.Stack (imported) # extract the stack matrix from the tiff file
-> info.StitchFile
-----
red_mat          :longblob     # stack matrix in red channel
green_mat        :longblob     # stack matrix in green channel. If the channel was not saved, the field will be a zero matrix
red_channel      :tinyint      # 1 indicates red channel exists
green_channel    :tinyint      # 1 indicates green channel exists
size             :tinyblob     # image size, height*width*nSlices

%}

classdef Stack < dj.Relvar & dj.AutoPopulate
	
    properties(Constant)
        table = dj.Table('info.Stack2Img')
        popRel = info.StitchFile 
    end
    methods(Access=protected)

		function makeTuples(self, key)
            filepath = [getLocalPath(fetch1(info.StitchSession & key, 'proc_path')) fetch1(info.StitchSession & key, 'file_base') '_' fetch1(info.StitchFile & key, 'file_extension') '.tif'];
            file = reso.reader(filepath);
            block = file.read(file.channels,1:file.nSlices,1);
            key.red_channel=0; key.green_channel=0;
            
            if ismember(1,file.channels)
                key.green_channel = 1;
                key.green_mat = block.channel1;
                key.size = size(key.green_mat);
            else
                key.green_mat = 0;
            end
            if ismember(2,file.channels)
                key.red_channel = 1;
                key.red_mat = block.channel2;
                key.size = size(key.red_mat);
            else
                key.red_mat = 0;
            end
            
            self.insert(key)
            
		end
	end

end