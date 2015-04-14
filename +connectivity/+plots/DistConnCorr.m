function DistConnCorr(varargin)

% 2D plots for distances between all the cell pairs

if (length(varargin) == 1 && strcmp(lowercase(varargin{1}),'all')) || isempty(varargin)
    % get all the cell types in the database
    types_from = unique(fetchn(connectivity.Cell & ...
    'cell_layer not in ("L4","L6","Unknown")' & 'cell_type_morph!="Unknown"',...
    'CONCAT(cell_layer," ",cell_type_morph)->cell_type'));
    types_to = types_from;
else
    idx1 = find(strcmp(varargin,'from')==1);
    idx2 = find(strcmp(varargin, 'to')==1);
    types_from = varargin{idx1+1:idx2-1};
    types_to = varargin{idx2+1:end};
end

distMat = zeros(length(types_from), length(types_to));
errMat = zeros(length(types_from), length(types_to));
connRatioMat = zeros(length(types_from), length(types_to));

for ii = 1:length(types_from)
    for jj = 1:length(types_to)
        type_from = types_from{ii};
        type_to = types_to{jj};
        type_from = regexp(type_from, '(\w+) (\w+)','tokens');
        type_to = regexp(type_to, '(\w+) (\w+)', 'tokens');
        keys_from = fetch(connectivity.Cell & ['cell_layer="' char(type_from{1}(1)) '"'] & ['cell_type_morph="' char(type_from{1}(2)) '"']);
        keys_to = fetch(connectivity.Cell & ['cell_layer="' char(type_to{1}(1)) '"'] & ['cell_type_morph="' char(type_to{1}(2)) '"']);
        pairs = fetch((connectivity.ConnectMembership & 'role="from"' & keys_from)...
            * pro(connectivity.ConnectMembership & 'role="to"' & keys_to, 'cell_id->cell_id2'));
        pairs = fetch(connectivity.CellTestedPair & pairs);
        dist = fetchn(connectivity.Distance & pairs,'distance');
        distMat(ii,jj) = mean(dist);
        errMat(ii,jj) = std(dist)/sqrt(length(dist));
        pairs_connected = fetch(connectivity.CellTestedPair & pairs & 'connected=1');
        connRatioMat(ii,jj) = length(pairs_connected)/length(pairs);
    end
end

figure; set(gcf,'Position',[50,50,300,250]);
distVec = distMat(:);
connRatioVec = connRatioMat(:);

distVec_rel = distVec(~isnan(connRatioVec));
connRatioVec_rel = connRatioVec(~isnan(connRatioVec));

distVec_rel = distVec_rel(connRatioVec_rel < 0.7);
connRatioVec_rel = connRatioVec_rel(connRatioVec_rel < 0.7);

scatter(distVec_rel, connRatioVec_rel,'ko');

[r,p] = corrcoef(distVec_rel, connRatioVec_rel)
