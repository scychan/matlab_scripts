function r = bindata(E,rbin)
% function r = bindata(E,rbin)
% 
% For each row of E, divides the data into bins of size rbin, and then
% finds the sum of each bin.
% 
% E can have multiple rows/trials
% rbin is the number of timepoints in each bin

r = E(:,1:rbin:end);
[rrows,rcols] = size(r);
for ibin = 2:rbin
    addition = E(:,ibin:rbin:end);
    addcols = size(addition,2);
    zeropad = zeros(rrows,rcols-addcols);
    addition = [addition,zeropad];
    r = r + addition;
end

