function reginfo = regress_and_plot(x,y,varargin)
% function reginfo = regress_and_plot(x,y)
% 
% INPUTS:
% x = regressor (vector)
% y = data to be regressed (vector)
% 
% OPTIONAL INPUTS:
% 'regtype' - options: linear, logistic, robust
%             (default = 'linear')

argpairs = {'regtype'    'linear'};
parseargs(varargin,argpairs);

% make sure x and y are column vectors
x = x(:);
y = y(:);

% scatter plot the points
scatter(x,y)

% do the regression
switch regtype
    case 'linear'
        [b,bint,r,rint,stats] = regress(y,[x ones(size(x))]);
        reginfo = var2struct(b,bint,r,rint,stats);
                
    case 'logistic'
        [b,dev,stats] = glmfit(x,y,'binomial','link','logit');
        xx = linspace(min(x),max(x));
        yfit = glmval(b,xx,'logit');
        reginfo = var2struct(b,dev,stats);    
        
    case 'robust'
        [b,stats] = robustfit(x,y);
        reginfo = var2struct(b,stats);
end

% draw the regression line
switch regtype
    case 'linear'
        hold on
        xlims = get(gca,'xlim');
        plot(xlims,xlims*b(1) + b(2));
        
    case 'logistic'
        hold on
        plot(xx,yfit,'linewidth',2)
        ylim([0 1])
        drawacross('h',0.5')
        drawacross('v',0)
                
    case 'robust'
        hold on
        xlims = get(gca,'xlim');
        plot(xlims,xlims*b(2) + b(1));
end
       
        