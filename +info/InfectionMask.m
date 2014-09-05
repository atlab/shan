%{
info.InfectionMask (imported) # mask of the craniotomy
-> info.ProcedureFile
-----
structure_mask  : longblob   # mask of hte craniotomy
%}

classdef InfectionMask < dj.Relvar & dj.AutoPopulate

	properties(Constant)
		table = dj.Table('info.InfectionMask')
        popRel = info.Infection
    end
    
    methods
		function self = InfectionMask(varargin)
			self.restrict(varargin)
        end
	end 

	methods(Access=protected)
		function makeTuples(self, key)
            structImg=fetchn(info.Infection(key),'img');
            structImg=double(structImg{end});
            h = imagesc(structImg); colormap('gray');
            axis image
            set(gca,'xdir','reverse')
            key.structure_mask=[];
            key=opt.utils.drawOptMask(key);
			self.insert(key)
		end
	end
end
