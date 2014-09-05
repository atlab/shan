function plotEpochs(e,y)

assert(size(e,2)~=2,'Epochs must be n x 2 matrix of start and end x-values');

y = y*ones(size(e));

line(e',y','color','c','linewidth',5);