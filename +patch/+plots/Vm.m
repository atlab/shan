function h = Vm(key)
% h = patch.plot.Vm(key)
%
% h: handle(s) to lines

assert(length(fetch(patch.Recording & key))==1, 'One recording at a time please.');

c = {'b','k'};

key = fetch(patch.Ephys & key);

for i=1:length(key)
    
    [vt,vm,fs] = patch.utils.cleanVm(key(i));
    if ~patch.utils.isWholeCell(fetch(patch.Ephys & key(i)))
        vm = ezfilt(vm,150,fs,'high');
    end
    plot(vt,vm*1000,c{key(i).amp});
end