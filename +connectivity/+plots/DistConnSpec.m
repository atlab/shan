function DistConnSpec(layer_from, layer_to, type, tosave)
% show the relationship between cell distance and connectivity, with specific layer conditions
% layer_from : layers where the cells that send connection to other cells,
% could be multiple layers, formatted as 'L23,L5'
% layer_to : layers where the cells that receive connection from other
% cells, could be multiple layers, formatted as 'L23,L5'
% type : enum('all','ind') # all means all to all, 'L23,L5' to 'L23,L5' includes L23->L23,L23-L5,L5->L23,L5->L5

if ~exist('tosave','var')
    tosave=0;
end

if isempty(regexp(layer_from,',','once')) || isempty(regexp(layer_to,',','once'))
    type = 'all';
end

if strcmp(type,'all')
    % fetch all the pairs with their distances
    layer_from_keys = fetch(connectivity.Cell & ['cell_layer in ("' layer_from '")']);
    layer_to_keys = fetch(connectivity.Cell & ['cell_layer="' layer_to '"']);
    pairs = fetch((connectivity.ConnectMembership & 'role="from"' & layer_from_keys)...
        * pro(connectivity.ConnectMembership & 'role="to"' & layer_to_keys, 'cell_id->cell_id2'));

elseif strcmp(type, 'ind')
    exp = regexp(layer_from,'\w*,','match'); layer_from1 = exp{1}(1:end-1);
    exp = regexp(layer_from,',\w*','match'); layer_from2 = exp{1}(2:end);
    exp = regexp(layer_to,'\w*,','match'); layer_to1 = exp{1}(1:end-1);
    exp = regexp(layer_to,',\w*','match'); layer_to2 = exp{1}(2:end);
    layer_from_keys1 = fetch(connectivity.Cell & ['cell_layer in ("' layer_from1 '")']);
    layer_from_keys2 = fetch(connectivity.Cell & ['cell_layer in ("' layer_from2 '")']);
    layer_to_keys1 = fetch(connectivity.Cell & ['cell_layer in ("' layer_to1 '")']);
    layer_to_keys2 = fetch(connectivity.Cell & ['cell_layer in ("' layer_to2 '")']);
    
    pairs1 = fetch((connectivity.ConnectMembership & 'role="from"' & layer_from_keys1)...
        * pro(connectivity.ConnectMembership & 'role="to"' & layer_to_keys1, 'cell_id->cell_id2'));
    
    pairs2 = fetch((connectivity.ConnectMembership & 'role="from"' & layer_from_keys2)...
        * pro(connectivity.ConnectMembership & 'role="to"' & layer_to_keys2, 'cell_id->cell_id2'));
    pairs = [pairs1; pairs2];
    
else
    error('Invalid type input, please enter all or ind.')
end

pairs = fetch(connectivity.CellTestedPair & pairs);
[distances, dist_x, dist_y] = fetchn(connectivity.Distance & pairs, 'distance', 'dist_x', 'dist_y');
% histogram of distances
fig1 = Figure(201,'size',[80,60]); hist(distances,linspace(0,600,20)); h = findobj(gca,'Type','patch'); set(h,'FaceColor','w'); xlim([-50,600]); fig1.cleanup
fig2 = Figure(202,'size',[80,60]); hist(dist_x,linspace(0,600,20),'FaceColor','w');h = findobj(gca,'Type','patch'); set(h,'FaceColor','w'); xlim([-50,600]); fig2.cleanup

bins = linspace(150,500,6);
bins_x = linspace(25,200,6);
bins_y = linspace(150,300,6);
conf = 0.95;
yLim = 0.4;

z = norminv(0.5+0.5*conf);
idx = interp1(bins,1:length(bins),distances,'nearest','extrap');
idx_x = interp1(bins_x,1:length(bins_x),dist_x,'nearest','extrap');
idx_y = interp1(bins_y,1:length(bins_y),dist_y,'nearest','extrap');

connMat = zeros(1,length(bins));
errMat = zeros(1,length(bins));
num_connected_pairs = zeros(1,length(bins));
num_total_pairs = zeros(1,length(bins));
for ii = 1:length(bins)
    pairs_rel = pairs(idx==ii);
    conn =  fetchn(connectivity.CellTestedPair & pairs_rel, 'connected');
    p_conn = mean(conn);
    err = z*sqrt(p_conn*(1-p_conn)/length(conn));
    connMat(ii) = p_conn;
    errMat(ii) = err;
    num_connected_pairs(ii) = sum(conn==1);
    num_total_pairs(ii) = length(conn);
end

fig = Figure(101,'size',[80,60]); plot(bins,connMat,'o'); hold on
errorbar(bins,connMat,errMat);
ylim([0,yLim]); xlim([min(bins)-50,max(bins)+50]);
xlabel('Intersomatic distance(um)');
ylabel('Connection Probability');
fig.cleanup; 

if tosave
    fig.save(['ConnDist_' layer_from '_' layer_to '.eps']);
end

connMat_x = zeros(1,length(bins_x));
errMat_x = zeros(1,length(bins_x));
num_connected_pairs_x = zeros(1,length(bins_x));
num_total_pairs_x = zeros(1,length(bins_x));
for ii = 1:length(bins_x)
    pairs_rel = pairs(idx_x==ii);
    conn_x = fetchn(connectivity.CellTestedPair & pairs_rel, 'connected');
    p_conn_x = mean(conn_x);
    err_x = z*sqrt(p_conn_x*(1-p_conn_x)/length(conn_x));
    connMat_x(ii) = p_conn_x;
    errMat_x(ii) = err_x;
    num_connected_pairs_x(ii) = sum(conn_x==1);
    num_total_pairs_x(ii) = length(conn_x);
end

fig = Figure(102,'size',[80,60]); plot(bins_x,connMat_x,'o'); hold on
errorbar(bins_x,connMat_x,errMat_x);
ylim([0,yLim]); xlim([min(bins_x)-50,max(bins_x)+50]);
xlabel('Intersomatic distance x(um)');
ylabel('Connection Probability');
fig.cleanup;

if tosave
    fig.save(['ConnDist_x_' layer_from '_' layer_to '.eps']);
end

connMat_y = zeros(1,length(bins_y));
errMat_y = zeros(1,length(bins_y));
num_connected_pairs_y = zeros(1,length(bins_y));
num_total_pairs_y = zeros(1,length(bins_y));
for ii = 1:length(bins_y)
    pairs_rel = pairs(idx_y==ii);
    conn_y = fetchn(connectivity.CellTestedPair & pairs_rel, 'connected');
    p_conn_y = mean(conn_y);
    err_y = z*sqrt(p_conn_y*(1-p_conn_y)/length(conn_y));
    connMat_y(ii) = p_conn_y;
    errMat_y(ii) = err_y;
    num_connected_pairs_y(ii) = sum(conn_y==1);
    num_total_pairs_y(ii) = length(conn_y);
end

fig = Figure(103,'size',[80,60]); plot(bins_y,connMat_y,'o'); hold on
errorbar(bins_y,connMat_y,errMat_y);
ylim([0,yLim]); xlim([min(bins_y)-50,max(bins_y)+50]);
xlabel('Intersomatic distance y(um)');
ylabel('Connection Probability');
fig.cleanup;

if tosave
    fig.save(['ConnDist_y_' layer_from '_' layer_to '.eps']);
    save([layer_from '_' layer_to '.mat'], 'bins','bins_x','bins_y','num_connected_pairs','num_total_pairs','num_connected_pairs_x','num_total_pairs_x','num_connected_pairs_y','num_total_pairs_y')
end