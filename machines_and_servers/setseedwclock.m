function setseedwclock(verbose)
% sets the seed for RandStream using the clock, so that results are
% different for each run

seed = sum(100*clock);
if exist('verbose','var') & strcmp(verbose,'v')
    fprintf('Random seed is: %f\n',seed)
end
% RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));
rand('twister', seed)
