function SpikeDensity(layer,varargin)

% spike density function, with LED on or off

animal_restrict = fetch(common.Animal & 'owner="Shan"' &  'line!="WFS1-Cre"' & 'line!="Etv1-Cre"');
keys_restrict = fetch(slicepatch.PeriLed & 'peri_led_delay>49' & 'peri_led_delay<151');
keys_cell = fetch(slicepatch.Cell & animal_restrict & keys_restrict & 'cell_type_morph="pyr"' & varargin)';
time = -200:0.04:300;
spkcount_on = zeros(length(keys_cell),length(time));
spkcount_off = zeros(length(keys_cell),length(time));
for kk = 1:length(keys_cell)
    key = keys_cell(kk);
    keys_on = fetch(slicepatch.PeriLed & key & 'peri_led_delay>49' & 'peri_led_delay<151')';
    for ikey = keys_on
        trace = fetch(slicepatch.PeriLed & ikey,'*');
        spk_time = trace.peri_led_time(logical(trace.peri_led_spk));
        for ii = 1:length(spk_time)
            spkcount_on(kk,time==spk_time(ii)) = spkcount_on(kk,time==spk_time(ii))+1;
        end
    end
    spkcount_on(kk,:) = spkcount_on(kk,:)/length(keys_on);
    keys_off = fetch(slicepatch.PeriLedOff & key & 'peri_led_delay>49' & 'peri_led_delay<151')';
     for ikey = keys_off
        trace = fetch(slicepatch.PeriLedOff & ikey,'*');
        spk_time = trace.peri_led_time(logical(trace.peri_led_spk));
        for ii = 1:length(spk_time)
            spkcount_off(kk,time==spk_time(ii)) = spkcount_off(kk,time==spk_time(ii))+1;
        end
     end
     spkcount_off(kk,:) = spkcount_off(kk,:)/length(keys_off);
end

% convolution way of showing spike density
% spkcount_on = sum(bsxfun(@rdivide, spkcount_on, sum(spkcount_off,2)));
% spkcount_off = sum(bsxfun(@rdivide, spkcount_off,sum(spkcount_off,2)));
spkcount_on_bin = conv(mean(spkcount_on), gausswin(50),'same')*500;
spkcount_off_bin = conv(mean(spkcount_off),gausswin(50),'same')*500;

% convolved traces
spkcount_on_conv = zeros(length(keys_cell), length(time));
spkcount_off_conv = zeros(length(keys_cell), length(time));
for ii = 1:length(keys_cell)
    spkcount_on_conv(ii,:) = conv(spkcount_on(ii,:), gausswin(50),'same')*500;
    spkcount_off_conv(ii,:) = conv(spkcount_off(ii,:), gausswin(50),'same')*500;
end
err_on = std(spkcount_on_conv)/sqrt(size(spkcount_on,1));
err_off = std(spkcount_off_conv)/sqrt(size(spkcount_off,1));
% spkcount_on_bin_norm = spkcount_on_bin/max(spkcount_off_bin);
% spkcount_off_bin_norm = spkcount_off_bin/max(spkcount_off_bin);
fig = Figure(101,'size',[73,35]);
patch([time, wrev(time)],[spkcount_on_bin+err_on, wrev(spkcount_on_bin-err_on)],[0.8,0.8,0.8],'LineStyle','None'); hold on

patch([time, wrev(time)],[spkcount_off_bin+err_off, wrev(spkcount_off_bin-err_off)],[1,0.65,0.65],'LineStyle','None');

plot(time,spkcount_on_bin,'k');
plot(time,spkcount_off_bin,'r'); 
ylim([0,80]); 
xlim([-50,100]);

Ylim = get(gca,'YLim');
h = patch([0,20,20,0],[Ylim(1) Ylim(1),Ylim(2),Ylim(2)],'c');
uistack(h,'bottom');

xlabel('Time(ms)'); ylabel('Firing rate (Hz)'); legend('LED stimulation', '','','spike density with LED on', 'spike density with LED off');
title(['Pyramidal cells-' layer]);
fig.cleanup
fig.save('spkDensity_invitro')