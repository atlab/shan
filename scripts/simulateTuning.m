% simulate tuning functions, figure out the relationship among gain
% control (multiplication), subtraction, and sharpening.

% orientations
oris = 0:10:180;
prefOri = 90;
gain = 10;
gain2 = 10;
width = 20;
width2 = 20;
baseline = 5;
baseline2 = 0;

% simulated response with random noise
response = normshape(oris,prefOri,gain,width,baseline) + 0.3*gain*(-1+2*rand(size(oris)));
response2= normshape(oris,prefOri,gain2,width2,baseline2) + 0.3*gain*(-1+2*rand(size(oris)));
response2(response2<0)=0;

% fit the simulated data with gaussian-shape function
ft = fittype('normshape(x,x0,g,w,b)');
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,0,0],...
               'Upper',[Inf,max(response)],...
               'StartPoint',[60,5,20,3]);
f = fit(oris', response', ft,fo);
f2 = fit(oris', response2', ft,fo);

figure; plot(oris, response,'o'); hold on
plot(f);
plot(oris,response2,'ko');
plot(f2)
