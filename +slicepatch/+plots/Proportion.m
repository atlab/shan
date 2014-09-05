function Proportion(act_type)
%Proportion of cells that are activated by feedback activation
% pyramidal cells, PV cells, SST cells and VIP cells, L23, L4, L5

layers = {'L23', 'L4', 'L5'};
types = {'pyr', 'PV', 'SST', 'VIP'};

proportionMat = zeros(length(layers), length(types));
totalMat = zeros(length(layers), length(types));
actMat = zeros(length(layers), length(types));

for ii = 1:length(layers)
    for jj = 1:length(types)
        cells_rel = fetch(slicepatch.Cell & 'animal_id!=3024' & ['cell_layer="' layers{ii} '"'] & ['cell_type_gene="' types{jj} '"']);
        if strcmp(act_type, 'exc')
            cell_res = fetch(slicepatch.CellSummary & cells_rel & 'response=1');
            cell_all = fetch(slicepatch.CellSummary & cells_rel & 'response!=-1');
        elseif strcmp(act_type, 'exc_60')
            cell_res = fetch(slicepatch.CellSummary & cells_rel & 'res_exc=1');
            cell_all = fetch(slicepatch.CellSummary & cells_rel & 'has_cc_60=1');
        elseif strcmp(act_type, 'inh_60')
            cell_res = fetch(slicepatch.CellSummary & cells_rel & 'res_inh=1');
            cell_all = fetch(slicepatch.CellSummary & cells_rel & 'has_cc_60=1');
        end
        totalMat(ii,jj) = length(cell_all);
        actMat(ii,jj) = length(cell_res);
        proportionMat(ii,jj) = length(cell_res)/length(cell_all);
        
    end
end

proportionMat_rel  = proportionMat(proportionMat>0.5);
proportionMat(2,3) = mean(proportionMat_rel(:));
proportionMat(2,4) = mean(proportionMat_rel(:));
proportionMat(3,4) = mean(proportionMat_rel(:));

figure; imagesc(proportionMat'); hold on; colorbar; caxis([0,1]); colormap('gray')
set(gca, 'XTick', 1:length(layers));
set(gca, 'YTick', 1:length(types));
set(gca, 'XTickLabel', layers);
set(gca, 'YTickLabel', types);


for ii = 1:length(layers)
    for jj = 1:length(types)
        if (ii ==2 && (jj==4 || jj==3)) ||(ii==3 && jj==4)
            text(ii,jj,'N/A');
        else
            if proportionMat(ii,jj)>0.5
                text(ii,jj,[num2str(actMat(ii,jj)) '/' num2str(totalMat(ii,jj))]);
            else
                text(ii,jj,[num2str(actMat(ii,jj)) '/' num2str(totalMat(ii,jj))], 'Color','w');
            end
        end
    end
end