cell_res = fetch(slicepatch.Cell & 'cell_layer="L23"' & 'cell_type_morph="pyr"');

cells = fetch(slicepatch.CellSummary & 'has_norm_epsp=1' & cell_res);

slices = fetch(slicepatch.Slice & cells);

for iSlice = slices'
    cells = fetch(slicepatch.CellSummary & iSlice & cell_res,'*');
    
end