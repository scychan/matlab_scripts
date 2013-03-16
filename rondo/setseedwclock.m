% sets the seed for RandStream using the clock, so that results are
% different for each run

seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed)); %set seed