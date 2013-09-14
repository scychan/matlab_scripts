function M = structarray_extractfield(S,field,mat_or_cell)

[m,n] = size(S);

if ~exist('mat_or_cell','var')
    mat_or_cell = 'cell';
end

switch mat_or_cell
    case 'mat'
        M = nan(size(S));
        
        for i = 1:m
            for j = 1:n
                eval(sprintf('M(i,j) = S(i,j).%s;',field))
            end
        end
    case 'cell'
        M = cell(size(S));
        for i = 1:m
            for j = 1:n
                eval(sprintf('M{i,j} = S(i,j).%s;',field))
            end
        end
end

