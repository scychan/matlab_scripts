function locs = find_subvec(vec,tidbit)

% make sure they're oriented the same direction
vec = vec(:)';
tidbit = tidbit(:)';

n = length(vec);
m = length(tidbit);

locs = zeros(1,n);

for j = 1:n-m+1
    subvec = vec(j:j+m-1);
    if isempty(find(subvec~=tidbit))
        locs(j) = 1;
    end
end