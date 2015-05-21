function output = softmaxRL(v, beta)
% v = vector to be converted to 
% beta = inverse temperature

if ~exist('beta','var')
    beta = 1;
end

numerators = exp(v.*beta);
denominator = sum(numerators);

output = numerators / denominator;