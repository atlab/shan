function OriTuningVmOpto(type,varargin)
%h = OriTuningVm(key)
%
% Plots orientation tuning of Vm for OriTuningOpto

% load data

keys = fetch(patch.OriTuningOpto & varargin & (patch.Cell & 'patch_type="whole cell"'));

for iKey = keys'
    
    [oris, vm_tuning_on, vm_tuning_off] = fetch1(patch.OriTuningOpto & iKey, 'oris','vm_tuning_on','vm_tuning_off');
    
    oris = oris*pi/180;
    
    if strcmp(type, 'polar')
        oris(length(oris)+1) = oris(1);
        vm_tuning_on = cellfun(@mean,vm_tuning_on)';
        vm_tuning_on(length(vm_tuning_on)+1) = vm_tuning_on(1);
        vm_tuning_off = cellfun(@mean,vm_tuning_off)';
        vm_tuning_off(length(vm_tuning_off)+1) = vm_tuning_off(1);
        figure;
        polar(oris, vm_tuning_off, 'k'); hold on
        polar(oris, vm_tuning_on);
        legend('LED off', 'LED on');
    elseif strcmp(type, 'dot')
        vm_tuning_on_mean = cellfun(@mean,vm_tuning_on)';
        vm_tuning_off_mean = cellfun(@mean,vm_tuning_off)';
        vm_tuning_on_ste = cellfun(@std,vm_tuning_on)'./sqrt(cellfun(@length,vm_tuning_on)');
        vm_tuning_off_ste = cellfun(@std,vm_tuning_off)'./sqrt(cellfun(@length,vm_tuning_off)');
        figure;
        errorbar(oris, vm_tuning_off_mean, vm_tuning_off_ste, 'k'); hold on
        errorbar(oris, vm_tuning_on_mean, vm_tuning_on_ste);
        legend('LED off','LED on');
    end

end