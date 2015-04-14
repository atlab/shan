function h = OriTuningSpkOptoAll(varargin)
%h = OriTuningSpk(key)
%
% Plots orientation tuning of spikes for OriTrials

keys = fetch(patch.OriVecOpto & varargin, '*');

spk_tuning_off = mean(cat(1,keys.spk_mean_off));
spk_tuning_on = mean(cat(1,keys.spk_mean_on));


oris = keys(1).oris*pi/180;
    
oris(length(oris)+1) = oris(1);
spk_tuning_on(length(spk_tuning_on)+1) = spk_tuning_on(1);
spk_tuning_off(length(spk_tuning_off)+1) = spk_tuning_off(1);
fig1 = Figure(101,'size',[100,80]); 
h1 = polar(oris, spk_tuning_off); hold on
set(h1, 'color','r', 'linewidth',2)
h2 = polar(oris, spk_tuning_on);
set(h2, 'color','b','linewidth',2)
legend('LED off', 'LED on', 'Location','NorthEast');
fig1.cleanup; 
% fig1.save('SpkTuning')

fig2 = Figure(102,'size',[60,60]);
plot([keys.spk_mean_cell_off], [keys.spk_mean_cell_on], 'b.', 'MarkerSize', 15); 
h3 = refline(1);
set(h3,'color', 'k','linestyle','--');
ylabel('mean firing rate with LED on')
xlabel('mean firing rate with LED off' )
fig2.cleanup; 
% fig2.save('SpkNumOnOff')
   