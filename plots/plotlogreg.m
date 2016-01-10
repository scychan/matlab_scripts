function [b_lr,dev,stats] = plotlogreg(x,y,showplot,b_lr)
% OPTION 1: COMPUTE THE REGRESSION:
% function [b_lr,dev,stats] = plotlogreg(x,y[,showplot])
% 
% OPTION 2: DO NOT COMPUTE THE REGRESSION:
% plotlogreg([],[],showplot,b_lr)

if ~exist('showplot','var')
    showplot = 1;
end

% logistic regression
if exist('b_lr','var')
    dev = [];
    stats = [];
else
    [b_lr,dev,stats] = glmfit(x,y,'binomial','link','logit');
end

% plot the fitted line
if showplot
    xlims = get(gca,'xlim');
    xx = linspace(xlims(1),xlims(2));
    yfit = glmval(b_lr,xx,'logit');
    plot(xx,yfit,'-')
end