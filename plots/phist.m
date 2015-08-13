function output = phist(data,bins)
% make histogram with y-axis as *proportion* of data, rather than number of
% dataspoints

ndata = length(data);
if exist('bins','var')
    datahist = hist(data,bins);
else
    [datahist,bins] = hist(data);
end
output = datahist/ndata;
bar(bins,output)