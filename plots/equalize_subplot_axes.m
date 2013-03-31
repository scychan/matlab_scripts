function equalize_subplot_axes(x_or_y, figure_number, m, n, subplots)
% function uniform_subplot_axes(x_or_y, figure_number, m, n)
%   x_or_y   - 'x','y', or 'xy'
%   m        - number of rows of subplots
%   n        - number of columns of subplots
%   subplots - indices of the subplots that you want to equalize
%               (optional - defaults to 'all subplots')


figure(figure_number)
num_subplots = m*n;

if ~exist('subplots','var')
    subplots = 1:num_subplots;
end
    
for axis = x_or_y
    
    % figure out the min and max values
    minval = Inf;
    maxval = -Inf;
    for iplot = subplots
        subplot(m,n,iplot)
        limits = eval(['get(gca,''' axis 'lim'')']);
        if limits(1) < minval
            minval = limits(1);
        end
        if limits(2) > maxval
            maxval = limits(2);
        end
    end
    
    % set the min and max for every plot
    for iplot = subplots
        subplot(m,n,iplot)
        eval([axis 'lim([minval maxval])']);
    end
end