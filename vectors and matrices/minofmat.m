function [minval, inds] = minofmat(X)

minval = min(X(:));
[i, j] = find(X == minval);
inds = [i j];