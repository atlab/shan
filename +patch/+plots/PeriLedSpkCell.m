function PeriLedSpkCell(varargin)

% scatter plot of spk, led on versus led off, with visual stimulus

restriction = fetch(patch.RecordingNote & varargin & 'recording_caveat=0' & patch.PeriLedTrial);
cell_res = fetch(patch.Cell & restriction & 'cell_type_morph="pyr"');

spk_cnt_on_inh = [];
spk_cnt_off_inh = [];
spk_cnt_on_exc = [];
spk_cnt_off_exc = [];

p_val_exc = [];
p_val_inh = [];
cnt=0;

key_temp = fetch(patch.PeriLedTrial & cell_res);
time0 = fetch1(patch.PeriLedTrial & key_temp(100),'peri_led_time');

for iKey = cell_res'
    spk_on = fetchn(patch.PeriLedTrial & iKey & 'peri_led_stat=1', 'peri_led_spk');
    spk_off = fetchn(patch.PeriLedTrial & iKey & 'peri_led_stat=-1', 'peri_led_spk');
    minlen_on = min(cellfun(@length, spk_on));
    minlen_off = min(cellfun(@length, spk_off));
    minlen = min(minlen_on, minlen_off);
    spk_on = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_on, 'Un', 0);
    spk_off = cellfun(@(x) patch.utils.cutArray(x,minlen), spk_off, 'Un', 0);
    time = patch.utils.cutArray(time0,minlen);

    spk_off_mat = horzcat(spk_off{:});
    spk_on_mat = horzcat(spk_on{:});
    spk_off_all = sum(horzcat(spk_off{:}),2);
    spk_on_all = sum(horzcat(spk_on{:}),2);
        
    if sum(spk_off_all)>200
        cnt = cnt+1;
        spk_on_inh = spk_on_all(time<0.15 & time>0.03);
        spk_off_inh = spk_off_all(time<0.15 & time>0.03);
        spk_on_exc = spk_on_all(time<0.03 & time>0);
        spk_off_exc = spk_off_all(time<0.03 & time>0);
        
        spk_off_inh_mat = sum(spk_off_mat(time<0.15 & time>0.03,:));
        spk_off_exc_mat = sum(spk_off_mat(time<0.03 & time>0,:));
        spk_on_inh_mat = sum(spk_on_mat(time<0.15 & time>0.03,:));
        spk_on_exc_mat = sum(spk_on_mat(time<0.03 & time>0,:));
        
        spk_cnt_on_inh(cnt) = sum(spk_on_inh)/length(spk_on)/0.12;
        spk_cnt_off_inh(cnt) = sum(spk_off_inh)/length(spk_off)/0.12;
        spk_cnt_on_exc(cnt) = sum(spk_on_exc)/length(spk_on)/0.03;
        spk_cnt_off_exc(cnt) = sum(spk_off_exc)/length(spk_off)/0.03;
        
        minlength_exc = min(length(spk_on_exc_mat),length(spk_off_exc_mat));
        minlength_inh = min(length(spk_on_inh_mat),length(spk_off_inh_mat));
        p_val_exc(cnt) = signrank(spk_on_exc_mat(1:minlength_exc), spk_off_exc_mat(1:minlength_exc));
        p_val_inh(cnt) = signrank(spk_on_inh_mat(1:minlength_inh), spk_off_inh_mat(1:minlength_inh));
    end
end



fig = Figure(102,'size',[70,60]);

plot(spk_cnt_off_exc(p_val_exc>0.05),spk_cnt_on_exc(p_val_exc>0.05),'ko', 'MarkerSize',4); hold on
plot(spk_cnt_off_exc(p_val_exc<0.05),spk_cnt_on_exc(p_val_exc<0.05),'k.', 'MarkerSize',12);
xlabel('LED off'); ylabel('LED on')
plot(spk_cnt_off_inh(p_val_inh>0.05),spk_cnt_on_inh(p_val_inh>0.05),'k^','MarkerSize',4);
plot(spk_cnt_off_inh(p_val_inh<0.05),spk_cnt_on_inh(p_val_inh<0.05),'k^','MarkerSize',4,'MarkerFaceColor','k');

xlabel('Firing rate LED off'); ylabel('Firing rate LED on')
legend('0-30ms p>0.05','0-30ms p<0.05','30-150ms p>0.05','30-150ms p<0.05','Location','NorthWest')
h2 = refline(1);
set(h2,'Color','k','LineStyle','--');
[h,p] = ttest(spk_cnt_off_inh, spk_cnt_on_inh)
[p,h] = signrank(spk_cnt_off_inh, spk_cnt_on_inh)

[h,p] = ttest(spk_cnt_off_exc, spk_cnt_on_exc)
[p,h] = signrank(spk_cnt_off_exc, spk_cnt_on_exc)

xlim([0,12]); ylim([0,12])

fig.cleanup; fig.save('in_vivo_spk_on_scatter.eps')

% fig2.cleanup; fig2.save('in_vivo_spk_off_scatter.eps')

