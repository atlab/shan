%{
slicepatch.Cell (manual) # information of each patched cell in slice
-> slicepatch.Slice
cell_id                     : smallint    # 1 to 8
-----
cell_type_gene="Unknown"    : enum('Unknown','pyr','PV','SST','VIP','5HT')  # molecular marker of the cell
cell_type_morph="Unknown"   : enum('Unknown','pyr','BaC','ChC','BPC','BTC','MaC','SBC','DBC','NGC')     # morphological identity of the cell
cell_type_fp="Unknown"      : enum('Unknown','FS','RS','IRS')         # spiking property of the cell
cell_layer="Unknown"        : enum('Unknown','L1','L23','L4','L5','L6') # which layer the cell body is located
retinotopic_area=2          : tinyint                                 # 1 represents inside the retinopic area, 0 is not, 2 is unknown
cell_notes                  : varchar(4095)                           # other comments
cell_ts=CURRENT_TIMESTAMP   : timestamp                   # automatic
%}

classdef Cell < dj.Relvar

	properties(Constant)
		table = dj.Table('slicepatch.Cell')
	end
end
