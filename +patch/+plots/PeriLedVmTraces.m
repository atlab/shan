
function PeriLedVmTraces(varargin)

keys = varargin;
keys_rel = fetch(patch.Patch & (patch.Cell & 'patch_type="whole cell"'));
[time_on, vm_on] = fetchn(patch.PeriLedTrial & keys & keys_rel & 'peri_led_stat=1', 'peri_led_time','peri_led_vm_norm');
vm_off = fetchn(patch.PeriLedTrial & keys & keys_rel & 'peri_led_stat=-1', 'peri_led_vm_norm');

minlen_on = min(cellfun(@length, vm_on));
minlen_off = min(cellfun(@length, vm_off));
minlen = min(minlen_on, minlen_off);
 
vm_on = cellfun(@(x) patch.utils.cutArray(x,minlen), vm_on, 'Un', 0);
vm_off = cellfun(@(x) patch.utils.cutArray(x,minlen), vm_off, 'Un', 0);
vm_off_all =horzcat(vm_off{:})*1000;
vm_on_all = horzcat(vm_on{:})*1000;

vm_off_all = bsxfun(@plus, vm_off_all, 20*(1:size(vm_off_all,2)));
vm_on_all = bsxfun(@plus, vm_on_all, 20*(1:size(vm_on_all,2)));

time = [time_on{1}];
time = patch.utils.cutArray(time,minlen);


figure; 
subplot 121
plot(time,vm_off_all,'k'); hold on
yLim = get(gca,'YLim');
h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
uistack(h,'bottom');


subplot 122

plot(time,vm_on_all','k'); hold on
yLim = get(gca,'YLim');
h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
uistack(h,'bottom');
