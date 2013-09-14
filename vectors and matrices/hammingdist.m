function d = hammingdist(v1,v2)

if length(v1) ~= length(v2)
    error('Lengths of v1 and v2 are not the same')
end

d = sum(v1~=v2);