%{
info.StitchCheck (computed) # check whether tuples in StitchFile match that in StitchSession
-> info.StitchSession
-----
valid                  : tinyint         # 1 if stitch can be populated correctly

%}

classdef StitchCheck < dj.Relvar & dj.AutoPopulate
    properties(Constant)
		table = dj.Table('info.StitchCheck')
        popRel = info.StitchSession
    end
    
    methods(Access=protected)            
		function makeTuples(self, key)
            [row_num, column_num]=fetch1(info.StitchSession & key, 'row_num', 'column_num');
            key.valid = 1;
            for ii = 1:row_num
                for jj = 1:column_num
                    key_file = fetch(info.StitchFile & key & ['row_idx=' num2str(ii)] & ['column_idx=' num2str(jj)]);
                    if isempty(key_file)
                        key.valid = 0;
                        break
                    end
                end
                if key.valid==0
                    break
                end
            end
            self.insert(key)
		end
	end

end