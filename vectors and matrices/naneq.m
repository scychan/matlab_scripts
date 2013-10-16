function Z = naneq(X,Y)
% Z(i) is 1 if X(i)==Y(i)
% Z(i) is nan if isnan(X) or isnan(Y)
% otherwise Z(i) is 0

% assert that X and Y have the same size
assert(~any(size(X)~=size(Y)))

Z = nan(size(X));
for i = 1:numel(X)
    if ~isnan(X(i)) && ~isnan(Y(i))
        Z(i) = X(i)==Y(i);
    end
end