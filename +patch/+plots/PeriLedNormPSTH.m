function PeriLedNormPSTH(varargin) 


restriction = fetch(patch.RecordingNote & varargin & 'recording_caveat=0' & patch.PeriLedTrial);
cell_res = fetch(patch.Cell & restriction);

spk_on_mat = {};
spk_off_mat = {};
cnt=0;
for iKey = cell_res'
    [win, spk_on] = fetchn(patch.PeriLedTrial & iKey & 'peri_led_stat=1','peri_led_win', 'peri_led_spk');
    spk_off = fetchn(patch.PeriLedTrial & iKey & 'peri_led_stat=-1', 'peri_led_spk');
    minlen_on = min(cellfun(@length, spk_on));
    minlen_off = min(cellfun(@length, spk_off));
    minlen = min(minlen_on, minlen_off);
    spk_on = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_on, 'Un', 0);
    spk_off = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_off, 'Un', 0);
    spk_off_all = sum(horzcat(spk_off{:}),2);
    spk_on_all = sum(horzcat(spk_on{:}),2);
        
    if sum(spk_off_all)>100
        cnt = cnt+1;
        spk_on_mat{cnt} = spk_on_all/sum(spk_off_all)*sum(win{1});
        spk_off_mat{cnt} = spk_off_all/sum(spk_off_all)*sum(win{1});
    end
end


minlen_on = min(cellfun(@length, spk_on_mat));
minlen_off = min(cellfun(@length, spk_off_mat));
minlen = min(minlen_on, minlen_off);
 
spk_on_mat = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_on_mat, 'Un', 0);
spk_off_mat = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_off_mat, 'Un', 0);
spk_off_all = mean(horzcat(spk_off_mat{:}),2);
spk_on_all = mean(horzcat(spk_on_mat{:}),2);

spk_off_all = conv(spk_off_all, gausswin(150),'same');
spk_on_all = conv(spk_on_all, gausswin(150), 'same');

key_temp = fetch(patch.PeriLedTrial & iKey);

time = fetch1(patch.PeriLedTrial & key_temp(1),'peri_led_time');
time = patch.utils.cutArray(time,minlen);
fig = Figure(102,'size',[100,60]); plot(time,spk_off_all, 'r'); hold on
plot(time,spk_on_all)

legend('LED off','LED on')
xlim([-0.6,0.6]);
yLim = get(gca, 'YLim');
h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
uistack(h,'bottom');
xlabel('time/s')
ylabel('spike counts')

fig.cleanup; fig.save('PeriLedPSTH.eps')