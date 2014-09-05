function t = totalEpochTime(E)

t=0;
for i=1:size(E,1)
    t=t+E(i,2)-E(i,1);
end
