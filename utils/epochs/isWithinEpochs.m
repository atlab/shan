function ind = isWithinEpochs(t,epochs)
% ind = isWithinEpochs(t,epochs)
t = sort(t);
ind=zeros(length(t),1);
for i = 1:length(t)
    s = max(find(epochs(:,1)<t(i)));
    if ~isempty(s)
        if epochs(s,2) > t(i)
            ind(i)=1;
        end
    end
end
