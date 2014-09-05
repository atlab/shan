function TraceCC(varargin)
% plot single traces
%   single traces under certain conditions

keys = fetch(slicepatch.TraceCC & varargin);

for iKey = keys'
    key = fetch(slicepatch.TraceCC & iKey, '*');
    figure
    plot(key.time, key.trace)
end


