function EIRatioScatter(varargin)
% Scatter plot of normalized IPSC against EPSC
%   SS 14-08-05

cells_rel = fetch(slicepatch.Cell & 'animal_id!=3024' & varargin);
cell_res = fetch(slicepatch.CellSummary & cells_rel & 'has_eiratio=1', '*');

epsc = [cell_res.norm_epsc];
ipsc = [cell_res.norm_ipsc];

figure; scatter(epsc,ipsc)