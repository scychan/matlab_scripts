function v = categoricalrnd(p,n)

cumsump = [0 horz(cumsum(p))];
nbins = length(p);

r = rand(n,1);
v = nan(size(r));
for bin = 1:nbins
    v(cumsump(bin) <= r & r < cumsump(bin+1)) = bin;
end
