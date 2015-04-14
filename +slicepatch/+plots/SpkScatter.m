function SpkScatter(time1,time2,varargin)
% plot the on off period

[spk_cnt_on1, spk_cnt_off1, pval1] = SpkCnts(time1(1),time1(2),varargin);
[spk_cnt_on2, spk_cnt_off2, pval2] = SpkCnts(time2(1),time2(2),varargin);

fig = Figure(102,'size',[60,50]);

plot(spk_cnt_off1, spk_cnt_on1,'ko','MarkerSize', 4); hold on
plot(spk_cnt_off2, spk_cnt_on2, 'k.', 'MarkerSize', 12)
legend('0-10ms','10-20ms','Location','SouthEast');
h = refline(1);
set(h, 'Color', 'k','LineStyle','--');
xlabel('Firing rate - LED off'); ylabel('Firing rate - LED on');

fig.cleanup
fig.save('/Volumes/lab/users/Shan/V2_project/FineResults/summary/in_vitro_spk_scatter.eps');

% helper function

function [spk_cnt_on_mean, spk_cnt_off_mean, pval] = SpkCnts(time_start, time_end, varargin)
% mean spk counts for a certain time range
animal_restrict = fetch(common.Animal & 'owner="Shan"' &  'line!="WFS1-Cre"' & 'line!="Etv1-Cre"');
keys_restrict = fetch(slicepatch.PeriLed & 'peri_led_delay>49' & 'peri_led_delay<151');
keys_cell = fetch(slicepatch.Cell & animal_restrict & keys_restrict & 'cell_type_morph="pyr"' & varargin)';

spk_cnt_on_mean = zeros(1,length(keys_cell));
spk_cnt_off_mean = zeros(1,length(keys_cell));
pval = zeros(1,length(keys_cell));
for ii = 1:length(keys_cell)
    key = keys_cell(ii);
    keys_on = fetch(slicepatch.PeriLed & key & 'peri_led_delay>49' & 'peri_led_delay<151')';
    spk_cnt_on = zeros(1,length(keys_on));
    for jj = 1:length(keys_on)
        ikey = keys_on(jj);
        trace = fetch(slicepatch.PeriLed & ikey,'*');
        
        spk_time = trace.peri_led_time;
        spk_train = trace.peri_led_spk(spk_time<time_end & spk_time>time_start);
        spk_cnt_on(jj) = sum(spk_train);
    end
    spk_cnt_on_mean(ii) = mean(spk_cnt_on)/(time_end-time_start)*1000;
    
    keys_off = fetch(slicepatch.PeriLedOff & key & 'peri_led_delay>49' & 'peri_led_delay<151')';
    spk_cnt_off = zeros(1,length(keys_off));
     for jj = 1:length(keys_off)
        ikey = keys_off(jj);
        trace = fetch(slicepatch.PeriLedOff & ikey,'*');
        spk_time = trace.peri_led_time;
        spk_train = trace.peri_led_spk(spk_time<time_end & spk_time>time_start);
        spk_cnt_off(jj) = sum(spk_train);
     end
     spk_cnt_off_mean(ii) = mean(spk_cnt_off)/(time_end-time_start)*1000;
     
     [~,pval(ii)] = ttest2(spk_cnt_on, spk_cnt_off);
end

