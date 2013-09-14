function meanvarplot(means,vars)

means = horz(means);
vars = horz(vars);

npoints = length(means);

hold on
scatter(1:npoints,means,'O')
scatter(1:npoints,means-vars,'.')
scatter(1:npoints,means+vars,'.')
plot(repmat(1:npoints,2,1),[means;means-vars])
plot(repmat(1:npoints,2,1),[means;means+vars])