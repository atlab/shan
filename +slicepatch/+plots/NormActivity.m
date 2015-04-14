function NormActivity(activity_type, figure_type, excl)
% EPSC values normalized with EPSC of L23 cells in the same slice
%   
if ~exist('excl','var')
    excl = 'no';
end
layers = {'L23', 'L4', 'L5'};
types = {'pyr', 'PV', 'SST', 'VIP'};

actMat = cell(length(layers), length(types));

nameMat = cell(length(layers), length(types));

for ii = 1:length(layers)
    for jj = 1:length(types)
        cells_rel = fetch(slicepatch.Cell & 'animal_id!=3024' & ['cell_layer="' layers{ii} '"'] & ['cell_type_gene="' types{jj} '"']);
        if strcmp(activity_type,'epsc')
            if strcmp(excl, 'yes')
                cell_res = fetch(slicepatch.CellSummary & cells_rel & 'res_epsc = 1');
                cell_res = fetch(slicepatch.CellSummaryNorm & cell_res &  'has_norm_epsc=1', '*');
            else
                cell_res = fetch(slicepatch.CellSummaryNorm & cells_rel & 'has_norm_epsc=1', '*');
            end
            log_norm_epsc = [cell_res.norm_epsc];
            actMat{ii,jj} = log_norm_epsc;
            yLim = [0,6];
            yName = 'EPSC normalized to the L23 pyramidal cells';
        elseif strcmp(activity_type,'epsp')
            if strcmp(excl, 'yes')
                cell_res = fetch(slicepatch.CellSummary & cells_rel & 'res_epsp = 1');
                cell_res = fetch(slicepatch.CellSummaryNorm & cell_res & 'has_norm_epsp=1', '*');
            else
                cell_res = fetch(slicepatch.CellSummaryNorm & cells_rel & 'has_norm_epsp=1', '*');
            end
            log_norm_epsp = log([cell_res.norm_epsp]);
            actMat{ii,jj} = log_norm_epsp;
            yLim = [-3,3];
            yName = 'EPSP normalized to the L23 pyramidal cells';
        elseif strcmp(activity_type,'ipsc')
            if strcmp(excl, 'yes')
                cell_res = fetch(slicepatch.CellSummary & cells_rel & 'res_ipsc = 1');
                cell_res = fetch(slicepatch.CellSummaryNorm & cell_res, '*');
            else
                cell_res = fetch(slicepatch.CellSummaryNorm & cells_rel & 'has_norm_ipsc=1', '*');
            end
            actMat{ii,jj} = [cell_res.norm_ipsc];
            yLim = [0,6];
            yName = 'IPSC nomalized to the L23 pyramidal cells';
        elseif strcmp(activity_type,'eiratio')
            cell_res = fetch(slicepatch.CellSummary & cells_rel & 'has_eiratio=1', '*');
            actMat{ii,jj} = [cell_res.eiratio];
            yLim = [-1,1];
            yName = '(EPSC-IPSC)/(EPSC+IPSC)';
        end
        
        nameMat{ii,jj} = [layers{ii} '_' types{jj}];
    end
end


if strcmp(figure_type,'landscape')
    figure; imagesc(actMat'); hold on; colorbar;
    set(gca, 'XTick', 1:length(layers));
    set(gca, 'YTick', 1:length(types));
    set(gca, 'XTickLabel', layers);
    set(gca, 'YTickLabel', types);


    for ii = 1:length(layers)
        for jj = 1:length(types)
           text(ii,jj,num2str(numMat(ii,jj)));
        end
    end
    
elseif strcmp(figure_type, 'bar')
    fig = Figure(101,'size',[100,65]); hold on
    barfun(actMat);
    set(gca, 'XTick', 1:length(layers));
    set(gca, 'XTickLabel', layers);
    legend(types);
    ylim(yLim); ylabel(yName)
    fig.cleanup;
    if strcmp(excl,'no')
        fig.save(['/Volumes/lab/users/Shan/V2_project/FineResults/summary/' activity_type '_norm.eps'])
    else
        fig.save(['/Volumes/lab/users/Shan/V2_project/FineResults/summary/' activity_type '_norm_active_only.eps'])
    end
end