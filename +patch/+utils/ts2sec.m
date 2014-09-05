function [s, start, badInd] = ts2sec(ts)

% convert 10MHz timestamps from Saumil's patching program (ts) to seconds (s)
% s: timestamps converted to seconds
% start: system time (in seconds) of t=0;
% badInd: bad camera indices from 2^31:2^32 in camera timestamps prior to 4/10/13

ts=double(ts);

%% find bad indices in camera timestamps and replace with linear est
if sum(ts==2^31-1) > 10
    disp('Fixing bad camera ts...');
    badInd = find(ts==2^31-1)';
    plateauStart = [badInd(1) badInd(find(diff(badInd)>1)+1)];
    plateauEnd = [badInd(diff(badInd)>1) badInd(end)];
    dt = diff(ts(setdiff(1:length(ts),badInd)));
    dtm = mean(dt(dt>quantile(dt,.01) & dt<quantile(dt,.99)));
    for i=1:length(plateauStart)
        len = plateauEnd(i) - plateauStart(i);
        ts(plateauStart(i):plateauEnd(i)) = ts(plateauStart(i)) + [0:len]*dtm;
    end
end

%%  remove wraparound
wrapInd = find(diff(ts)<0);
while ~isempty(wrapInd)
    ts(wrapInd(1)+1:end)=ts(wrapInd(1)+1:end)+2^32;
    wrapInd = find(diff(ts)<0);
end
    
%% convert to seconds and remove offset
s = ts/1E7;
start = s(1);
s = s - start;

%% if not monotonically increasing, interpolate
if any(diff(s)<=0)
    nonZero = [1 ; find(diff(s)>0)+1];
    s=interp1(nonZero,s(nonZero),1:length(s),'linear','extrap');
end

if size(s) ~= size(ts)
    s=s';
end
