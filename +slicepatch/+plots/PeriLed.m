function PeriLed(varargin)


keys_led = fetch(slicepatch.VoltageProperties & 'nLed=2');
keys_cell = fetch(slicepatch.Cell & 'cell_type_morph="pyr"' & 'cell_layer = "L23"');
keys = fetch(slicepatch.FineTraceCCAlign & varargin & keys_led & keys_cell)';


vt = fetch1(slicepatch.FineTraceCCAlign & keys(1), 'time');
vm = fetchn(slicepatch.FineTraceCCAlign & keys, 'finetrace');

minlen = min(cellfun(@length, vm));
vm = cellfun(@(x) patch.utils.cutArray(x,minlen), vm, 'Un', 0);
vt = patch.utils.cutArray(vt,minlen);
meanVm = nanmean(horzcat(vm{:}),2)';
semVm = nanstd(horzcat(vm{:}),[],2)'/sqrt(length(keys));

figure; hold on

patch([vt wrev(vt)],[meanVm+semVm wrev(meanVm-semVm)],[0.7,0.7,0.7], 'LineStyle','None');
plot(vt,meanVm,'k');
ylim([-5,5]); xlim([-50,300]);
yLim = get(gca,'YLim');
h = patch([0,2,2,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
uistack(h,'bottom');