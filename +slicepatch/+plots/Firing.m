function Firing(varargin)
% Show the firing trace of a cell, with LED stimulation
%
keys = fetch(slicepatch.Firing & varargin)';
for key = keys
    trace = fetch(slicepatch.Firing & key, '*');
    figure; set(gcf, 'Position',[500,500,500,250]);
    plot(trace.time, trace.trace,'k');
    idx1 = find(diff(trace.led)==1);
    idx2 = find(diff(trace.led)==-1);
    Ylim = get(gca, 'YLim');
    h = patch([trace.time(idx1),trace.time(idx2),trace.time(idx2),trace.time(idx1)],[Ylim(1) Ylim(1),Ylim(2),Ylim(2)],'c');
    uistack(h,'bottom');
    key
    in=input('Press Enter to continue:');

    if isempty(in)
        continue
    else
        break
    end
end
