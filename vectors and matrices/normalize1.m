function y = normalize1(x,dir)
% If x is a vector, normalize the vector to 1
% If x is a matrix and dir='c', normalize the columns to 1.
% If x is a matrix and dir='r', normalize the rows to 1.

if isvector(x)

    y = x/sum(x);
    
elseif dir=='c'
    
    nrows = size(x,1);
    y = x./repmat(sum(x,1),nrows,1);
    
elseif dir=='r'
    
    ncols = size(x,2);
    y = x./repmat(sum(x,2),1,ncols);
    
end
    
    
