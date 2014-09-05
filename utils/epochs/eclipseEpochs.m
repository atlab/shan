function t = eclipseEpochs(t1,t2);
% t = eclipseEpochs(t1,t2);
% t1: n by 2 matrix of start (:,1) and end (:,2) times 
% t2: m by 2 matrix of start (:,1) and end (:,2) times 
% t: returns start and end times of epochs in t1 or t2 that are totally encompassed by epochs in the other matrix
% Epochs within each input (t1 or t2) cannot be overlapping 
% - i.e. all t1 epochs must be nonoverlapping, and all t2 epochs must be nonoverlapping


c = [t1 ; t2];
if isempty(c)
    t=[];
    return
end


[c(:,1) , ind]=sort(c(:,1));

c(:,2)=c(ind,2);

k=1;t=[];
prevStart=c(1,1); prevEnd=c(1,2);
for i=2:length(c)
    if c(i,1) <= prevEnd & c(i,2) <= prevEnd 
        blockStart = max( c(i,1), prevStart);
        blockEnd = min( c(i,2), prevEnd);
        t(k,:) = [blockStart blockEnd];
        k=k+1;
    else
        prevStart = c(i,1);
    end
    prevEnd = max(c(i,2),prevEnd);
end
if ~isempty(t)
    badind=find(t(:,1)==t(:,2));
    t(badind,:)=[];
end
