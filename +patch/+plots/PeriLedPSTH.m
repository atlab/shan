function PeriLedPSTH(varargin)


restriction = fetch(patch.RecordingNote & 'recording_caveat=0' & 'recording_purpose="temporal sharpening"');

keys_cell = fetch(patch.Cell & varargin & restriction);

figure; set(gcf,'Position',get(gcf,'Position').*[1,1,1,3.5])

for ii = 1:length(keys_cell)
    ikey = keys_cell(ii);
    spk_on = fetchn(patch.PeriLedTrial & ikey & restriction & 'peri_led_stat=1', 'peri_led_spk');
    spk_off = fetchn(patch.PeriLedTrial & ikey & restriction & 'peri_led_stat=-1', 'peri_led_spk');

    minlen_on = min(cellfun(@length, spk_on));
    minlen_off = min(cellfun(@length, spk_off));
    minlen = min(minlen_on, minlen_off);

    spk_on = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_on, 'Un', 0);
    spk_off = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_off, 'Un', 0);
    spk_off_all = sum(horzcat(spk_off{:}),2);
    spk_on_all = sum(horzcat(spk_on{:}),2);

    spk_off_all = conv(spk_off_all, gausswin(150),'same');
    spk_on_all = conv(spk_on_all, gausswin(150), 'same');

    key_temp = fetch(patch.PeriLedTrial & varargin & restriction);
    time = fetch1(patch.PeriLedTrial & key_temp(1), 'peri_led_time');
    time = patch.utils.cutArray(time,minlen);
%     fig = Figure(102,'size',[80,40]);

    subplot(7,3,ii)
    plot(time,spk_off_all, 'r'); hold on
    plot(time,spk_on_all)
    if ii ==1
        legend('LED off','LED on')
    end
    ylim([0,50]); xlim([-0.6,0.6]);
    yLim = get(gca, 'YLim');
    h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
    uistack(h,'bottom');
    xlabel('time/s')
    ylabel('spike counts')
%     fig.cleanup; fig.save(['PeriLedPSTH-' num2str(ii) '.eps'])
end