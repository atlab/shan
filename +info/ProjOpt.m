%{
info.ProjOpt (lookup) # projection option of stack data 
proj_id         :tinyint    # projection option number
-----
proj_opt        :enum('max','mean')  # comment
%}

classdef ProjOpt < dj.Relvar
    properties(Constant)
		table = dj.Table('tp.CaOpt')
	end

	methods        
        function fill(self)
            tuples = cell2struct({
                1   'max'
                2   'mean'
            }', {'proj_id', 'proj_opt'});
            self.insert(tuples,'INSERT IGNORE')
            
        end            
	end
end