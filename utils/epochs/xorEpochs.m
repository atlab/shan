function t = xorEpochs(t1,t2);

if isempty(t1) | isempty(t2)
    t=[];
    return;
end


temp = intersectEpochs(t1,t2);

if isempty(temp)
    t=unionEpochs([t1;t2]);
    return;
end

a = [ [0 ; temp(:,2)] [temp(:,1) ; max([t1(:,2);t2(:,2)])+1] ];

b = intersectEpochs(a,t1);
c = intersectEpochs(a,t2);

t=unionEpochs([b;c]);
 