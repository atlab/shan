function linkAxes(fig,spec)
% Link all axes limits in figure
% spec = 'x','y','xy',or 'off'
% default is gcf and 'x'

if nargin==0
    fig=gcf;
    spec='x';
end

if nargin==1
    spec='x';
end

ax = findobj(fig,'type','axes');
for i=1:length(ax)
    if strcmp(get(ax(i),'tag'),'legend')
        ax(i)=nan;
    end
end
    ax(isnan(ax))=[];
linkaxes(ax,spec);
