function h = PeriLedSpon(varargin)
% h = PeriLed(key)
% SS 2014-02-19

restriction = fetch(patch.RecordingNote & 'recording_caveat=0' & 'recording_purpose="spontaneous activity"');

keys_cell = fetch(patch.Cell & varargin & restriction);

keys = fetch(patch.PeriLed & varargin & keys_cell)';


vt0 = fetch1(patch.PeriLed & keys(1), 'peri_led_time');
figure; set(gcf, 'Position', get(gcf, 'Position').*[1,1,1,3.5]);

for ii = 1:length(keys_cell)
    ikey = keys_cell(ii);
    patch_type = fetch1(patch.Cell & ikey, 'patch_type');
    if ~strcmp(patch_type, 'whole cell')
        continue
    end
    vm = fetchn(patch.PeriLed & ikey, 'peri_led_vm');
    if isempty(vm)
        continue
    end
    minlen = min(cellfun(@length, vm));
    vm = cellfun(@(x) patch.utils.cutArray(x,minlen), vm, 'Un', 0);
    vt = patch.utils.cutArray(vt0,minlen);
    vt = vt'*1000;
    meanVm = nanmean(horzcat(vm{:}),2)'*1000;
    semVm = nanstd(horzcat(vm{:}),[],2)'/sqrt(length(vm))*1000;

    subplot(7,3,ii)
    patch([vt wrev(vt)],[meanVm+semVm wrev(meanVm-semVm)],[0.7,0.7,0.7], 'LineStyle','None'); hold on
    plot(vt,meanVm,'k');
    ylim([-10,10]); xlim([-50,300]);
    yLim = get(gca,'YLim');
    h = patch([0,20,20,0],[yLim(1) yLim(1),yLim(2),yLim(2)],[0.6,0.8,1],'LineStyle','None');
    uistack(h,'bottom');
%     plot([150,200],[4,4],'k')
%     plot([150,150],[4,9],'k')
    set(gcf,'renderer','painters');
%     fig.cleanup; 
%     fig.save('spon_summary.eps')

end