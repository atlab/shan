function OriTuningVmOpto(varargin)
%h = OriTuningVm(key)
%
% Plots orientation tuning of Vm for OriTuningOpto

% load data

keys = fetch(patch.OriTuning & varargin,'*');

% for ii = 1:length(keys)
%     key =keys(ii);
%     mean_vm_on = mean(key.vm_tuning_on,2);
%     mean_vm_off = mean(key.vm_tuning_off,2);
%     sem_vm_on = std(key.vm_tuning_on,[],2)/sqrt(length(key.vm_tuning_on));
%     sem_vm_off = std(key.vm_tuning_off,[],2)/sqrt(length(key.vm_tuning_off));
%     
%     figure; hold on
%     errorbar(key.oris,mean_vm_on, sem_vm_on);
%     errorbar(key.oris,mean_vm_off, sem_vm_off,'g');
%     
%     mean_spk_on = mean(key.spk_tuning_on,2);
%     mean_spk_off = mean(key.spk_tuning_off,2);
%     sem_spk_on = std(key.spk_tuning_on,[],2)/sqrt(length(key.spk_tuning_on));
%     sem_spk_off = std(key.spk_tuning_off,[],2)/sqrt(length(key.spk_tuning_off));
%     
%     figure; hold on
%     errorbar(key.oris,mean_spk_on, sem_spk_on);
%     errorbar(key.oris,mean_spk_off, sem_spk_off,'g');
% end
for ii = 1:length(keys)
    key =keys(ii);
    mean_vm = mean(key.vm_tuning,2)*1000;
    
    sem_vm = std(key.vm_tuning,[],2)/sqrt(length(key.vm_tuning))*1000;
   
    figure; hold on
    errorbar(key.oris,mean_vm, sem_vm);
   
    
    mean_spk = mean(key.spk_tuning,2);
    
    sem_spk = std(key.spk_tuning,[],2)/sqrt(length(key.spk_tuning));
    figure; hold on
    errorbar(key.oris,mean_spk, sem_spk); ylim([0,1.5]);
end