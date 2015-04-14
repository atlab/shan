function SpkProb(varargin)

% plot the spiking probability as a function of LED onset Vm (to threshold)
keys_rel = fetch(patch.Cell & 'patch_type="whole cell"');
vm_to_thres = fetchn(patch.PeriLedTrial & varargin & keys_rel, 'peri_led_vm_to_thresh');
keys_on = fetch(patch.PeriLedTrial & varargin & 'peri_led_stat=1');
keys_off = fetch(patch.PeriLedTrial & varargin & 'peri_led_stat=-1');
vm_vec = linspace(min(vm_to_thres),max(vm_to_thres),9);
spk_prob_on = zeros(1,length(vm_vec)-1);
spk_prob_off = zeros(1,length(vm_vec)-1);
for ii = 1:length(vm_vec)-1
    spk_on = fetchn(patch.SpikeProb & keys_on & ['vm_to_thresh>' num2str(vm_vec(ii))] & ['vm_to_thresh<' num2str(vm_vec(ii+1))], 'spk_num');
    spk_on = logical(vertcat(spk_on{:}));
    temp = spk_on(:,4);
    spk_prob_on(ii) = mean(temp);
    spk_off = fetchn(patch.SpikeProb & keys_off & ['vm_to_thresh>' num2str(vm_vec(ii))] & ['vm_to_thresh<' num2str(vm_vec(ii+1))], 'spk_num');
    spk_off = logical(vertcat(spk_off{:}));
    temp = spk_off(:,4);
    spk_prob_off(ii) = mean(temp);
end


figure; plot(vm_vec(1:end-1),spk_prob_off,'k');
hold on; plot(vm_vec(1:end-1),spk_prob_on);