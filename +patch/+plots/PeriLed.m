function h = PeriLed(varargin)
% h = PeriLed(key)
% subplot1: vm without spikes around the led stimulation
% subplot2: spike raster around the led stimulation
% subplot3: firing rate around the led stimulation
% SS 2014-02-19
keys = fetch(patch.PeriLed & varargin)';
key1 = keys(1);
[vm,win] = fetch1(patch.PeriLed & key1, 'peri_led_vm', 'peri_led_win');
sz = 5000;
vMat = zeros(length(keys),sz);
for ii = 1:length(keys)
    [vm,led] = fetch1(patch.PeriLed & keys(ii), 'peri_led_vm','peri_led_led');
    idx = find(diff(led)==1); idx = idx(1);
    vm_plus = vm(idx:idx+sz/2-1);
    vm_minus = vm(idx-sz/2:idx-1);
    vm = [vm_minus;vm_plus];
    vMat(ii,:) = vm;
end

vMat = bsxfun(@minus,vMat,vMat(:,1));
temp = vMat(:,2000);
idx = temp<0.1;
vMat = vMat(idx,:);

meanVm = mean(vMat)*1000;
semVm = std(vMat)/sqrt(length(keys))*1000;

figure; plot(meanVm); hold on
plot(meanVm+semVm,'.');
plot(meanVm-semVm,'.');
ylim([-10,10])

