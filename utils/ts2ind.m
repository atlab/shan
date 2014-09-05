function ind = ts2ind(t,ts,dt,mod)
% ind = ts2ind(t,ts, dt)
%
% t: scalar or matrix of time(s) to find index 
% ts: a relatively uniformly-sampled vector of times
% dt: sampling interval
% mod: if 'nan', ind for values of t outside of the range of ts are returned as nan
%      if 'extrap', ind for values of t outside of range of ts are returned
%      as the boundary ind
%
% ind: the index into ts that gives the closest time to t (same size as t)
%
% Faster than [~,ind] = min(abs(t-ts)) because it considers only a limited 
% range of times around ts (+/-win indices)

if nargin == 2 || isempty(dt)
    dt = median(diff(ts));
end

if nargin<4
    mod='';
end

if isempty(t)
    ind=[];
    return
end

sz=size(t);
t=t(:);
win = 1000;
for i=1:length(t)
    if (t(i)<ts(1) || t(i)>ts(end)) && strcmp(mod,'nan');
        ind(i)=nan;
        continue
    elseif (t(i)<ts(1) && strcmp(mod, 'extrap'))
        ind(i)=1;
        continue
    elseif (t(i)>ts(end) && strcmp(mod, 'extrap'))
        ind(i)=length(ts);
        continue
    end
        
    seg = round(t(i)/dt) - round(ts(1)/dt) + [-win:win];
    seg(seg<1)=1; seg(seg>length(ts)) = length(ts);
    
    [d,x] = min(abs(ts(seg)-t(i)));
    if d > dt*2
        warning(['Closest index is ' num2str(round(d/dt)) '*dt away from time ' num2str(t(i)) '. Looking for global min...']);
        [d,x] = min(abs(ts-t(i)));
        ind(i) = x;
        if d > dt*2
            warning(['Globally, closest index is ' num2str(round(d/dt)) '*dt away from time ' num2str(t(i))]);
        end
    else
        ind(i) = seg(x);
    end
end
ind = reshape(ind,sz);

