function [maxval, inds] = maxofmat(X)

maxval = max(X(:));
[i, j] = find(X == maxval);
inds = [i j];