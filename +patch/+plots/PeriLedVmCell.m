function PeriLedVmCell(varargin)

% scatter plot of mean Vm, led on versus led off, with visual stimulus

restriction = fetch(patch.RecordingNote & varargin & 'recording_caveat=0' & patch.PeriLedTrial);
cell_res = fetch(patch.Cell & restriction & 'cell_type_morph="pyr"' & 'patch_type="whole cell"');

vm_on_inh_mat = zeros(1,length(cell_res));
vm_off_inh_mat = zeros(1,length(cell_res));
vm_on_exc_mat = zeros(1,length(cell_res));
vm_off_exc_mat = zeros(1,length(cell_res));

p_val_exc = zeros(1,length(cell_res));
p_val_inh = zeros(1,length(cell_res));


for ii = 1:length(cell_res)
    iKey = cell_res(ii);
    keys_on = fetch(patch.PeriLedTrial & iKey & 'peri_led_stat=1');
    keys_off = fetch(patch.PeriLedTrial & iKey & 'peri_led_stat=-1');
    vm_on_exc = fetchn(patch.PeriLedTrialVm & iKey & keys_on, 'peri_led_vm_exc');
    vm_on_inh = fetchn(patch.PeriLedTrialVm & iKey & keys_on, 'peri_led_vm_inh');
    vm_off_exc = fetchn(patch.PeriLedTrialVm & iKey & keys_off, 'peri_led_vm_exc');
    vm_off_inh = fetchn(patch.PeriLedTrialVm & iKey & keys_off, 'peri_led_vm_inh');
    
    vm_on_exc_mat(ii) = mean(vm_on_exc);
    vm_on_inh_mat(ii) = mean(vm_on_inh);
    vm_off_exc_mat(ii) = mean(vm_off_exc);
    vm_off_inh_mat(ii) = mean(vm_off_exc);
       
    [~,p_val_exc(ii)] = ttest2(vm_on_exc, vm_off_exc);
    [~,p_val_inh(ii)] = ttest2(vm_on_inh, vm_off_inh);

end

fig = Figure(202,'size',[70,60]);

plot(vm_off_exc_mat(p_val_exc>0.05),vm_on_exc_mat(p_val_exc>0.05),'ko', 'MarkerSize',4); hold on
plot(vm_off_exc_mat(p_val_exc<0.05),vm_on_exc_mat(p_val_exc<0.05),'k.', 'MarkerSize',12);
xlabel('LED off'); ylabel('LED on')
plot(vm_off_inh_mat(p_val_inh>0.05),vm_on_inh_mat(p_val_inh>0.05),'k^','MarkerSize',4);
plot(vm_off_inh_mat(p_val_inh<0.05),vm_on_inh_mat(p_val_inh<0.05),'k^','MarkerSize',4,'MarkerFaceColor','k');

xlabel('Firing rate LED off'); ylabel('Firing rate LED on')
legend('0-40ms p>0.05','0-40ms p<0.05','40-150ms p>0.05','40-150ms p<0.05','Location','NorthWest')

% [h,p] = ttest(vm_off_inh, vm_on_inh)
% [p,h] = signrank(vm_off_inh, vm_on_inh)
% 
% [h,p] = ttest(vm_off_exc, vm_on_exc)
% [p,h] = signrank(vm_off_exc, vm_on_exc)

xlim([-0.005,0.01]); ylim([-0.005,0.01])
h2 = refline(1);
set(h2,'Color','k','LineStyle','--');

fig.cleanup; fig.save('in_vivo_vm_scatter.eps')

% fig2.cleanup; fig2.save('in_vivo_spk_off_scatter.eps')

