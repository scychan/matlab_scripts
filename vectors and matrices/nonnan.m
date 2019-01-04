function output = nonnan(input)
% function output = nonnan(input)
% 
% Return, as a vector, all the non-NaN elements of the input 
% (input can be a vector or a matrix).

output = input(~isnan(input));