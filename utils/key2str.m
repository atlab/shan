function t = key2str(key)
names=fieldnames(key);
names=names(1:min(3,length(names)));
t='';
for i=1:length(names)

    n=names{i};
    us=findstr('_',n);
    if ~isempty(us)
        n(us)=' ';
    end

    f=getfield(key,names{i});
    if isnumeric(f)
        f=num2str(f);
    end

    t=[t n ':' f '  '];
end
