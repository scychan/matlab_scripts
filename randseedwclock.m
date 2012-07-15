
seed = sum(100*clock);
fprintf('Random seed is: %f\n',seed)
RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));