function equalize_subplot_axes(x_or_y, figure_number, m, n, subplots, range)
% function uniform_subplot_axes(x_or_y, figure_number, m, n, [subplots], [range])
%   x_or_y   - 'x','y', or 'xy'
%   m        - number of rows of subplots
%   n        - number of columns of subplots
%   subplots -  [vector]  - indices of the subplots that you want to equalize
%               {cell of vectors} - sets of subplots to equalize within
%               'r'       - equalize within each row
%               'c'       - equalize within each column
%               (optional - defaults to 'all subplots' if empty)
%
%   range    - [axis_lower_limit axis_upper_limit]
%               (optional - defaults to [min max] across subplots)

figure(figure_number)
num_subplots = m*n;

if ~exist('subplots','var') || isempty(subplots)
    subplots{1} = 1:num_subplots;
elseif ~iscell(subplots)
    if subplots == 'r' % equalize within the rows
        clear subplots
        for row = 1:m
            subplots{row} = (row-1)*n + (1:n);
        end
    elseif subplots == 'c' % equalize within the columns
        clear subplots
        for col = 1:n
            subplots{col} = (1:n:m*n) + (col-1);
        end
    else % subplots is just a single vector
        temp = subplots; clear subplots
        subplots{1} = temp;
    end
end
ncells = length(subplots);

for axis = x_or_y
    
    for icell = 1:ncells
        
        if ~exist('range','var')
            % figure out the min and max values
            minval = Inf;
            maxval = -Inf;
            for iplot = subplots{icell}
                subplot(m,n,iplot)
                limits = eval(['get(gca,''' axis 'lim'')']);
                if limits(1) < minval
                    minval = limits(1);
                end
                if limits(2) > maxval
                    maxval = limits(2);
                end
            end
        else
            minval = range(1);
            maxval = range(2);
        end
        
        % set the min and max for every plot
        for iplot = subplots{icell}
            subplot(m,n,iplot)
            eval([axis 'lim([minval maxval])']);
        end
    end
end