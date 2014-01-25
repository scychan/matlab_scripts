function seed = randseedwclock()
% function seed = randseedwclock()

seed = sum(100*clock);
try
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));
catch
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));
end