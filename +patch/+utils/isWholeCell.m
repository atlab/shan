function x = isWholeCell(key)

for i=1:length(key)
    x(i) = logical(strcmp(fetch1(patch.Cell & key(i),'patch_type'),'whole cell'));
end
