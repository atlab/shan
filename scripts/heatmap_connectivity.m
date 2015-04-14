
filename = '/Users/shanshen/Dropbox/Xiaolong and Shan/complete matrix of L1 L23 and L5 interneurons.xlsx';

% connectivity

[~,cell_types] = xlsread(filename, 1, 'B21:R21');
conn = xlsread(filename, 1, 'B22:R38');
[~,txt] = xlsread(filename, 1,'B2:R18');
conn = conn';
txt = txt';

% define colormap

map = [ones(50,1), linspace(1,0,50)', linspace(1,0,50)'];


figure; imagesc(conn'); colormap(map); caxis([0,1]); colorbar; hold on

set(gcf,'Position', [500,500,650,400]);
set(gca, 'XTick', 1:length(cell_types), 'YTick', 1:length(cell_types));
set(gca,'xaxisLocation','top')
set(gca,'xTickLabel',cell_types, 'yTickLabel',cell_types, 'TickLength', [0,0.35]);

% plot grid lines 
for ii = 1:length(cell_types)
    plot((1:length(cell_types)+1)-0.5, ones(1,length(cell_types)+1)*(ii - 0.5), 'Color',[0.7,0.7,0.7]);
end

for ii = 1:length(cell_types)
    plot(ones(1,length(cell_types)+1)*(ii - 0.5),(1:length(cell_types)+1)-0.5, 'Color',[0.7,0.7,0.7]);
end

% mark text
for ii = 1:length(cell_types)
    for jj = 1:length(cell_types)
  
        h = text(ii-0.25,jj,txt{ii,jj});
        set(h,'FontSize',6,'FontName','Arial');

    end
end

% amplitude

conn = xlsread(filename, 2, 'B2:R18');
[~,txt] = xlsread(filename, 2,'B22:R38');
conn = conn';
txt = txt';
figure; imagesc(conn'); colormap(map); caxis([0,2]); colorbar; hold on
set(gcf,'Position', [500,500,650,400]);
set(gca, 'XTick', 1:length(cell_types), 'YTick', 1:length(cell_types));
set(gca,'xaxisLocation','top')
set(gca,'xTickLabel',cell_types, 'yTickLabel',cell_types, 'TickLength', [0,0.35]);

% plot grid lines 
for ii = 1:length(cell_types)
    plot((1:length(cell_types)+1)-0.5, ones(1,length(cell_types)+1)*(ii - 0.5), 'Color',[0.7,0.7,0.7]);
end

for ii = 1:length(cell_types)
    plot(ones(1,length(cell_types)+1)*(ii - 0.5),(1:length(cell_types)+1)-0.5, 'Color',[0.7,0.7,0.7]);
end

for ii = 1:length(cell_types)
    for jj = 1:length(cell_types)
        
        if strcmp(txt{ii,jj},['0.00' setstr(177) '0.00']);
            h = text(ii-0.1,jj+0.15,'0');
        else
            h = text(ii-0.25,jj-0.25,txt{ii,jj});
        end
        set(h,'FontSize',6,'FontName','Arial');

    end
end
