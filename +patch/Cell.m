%{
patch.Cell (manual) # Cell patch recording$
-> patch.Patch
amp             : smallint              # 1 = NPI ELC-03XS, 2 = AxoClamp 2B
---
imp=0                       : int                           # impedance of pipette, in Mohm
patch_part="Unknown"        : enum('cell','dendrite','axon','Unknown')# putative cell part patched
patch_type="none"           : enum('whole cell','loose patch','none')# type of patch recording
cell_type_gene="none"       : enum('pyr','PV','SST','VIP','other','none')# Ai9 positive
label_confidence="N/A"      : enum('high','medium','low','N/A')# Confidence that cell is labeled
cell_type_fp="none"         : enum('RS','FS','IRS','other','none')# post-hoc characterization of firing pattern (fast spiking or regular spiking)
cell_type_morph="Unknown"   : enum('Unknown','pyr','BaC','ChC','BPC','BTC','MaC','SBC','DBC','NGC')# morphological identity of the cell
retinotopic_area=2          : tinyint                       # 1 represents inside the retinopic area, 0 is not, 2 is unknown
depth=0                     : int                           # depth of patched cell
cell_layer="Unknown"        : enum('Unknown','L1','L23','L4','L5','L6')# which layer the cell body is located
has_stack                   : tinyint                       # true if the files with this basename have an associated 2P stack of the patched cells
has_fp                      : tinyint                       # true if the files with this basename have an associated firing pattern file
cell_notes                  : varchar(4095)                 # free-text notes
cell_ts=CURRENT_TIMESTAMP   : timestamp                     # automatic
%}

classdef Cell < dj.Relvar

end
