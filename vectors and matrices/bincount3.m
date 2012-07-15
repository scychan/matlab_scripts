% [counts,zmeans,zstds,xbincenters,ybincenters,xbinedges,ybinedges,xbins,ybins,zbins,inbins] = bincount3(x,y,z[,xbinparam,ybinparam])
% 
% Bin "z" according to corresponding values of "x" and "y".
% 
% OPTIONS:  
% 
% INPUTS:
%   x, y, z = vectors of the same length
%   [xbinsparam] can be given as an integer [nbins] or as a vector [binedges]
%           Defaults to nbins=10
%   [ybinsparam] can be given as an integer [nbins] or as a vector [binedges]
%           Defaults to nbins=10
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

function [counts,zmeans,zstds,xbincenters,ybincenters,xbinedges,ybinedges,xbins,ybins,zbins,inbins] = bincount3(x,y,z,xbinsparam,ybinsparam)

if ~exist('xbinsparam','var')
    xbinsparam = 10;
end
if ~exist('ybinsparam','var')
    ybinsparam = 10;
end

if numel(xbinsparam)==1
    nbinsx = xbinsparam;
    xmin = min(x);
    xmax = max(x);
    binsizex = (xmax-xmin)/nbinsx;
    xbinedges = xmin:binsizex:xmax;
else
    xbinedges = xbinsparam;
    nbinsx = length(binedgesx)-1;
end

if numel(ybinsparam)==1
    nbinsy = ybinsparam;
    ymin = min(y);
    ymax = max(y);
    binsizey = (ymax-ymin)/nbinsy;
    ybinedges = ymin:binsizey:ymax;
else
    ybinedges = ybinsparam;
    nbinsy = length(binedgesy)-1;
end

xbincenters = (xbinedges(1:end-1) + xbinedges(2:end)) / 2;
ybincenters = (ybinedges(1:end-1) + ybinedges(2:end)) / 2;

counts = nan(nbinsx,nbinsy);
zmeans = nan(nbinsx,nbinsy);
zstds = nan(nbinsx,nbinsy);
inbins = cell(nbinsx,nbinsy);
xbins = cell(nbinsx,nbinsy);
ybins = cell(nbinsx,nbinsy);
zbins = cell(nbinsx,nbinsy);

for ibinx = 1:nbinsx
    for ibiny = 1:nbinsy

        inbin = x>xbinedges(ibinx) & x<xbinedges(ibinx+1) ...
                    & y>ybinedges(ibiny) & y<ybinedges(ibiny+1);
        xbin = x(inbin);
        ybin = y(inbin);
        zbin = z(inbin);

        counts(ibinx,ibiny) = sum(inbin);
        zmeans(ibinx,ibiny) = mean(zbin);
        zstds(ibinx,ibiny) = std(zbin);

        inbins{ibinx,ibiny} = inbin;
        xbins{ibinx,ibiny} = xbin;
        ybins{ibinx,ibiny} = ybin;
        zbins{ibinx,ibiny} = zbin;
    end
end