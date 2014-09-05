%{
connectivity.Distance (computed) # my newest table
-> connectivity.CellTestedPair
-----
distance:   double             # Euclidean distances between the cell pairs
dist_x  :   double             # distance in x coordinate
dist_y  :   double             # distance in y coordinate
%}

classdef Distance < dj.Relvar & dj.AutoPopulate
	properties
        popRel = connectivity.CellTestedPair & connectivity.CellPosition
    end
    
    methods(Access=protected)

		function makeTuples(self, key)
            % fetch cell pairs
            key_pair = fetch(connectivity.CellTestedPair & key);
            
            key_cell_from = fetch(connectivity.ConnectMembership & key_pair & 'role="from"');
            key_cell_to = fetch(connectivity.ConnectMembership & key_pair & 'role="to"');
            
            if ~isempty(key_cell_from) && ~isempty(key_cell_to)            
                [x1,y1] = fetch1(connectivity.CellPosition & key_cell_from, 'cell_pos_x', 'cell_pos_y');
                [x2,y2] = fetch1(connectivity.CellPosition & key_cell_to, 'cell_pos_x', 'cell_pos_y');
            else
                keys = fetch(connectivity.ConnectMembership & key_pair & 'role="EC"');
                if length(keys)~=2
                    assert('Connection is not complete!');
                else
                   	[x1,y1] = fetch1(connectivity.CellPosition & keys(1), 'cell_pos_x', 'cell_pos_y');
                    [x2,y2] = fetch1(connectivity.CellPosition & keys(2), 'cell_pos_x', 'cell_pos_y');
                end
            end
            
            
            % compute distances
            key.dist_x = abs(x2-x1);
            key.dist_y = abs(y2-y1);
            key.distance = sqrt((y2-y1)^2+(x2-x1)^2);
            
            self.insert(key)
		end
	end

end