function binned = assign_to_bins(data,bins)
% function binned = assign_to_bins(data,bins)
% bins are actually bin edges

binned = nan(size(data));
for i = 1:numel(data)
    x = data(i);
    binned(i) = find(bins < x,1,'last');
end