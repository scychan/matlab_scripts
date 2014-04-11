function reginfo = regress_and_plot(x,y)
% x = regressor (vector)
% y = data to be regressed (vector)

% make sure x and y are column vectors
x = x(:);
y = y(:);

% do the regression
[b,bint,r,rint,stats] = regress(y,[x ones(size(x))]);
reginfo = var2struct(b,bint,r,rint,stats);

% scatter plot the points
scatter(x,y)

% draw the regression line
hold on
xlims = get(gca,'xlim');
plot(xlims,xlims*b(1) + b(2));