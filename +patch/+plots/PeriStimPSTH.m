function PeriStimPSTH(varargin)


restriction = fetch(patch.RecordingNote & 'recording_caveat=0' & 'recording_purpose="temporal sharpening"');

keys_cell = fetch(patch.Cell & varargin & restriction);

figure; set(gcf,'Position',get(gcf,'Position').*[1,1,1,3.5])

for ii = 1:length(keys_cell)
    ikey = keys_cell(ii);
    
    spk_off = fetchn(patch.PeriStimTrial & ikey & restriction & 'peri_stim_stat=-1', 'peri_stim_spk');

    
    minlen = min(cellfun(@length, spk_off));
    
    spk_off = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_off, 'Un', 0);
    spk_off_all = sum(horzcat(spk_off{:}),2);
   
    spk_off_all = conv(spk_off_all, gausswin(150),'same');

    key_temp = fetch(patch.PeriStimTrial & varargin & restriction);
    time = fetch1(patch.PeriStimTrial & key_temp(1), 'peri_stim_time');
    time = patch.utils.cutArray(time,minlen);
%     fig = Figure(102,'size',[80,40]);

    subplot(7,3,ii)
    plot(time,spk_off_all, 'r'); hold on
   
    ylim([0,25]); xlim([-0.6,0.6]);
    yLim = get(gca, 'YLim');
    h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
    uistack(h,'bottom');
    xlabel('time/s')
    ylabel('spike counts')
%     fig.cleanup; fig.save(['PeriLedPSTH-' num2str(ii) '.eps'])
end