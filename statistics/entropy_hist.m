function H = entropy_hist(histogram,width)
% entropy of a histogram distribution

nbins = length(histogram);
histogram = histogram/sum(histogram);

log_hist = log(histogram);
log_hist(histogram==0) = log(eps);

H = -width*sum(histogram.*log_hist)
eachbin = 
for i = 1:nbins
    H = 