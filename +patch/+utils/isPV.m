function x = isPV(key)

for i=1:length(key)
    x(i) = logical(strcmp(fetch1(patch.Cell & key(i),'label'),'PV+'));
end
