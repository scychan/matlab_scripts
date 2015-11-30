function pv = pooled_variance(ns,vars)
% function pv = pooled_variance(ns,vars)
% 
% ns - a vector of sample sizes for each of the samples
% vars - a vector variances for each of the samples
% (ns and vars should be in the same order)

pv = sum((ns-1).*vars) / sum(ns-1);