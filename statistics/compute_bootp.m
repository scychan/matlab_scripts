function [bootp, bootsamples] = compute_bootp(data,greaterthan_or_lessthan_or_twosided,threshold,nboot)
% function [bootp, bootsamples] = compute_bootp(data,greaterthan_or_lessthan_or_twosided,threshold[,nboot])
% 
% default nboot = 10,000

N = length(data);
if ~exist('nboot','var')
    nboot = 10000;
end

sel = squeeze(RandSel(1:N,[nboot N]));
bootsamples = mean(data(sel),2);
switch greaterthan_or_lessthan_or_twosided
    case 'greaterthan'
        bootp = sum(bootsamples < threshold)/nboot;
    case 'lessthan'
        bootp = sum(bootsamples > threshold)/nboot;
    case 'twosided'
        bootp = sum(bootsamples < threshold)/nboot;
        if bootp > 0.5, bootp = 1-bootp; end
        bootp = 2*bootp;
end