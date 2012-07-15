function r = rand_int(varargin)
% r = rand_int(max) : gives a random int in range [1,max]
% r = rand_int(min,max) : gives a random int in range [min,max]
% r = rand_int(min,max,length) : gives a vector of random integers
% r = rand_int(min,max,nrow,ncol) : gives a matrix of random integers

if length(varargin) == 1
    
    min = 1;
    max = varargin{1};
    nrow = 1;
    ncol = 1;
    
elseif length(varargin) == 2
    
    min = varargin{1};
    max = varargin{2};
    nrow = 1;
    ncol = 1;
    
elseif length(varargin) == 3
    
    min = varargin{1};
    max = varargin{2};
    nrow = 1;
    ncol = varargin{3};
    
elseif length(varargin) == 4
    
    min = varargin{1};
    max = varargin{2};
    nrow = varargin{3};
    ncol = varargin{4};
    
end

r = rand(nrow,ncol);
r = ceil((max-min+1)*r + min-1);