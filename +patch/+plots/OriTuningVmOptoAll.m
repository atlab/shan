function h = OriTuningVmOptoAll(varargin)
%h = OriTuningvm(key)
%
% Plots orientation tuning of spikes for OriTrials
restr = fetch(patch.Cell & 'patch_type="whole cell"');
keys = fetch(patch.OriVecOpto & varargin & restr, '*');

vm_tuning_off = mean(cat(1,keys.vm_mean_off))*1000;
vm_tuning_on = mean(cat(1,keys.vm_mean_on))*1000;


oris = keys(1).oris*pi/180;
    
oris(length(oris)+1) = oris(1);
vm_tuning_on(length(vm_tuning_on)+1) = vm_tuning_on(1);
vm_tuning_off(length(vm_tuning_off)+1) = vm_tuning_off(1);
fig1 = Figure(101,'size',[100,80]); 
h1 = polar(oris, vm_tuning_off); hold on
set(h1, 'color','r', 'linewidth',2)
h2 = polar(oris, vm_tuning_on);
set(h2, 'color','b','linewidth',2)
legend('LED off', 'LED on', 'Location','NorthEast');
fig1.cleanup; 
% fig1.save('vmTuning')

fig2 = Figure(102,'size',[60,60]);
plot([keys.vm_mean_cell_off]*1000, [keys.vm_mean_cell_on]*1000, 'b.', 'MarkerSize', 15); 
h3 = refline(1);
set(h3,'color', 'k','linestyle','--');
ylabel('\DeltaVm with LED on(mV)')
xlabel('\DeltaVm with LED off(mV)' )
fig2.cleanup; 
% fig2.save('vmNumOnOff')