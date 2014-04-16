function varargout = subplot_square(ntot,isubplot)
% function [height,width] = subplot_square(ntot,isubplot)

width = ceil(sqrt(ntot));
height = ceil(ntot/width);

subplot(height,width,isubplot);

if nargout == 2
    varargout{1} = height;
    varargout{2} = width;
end