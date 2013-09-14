function Y = getfield_structarray(X,field,cell_or_mat)

if ~exist('cell_or_mat','var')
    cell_or_mat = 'cell';
end

dims = size(X);

switch numel(dims)
    case 2
        Y = cell(dims);
        for i = 1:dims(1)
            for j = 1:dims(2)
                eval(sprintf('Y{i,j} = X(i,j).%s;',field))
            end
        end
    case 3
        Y = cell(dims);
        for i = 1:dims(1)
            for j = 1:dims(2)
                for k = 1:dims(3)
                    eval(sprintf('Y{i,j,k} = X(i,j,k).%s;',field))
                end
            end
        end
    otherwise
        error
end

if strcmp(cell_or_mat,'mat')
    Y = cell2mat(Y);
end