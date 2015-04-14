filename = '5213_V1.tif';
img = imread(['slices/' filename]);

% mark ROI
% figure; imagesc(img)
% A = getrect(gcf);

ROI = imread(['slices/' filename],'PixelRegion',{[25,500],[200,300]});

figure; imagesc(ROI)

mean_val = mean(ROI,2);
mean_val_norm = (mean_val - min(mean_val))/(max(mean_val)-min(mean_val));

figure; plot(wrev(mean_val_norm),(1:length(mean_val))*2);