function t = removeEpochs(t1,t2)
% removes epochs in t2 from t1


c = [t1 ; t2];
if isempty(c)
    t=[];
    return
end

[t1(:,1) , ind]=sort(t1(:,1));
t1(:,2)=t1(ind,2);

[t2(:,1) , ind]=sort(t2(:,1));
t2(:,2)=t2(ind,2);

t=[];k=1;j=1;
for i=1:length(t1(:,1))
    if j > length(t2(:,1))
        t(k,:) = t1(i,:);
        k=k+1;
    elseif t1(i,1) < t2(j,1)
        t(k,1) = t1(i,1);
        if t1(i,2) < t2(j,1)
            t(k,2) = t1(i,2);
        else
            t(k,2) = min ([t1(i,2) t2(j,1)]);
        end
        k=k+1;
    elseif t1(i,2) >= t2(j,2)
        t(k,1) = max([t1(i,1) t2(j,2)]);
        t(k,2) = t1(i,2);
        j=j+1;
        k=k+1;
    end
end     

if ~isempty(t)
    badind=find(t(:,1)==t(:,2));
    t(badind,:)=[];
end
