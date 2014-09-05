function ind = spkDetect(vt,vm)

spkThresh = .003; %volts
minISI=.0016; %sec

dt = mean(diff(vt));
fs = round(1/dt);

vHigh = ezfilt(vm,150,fs,'high');
vLow = ezfilt(vm,25,fs,'low');
vDiff = diff(vm);

if size(vHigh,1)~=size(vm,1)
    vHigh = vHigh';
    vLow = vLow';
end

% loose criteria based on rise time or filtered spike height
spk = vDiff>.004 | vDiff>nanstd(vDiff)*5 | vHigh(2:end)>.004 | vHigh(2:end)>nanstd(vHigh)*5;

% restrict to peaks
peak = vDiff(1:end-1) > 0 & vDiff(2:end) < 0;
spk = spk(2:end) & peak;
spk = spk & vm(2:end-1) > nanmedian(vm);

% find indices
ind = find(spk) + 1;

% remove indices that occur within minISI of each other
ind(diff(ind) < fs*minISI)=[];

% remove indices that are less than spkThresh above low-pass filtered signal
ind(vm(ind) - vLow(ind) < spkThresh) = [];

% figure;
% plot(vt,vm)
% hold on
% plot(vt(ind),vm(ind),'gx')