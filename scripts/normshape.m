function y = normshape(x,x0,g,w,b)
% gaussian shape function
% Input: x: data, can be a vector; x0: center; g: gain; w: width; b: baseline
% Output: y
% 2014-07-09 SS

y = g*exp(-(x-x0).^2/2/w^2)+b;


end

