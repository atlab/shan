%{
slicepatch.CellSummaryNorm (computed) # my newest table
->slicepatch.CellSummary
-----
has_norm_epsc         : tinyint      # whether the cell has epsc that can be normalized to L23 pyramidal cells, vm = -70,-80,-85,-90
norm_epsc             : double       # EPSC normalized to L23 pyramidal cells
has_norm_ipsc         : tinyint      # whether the cell has inhibitory current that can be normailzed to L23 pyramidal cells, vm = 0
norm_ipsc             : double       # IPSC normalzied to L23 pyramidal cells
has_norm_epsp         : tinyint      # whether the cell has epsp that can be normalized to L23 pyramidal cells, vm = 70mV
norm_epsp             : double       # EPSP normalized to L23 pyramidal cells
%}

classdef CellSummaryNorm < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = slicepatch.CellSummary
    end
    
    
	methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
            
            % initialize all attributes
            tuple.has_norm_epsc = 0;
            tuple.norm_epsc = -1;
            tuple.has_norm_ipsc = 0;
            tuple.norm_ipsc = -1;
            tuple.has_norm_epsp = 0;
            tuple.norm_epsp = -1;
            
            % get L23 cells in the same slice
            
            keys_temp = fetch(slicepatch.Slice & key);
            keys_L23 = fetch(slicepatch.Cell & keys_temp & 'cell_type_morph="pyr"' & 'cell_layer="L23"');
            
            % Norm values
            
            keys_rel = fetch(slicepatch.CellSummary & key,'*');
            keys_L23_epsc = fetch(slicepatch.CellSummary & keys_L23 & 'res_epsc = 1','*');
          
            if ~isempty(keys_L23_epsc) && keys_rel.res_epsc~=-1
                tuple.has_norm_epsc = 1;
                mean_amp = keys_rel.epsc;
                mean_amp_L23 = mean([keys_L23_epsc.epsc]);
                tuple.norm_epsc = mean_amp/mean_amp_L23;
            end
            
            keys_L23_ipsc = fetch(slicepatch.CellSummary & keys_L23 & 'res_ipsc = 1','*');
            
            if ~isempty(keys_L23_ipsc) && keys_rel.res_ipsc~=-1
                tuple.has_norm_ipsc = 1;
                mean_amp = keys_rel.ipsc;
                mean_amp_L23 = mean([keys_L23_ipsc.ipsc]);
                tuple.norm_ipsc = mean_amp/mean_amp_L23;
            end
            
            keys_L23_epsp = fetch(slicepatch.CellSummary & keys_L23 & 'res_epsp = 1','*');
            
            if ~isempty(keys_L23_epsp) && keys_rel.res_epsp~=-1
                tuple.has_norm_epsp = 1;
                mean_amp = keys_rel.epsp;
                mean_amp_L23 = mean([keys_L23_epsp.epsp]);
                tuple.norm_epsp = mean_amp/mean_amp_L23;
            end
            
            self.insert(tuple)
		end
	end

end