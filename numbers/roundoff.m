function y = roundoff(x,k)
% function y = roundoff(x,k)
% 
% Round off x to the nearest multiple of k.
%  x can be a matrix
% E.g. roundoff(1.0351,0.01) = 1.04

y = round(x./k) * k;
