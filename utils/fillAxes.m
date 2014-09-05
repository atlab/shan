function fillAxes(h)
% Set all axes limits in specified figure or axes to x/y range of plotted data
% Default is gcf
if nargin==0
    h=gcf;
end

if strcmp(get(h,'type'),'figure')
    ax = findobj(h,'type','axes');
else
    ax = h;
end

for i=1:length(ax)
    if strcmp(get(ax(i),'tag'),'legend')
        continue
    end
    h = findobj(ax(i),'-property','xdata','type','line');
    xL=[];yL=[];
    for j=1:length(h)
        xL(j,:) = [min(get(h(j),'xdata')) max(get(h(j),'xdata'))];
        yL(j,:) = [min(get(h(j),'ydata')) max(get(h(j),'ydata'))];
    end
    xL = [min(xL(:)) max(xL(:))];
    yL = [min(yL(:)) max(yL(:))];
    if ~isempty(xL) && ~isempty(yL) && diff(xL)>0 && diff(yL)>0
        set(ax(i),'xlim',xL,'ylim',yL)
    end
end
    