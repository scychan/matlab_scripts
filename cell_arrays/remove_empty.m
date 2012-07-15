% remove empty entries from a cell array X

function empty_removed = remove_empty(X)
    empty_removed = X(~cellfun(@isempty,X));
end