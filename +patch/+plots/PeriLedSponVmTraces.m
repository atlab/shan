function h = PeriLedSponVmTraces(varargin)
% h = PeriLed(key)
% subplot1: vm without spikes around the led stimulation
% subplot2: spike raster around the led stimulation
% subplot3: firing rate around the led stimulation
% SS 2014-02-19

keys_led = fetch(patch.Led & 'led_dur>0.01' & 'led_dur<0.03');
keys_cell = fetch(patch.Cell & 'patch_type="whole cell"');
keys = fetch(patch.PeriLed & varargin & keys_led & keys_cell)';


vt = fetch1(patch.PeriLed & keys(1), 'peri_led_time');
vm = fetchn(patch.PeriLed & keys, 'peri_led_vm');

minlen = min(cellfun(@length, vm));
vm = cellfun(@(x) patch.utils.cutArray(x,minlen), vm, 'Un', 0);
vt = patch.utils.cutArray(vt,minlen);
vt = vt';
Vm = horzcat(vm{:})*1000;
figure; hold on
Vm = bsxfun(@plus, Vm, 10*(1:size(Vm,2)));
plot(vt,Vm,'k');
xlim([-0.05,0.3]);
yLim = get(gca,'YLim');
h = patch([0,0.02,0.02,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c','LineStyle','None');
uistack(h,'bottom');

