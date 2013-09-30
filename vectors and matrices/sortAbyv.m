function [B,idx] = sortAbyv(A,v,mode)
% function [B,idx] = sortAbyv(A,v,[mode])
% 
% Sort rows of matrix A (m by n) by a column vector v (length m)
% The vector v indicates the index of each row.
% Example:  A = [11 11; 12 12; 13 13; 14 14] and v = [3 1 4 2]';
%           Then B = [12 12; 14 14; 11 11; 13 13]
% 
% mode (optional): 'ascend' (default) or 'descend'

if ~exist('mode','var')
    mode = 'ascend';
end
    

if isvector(A)
    A = A(:);
end

[vals, idx] = sort(v);
B = A(idx,:);

% [m,n] = size(A);
% p = 1:m;
% q = 1:n;
% [P,Q] = ndgrid(p,q);
% V = repmat(v,[1 n]);
% ind = sub2ind([m n],V,Q);
% B = A(ind);