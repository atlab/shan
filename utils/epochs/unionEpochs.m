function t = unionEpochs(c)
% t = unionEpochs(c);
% c: m by 2 matrix of start (:,1) and end (:,2) times 
% t: returns start and end times of all discrete epochs in c
% Overlapping epochs within c are merged into a single epoch.



if isempty(c) 
    t=[];
    return
end

[c(:,1) , ind]=sort(c(:,1));

c(:,2)=c(ind,2);

k=1;
blockStart=-1; blockEnd=-1;
for i=1:length(c)
    if c(i,1) > blockEnd
        blockStart = c(i,1);
    end
    if c(i,2) > blockEnd
        blockEnd = c(i,2);
    end
    if i==length(c)
        t(k,:) = [blockStart blockEnd];
    elseif c(i+1,1) > blockEnd
        t(k,:) = [blockStart blockEnd];
        k=k+1;
    end
end

