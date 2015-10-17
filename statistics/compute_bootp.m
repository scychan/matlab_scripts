function [bootp, bootsamples] = compute_bootp(data,greaterthan_or_lessthan,threshold,nboot)
% function [bootp, bootsamples] = compute_bootp(data,greaterthan_or_lessthan,threshold[,nboot])
% 
% NOTE: This is a one-sided test
% 
% default nboot = 10,000

N = length(data);
if ~exist('nboot','var')
    nboot = 10000;
end

sel = squeeze(RandSel(1:N,[nboot N]));
bootsamples = mean(data(sel),2);
switch greaterthan_or_lessthan
    case 'greaterthan'
        bootp = sum(bootsamples < threshold)/nboot;
    case 'lessthan'
        bootp = sum(bootsamples > threshold)/nboot;
end