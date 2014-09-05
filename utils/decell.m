function c = decell(C)

while iscell(C)
    if isempty(C)
        C = [];
    else
        C = C{:};
    end
end
c = C;
