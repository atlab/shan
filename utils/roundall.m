function X = roundall(x,target,rounding)

% function X = roundall(x)
%
% roundall rounds all real numbers to the most proximate decimal
% nargin 2 targets the rounding
%
% MF 2011-08-23

if nargin<3
    rounding = 'round';
end

if nargin<2
    X = eval([rounding '(x.*10.^abs(floor(log10(x))))./10.^abs(floor(log10(x)))']);
else
    X = eval([rounding '(x/target)*target']);
end