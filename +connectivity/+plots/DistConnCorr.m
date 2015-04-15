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
nPairsMat = zeros(length(types_from), length(types_to));

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
        nPairsMat(ii,jj) = length(pairs);
        pairs_connected = fetch(connectivity.CellTestedPair & pairs & 'connected=1');
        connRatioMat(ii,jj) = length(pairs_connected)/length(pairs);
    end
end

distVec = distMat(:);
connRatioVec = connRatioMat(:);
nPairsVec = nPairsMat(:);

% some restrictions
distVec_rel = distVec(~isnan(connRatioVec));
connRatioVec_rel = connRatioVec(~isnan(connRatioVec));
nPairsVec_rel = nPairsVec(~isnan(connRatioVec));

distVec_rel = distVec_rel(nPairsVec_rel>10);
connRatioVec_rel = connRatioVec_rel(nPairsVec_rel>10);

distVec_rel = distVec_rel(distVec_rel<250);
connRatioVec_rel = connRatioVec_rel(distVec_rel<250);

distVec_rel = distVec_rel(connRatioVec_rel<0.7);
connRatioVec_rel = connRatioVec_rel(connRatioVec_rel<0.7);
% fits
p = polyfit(distVec_rel, connRatioVec_rel,1);
yfit = polyval(p,distVec_rel);
yresid = connRatioVec_rel - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(distVec_rel)-1) * var(connRatioVec_rel);
rsq = 1 - SSresid/SStotal
fig = Figure(101,'size',[70,50]); 
scatter(distVec_rel, connRatioVec_rel,'ko'); hold on
[x,idx] = sort(distVec_rel);
plot(x, yfit(idx))
fig.cleanup
[r,p] = corrcoef(distVec_rel, connRatioVec_rel)
