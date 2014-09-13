function rownums = findrow(matrix,vector)

[nrow,ncol] = size(matrix);

vector = horz(vector);
vectorrep = repmat(vector,nrow,1);

rownums = find(sum(matrix==vectorrep,2) == ncol);