% Make lookup table for PTB based on a given monitor gamma value
gamma = 1.8;
x = linspace(0,1,256)';
y = x.^(1/gamma);
LUT = [y y y];
plot(y)