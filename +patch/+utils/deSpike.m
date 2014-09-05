function vi = deSpike(vt,vm,spk,spkwid)

dt = mean(diff(vt));
ind = ts2ind(spk,vt,dt);

if isempty(ind)
    vi = vm;
    return
end

win = round(spkwid/dt)/1000;

ind2 = [];
for ii = 1:length(ind)
    ind_temp = ind(ii) - win(ii)*4:ind(ii)+win(ii)*4;
    ind2 = [ind2,ind_temp];
end

ind = setdiff(1:length(vt),ind2);

vi = interp1(vt(ind),vm(ind),vt,'spline');

idx = isnan(vm);
vi(idx)=nan;




