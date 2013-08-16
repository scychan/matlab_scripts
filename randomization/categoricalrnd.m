function v = categoricalrnd(p,n)
% v = categoricalrnd(p,n)
% p is the vector of probabilities (of each bin)
% n is the number of observations/samples that you want to draw / the length of v

cumsump = [0 horz(cumsum(p))];
nbins = length(p);

r = rand(n,1);
v = nan(size(r));
for bin = 1:nbins
    v(cumsump(bin) <= r & r < cumsump(bin+1)) = bin;
end
