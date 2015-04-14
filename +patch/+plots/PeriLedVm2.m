function PeriLedVm2(varargin)

% trace average across cells, with visual stimulus
% SS 2015-01-21

keys_led = fetch(patch.Led & 'led_dur>0.01' & 'led_dur<0.03');
keys_cell = fetch(patch.Cell & 'patch_type="whole cell"' & varargin & keys_led & (patch.RecordingNote & 'recording_purpose = "temporal sharpening"' & 'recording_caveat=0') & patch.PeriLedTrial);

vmMat = cell(1,length(keys_cell));
for ii = 1:length(keys_cell)
    ikey = keys_cell(ii);
    rec_res = fetch(patch.RecordingNote & 'recording_purpose="temporal sharpening"' & 'recording_caveat=0' & ikey);
    vm = fetchn(patch.PeriLedTrial & rec_res & 'peri_led_stat=1','peri_led_vm_norm');
    minlen = min(cellfun(@length,vm));
    vm = cellfun(@(x) patch.utils.cutArray(x,minlen),vm,'Un',0);
    meanVm = nanmean(horzcat(vm{:}),2)'*1000;
    vmMat{ii} = meanVm;
    clear vm; clear minlen
end
rec_res = fetch(patch.RecordingNote & 'recording_purpose="temporal sharpening"');
keys = fetch(patch.PeriLedTrial & rec_res);
vt = fetch1(patch.PeriLedTrial & keys(1), 'peri_led_time');
minlen = min(cellfun(@length,vmMat));
vmMat = cellfun(@(x) patch.utils.cutArray(x,minlen),vmMat,'Un',0);
vt = patch.utils.cutArray(vt,minlen)'*1000;
meanVm = mean(horzcat(vmMat{:}),2)';
semVm = std(horzcat(vmMat{:}),[],2)'/sqrt(length(keys_cell));

fig = Figure(201,'size',[100,80]); hold on

patch([vt wrev(vt)],[meanVm+semVm wrev(meanVm-semVm)],[0.7,0.7,0.7], 'LineStyle','None');
plot(vt,meanVm,'k');
ylim([-10,10]); xlim([-50,300]);
yLim = get(gca,'YLim');
h = patch([0,20,20,0],[yLim(1) yLim(1),yLim(2),yLim(2)],[0.6,0.8,1],'LineStyle','None');
uistack(h,'bottom');
plot([150,200],[4,4],'k')
plot([150,150],[4,9],'k')
set(gcf,'renderer','painters');
fig.cleanup;
% fig.save('spon_summary.eps')