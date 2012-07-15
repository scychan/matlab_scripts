% [counts,ymeans,ystds,bincenters,binedges,xbins,ybins,inbins] = bincount(x,y[,bins])
% 
% Bin "y" according to corresponding values of "x".
% 
% OPTIONS:  [bins] can be given as an integer [nbins] or as a vector [binedges]
%           Defaults to nbins=10
% 
% INPUTS:
%   x = vector, same length as y
%   y = vector that will be binned according to corresponding values of x
% 
% OUTPUTS:
%   counts = vector with number of elements in each bin
%   ymeans = vector with mean of y in each bin
%   ystds = vector with std of y in each bin
%   binedges = the values that were used to bin x
%   bincenters = the centers of the x-bins
%   xbins = cell with the values of x in each bin
%   ybins = cell with the values of y in each bin
%   inbins = cell containing logical vector indicating membership in each bin
% 
% Stephanie Chan 2012

function [counts,ymeans,ystds,bincenters,binedges,xbins,ybins,inbins] = bincount(x,y,bins)

if ~exist('bins','var')
    bins = 10;
end

if numel(bins)==1
    nbins = bins;
    xmin = min(x);
    xmax = max(x);
    binsize = (xmax-xmin)/10;
    binedges = xmin:binsize:xmax;
elseif length(varargin)==2
    binedges = bins;
    nbins = length(binedges)-1;
end

bincenters = nan(nbins,1);
counts = nan(nbins,1);
ymeans = nan(nbins,1);
ystds = nan(nbins,1);
inbins = cell(nbins,1);
xbins = cell(nbins,1);
ybins = cell(nbins,1);

for ibin = 1:nbins
    bincenters(ibin) = (binedges(ibin) + binedges(ibin+1))/2;
    
    inbin = x>binedges(ibin) & x<binedges(ibin+1);
    xbin = x(inbin);
    ybin = y(inbin);
    
    counts(ibin) = sum(inbin);
    ymeans(ibin) = mean(ybin);
    ystds(ibin) = std(ybin);
    
    inbins{ibin} = inbin;
    xbins{ibin} = xbin;
    ybins{ibin} = ybin;
end