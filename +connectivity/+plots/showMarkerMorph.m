function showMarkerMorph(gene)
    % show the relationship between maker and morphology
    % SS 6-19-2014
    
    % get all the cells with the maker gene
    cells_all = fetch(connectivity.Cell & ['cell_type_gene="' gene '"']);
    type_morph = unique(fetchn(connectivity.Cell & cells_all,'cell_type_morph'));
    
    perc_morph = zeros(1,length(type_morph));
    for ii = 1:length(type_morph)
        cells = fetch(connectivity.Cell & cells_all & ['cell_type_morph="' type_morph{ii} '"']);
        perc_morph(ii) = length(cells)/length(cells_all);
    end
    figure;
    pie(perc_morph);
    legend(type_morph,'Location','southoutside','Orientation','horizontal')
    
    cells_all = fetch(connectivity.Cell & ['cell_type_gene="' gene '"'] & 'cell_layer="L23"');
    type_morph = unique(fetchn(connectivity.Cell & cells_all,'cell_type_morph'));
    
    perc_morph = zeros(1,length(type_morph));
    for ii = 1:length(type_morph)
        cells = fetch(connectivity.Cell & cells_all & ['cell_type_morph="' type_morph{ii} '"']);
        perc_morph(ii) = length(cells)/length(cells_all);
    end
    figure; title('L23');
    pie(perc_morph); legend(type_morph,'Location','southoutside','Orientation','horizontal')
    
    cells_all = fetch(connectivity.Cell & ['cell_type_gene="' gene '"'] & 'cell_layer="L5"');
    type_morph = unique(fetchn(connectivity.Cell & cells_all,'cell_type_morph'));
    
    perc_morph = zeros(1,length(type_morph));
    for ii = 1:length(type_morph)
        cells = fetch(connectivity.Cell & cells_all & ['cell_type_morph="' type_morph{ii} '"']);
        perc_morph(ii) = length(cells)/length(cells_all);
    end
    
    figure; title('L5');
    pie(perc_morph); legend(type_morph,'Location','southoutside','Orientation','horizontal') 