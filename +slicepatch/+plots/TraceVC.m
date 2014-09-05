function TraceVC(varargin)
% plot single traces
%   single traces under certain conditions

keys = fetch(slicepatch.TraceVC & varargin);

for iKey = keys'
    key = fetch(slicepatch.TraceVC & iKey, '*');
    figure
    plot(key.time, key.trace)
end

