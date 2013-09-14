function [height,width] = subplot_square(ntot,isubplot)
% function [height,width] = subplot_square(ntot,isubplot)

width = ceil(sqrt(ntot));
height = ceil(ntot/width);

subplot(height,width,isubplot);