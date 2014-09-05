%{
info.Infection (imported) # infection image taken with CCD camera
->info.ProcedureFile
-----
img  :  longblob    # image for infection
%}

classdef Infection < dj.Relvar & dj.AutoPopulate

	properties(Constant)
		table = dj.Table('info.Infection')
        popRel = info.ProcedureFile & 'img_type="CCD"' & 'material_type="in vivo"'
    end
    
    methods
		function self = Infection(varargin)
			self.restrict(varargin)
		end
    end
    
	methods(Access=protected)
        
		function makeTuples(self, key)
			filename = fullfile(...
                fetch1(info.ProcedureSession & key, 'proc_path'),...
                fetch1(info.ProcedureFile & key, 'filename'));
            X = opt.utils.getOpticalData(getLocalPath(filename));
            X = squeeze(median(X));
            X = X-quantile(X(:),0.005);
            X = X/quantile(X(:),0.999);
            key.img = uint8(255*X); 
			self.insert(key)
		end
	end
end
