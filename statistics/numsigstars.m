function stars = sigstars(pval,show_direction)
% n = numsigstars(pval[, show_direction])
%
% show_direction
%  - optional (defaults to 0)
%  => if true, also check for p > 0.95, and return symbols as '+' or '-'

if ~exist('show_direction','var')
    show_direction = 0;
end

% which symbol
symbol = '*';
if show_direction
    if pval < 0.05
        symbol = '+';
    elseif pval > 0.95
        symbol = '-';
        pval = 1 - pval;
    end
end

% how many stars
sigthresh = [0.05, 0.01, 0.005, 0.001, 0.0005, 0.0001, 0.00005, 0.00001];
nstars = 0;
for i = 1:length(sigthresh)
    if pval <= sigthresh(i)
        nstars = i;
    end
end

% make the string
stars = repmat(symbol,1,nstars);