function x = cutArray(x,len)
%CUTARRAY cut an array to a certain length
%   len is the final length of the mat

x = x(1:len);
if size(x,1)==1
    x = x';
end


