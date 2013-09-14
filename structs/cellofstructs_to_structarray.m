function array = cellofstructs_to_structarray(C)

dims = size(C);

if ismember(1,size(C));
    nstructs = length(C);
    for istr = 1:nstructs
        curr_fieldnames = fieldnames(C{istr});
        for fn = horz(curr_fieldnames)
            eval(['array(istr).' fn{1} ' = C{istr}.' fn{1} ';'])
        end
    end
    
elseif numel(dims)==2
    for i = 1:dims(1)
        for j = 1:dims(2)
            curr_fieldnames = fieldnames(C{i,j});
            for fn = horz(curr_fieldnames)
                eval(['array(i,j).' fn{1} ' = C{i,j}.' fn{1} ';'])
            end
        end
    end
    
elseif numel(dims)==3
    for i = 1:dims(1)
        for j = 1:dims(2)
            for k = 1:dims(3)
                curr_fieldnames = fieldnames(C{i,j,k});
                for fn = horz(curr_fieldnames)
                    eval(['array(i,j,k).' fn{1} ' = C{i,j,k}.' fn{1} ';'])
                end
            end
        end
    end
else
    error('not written for size(dims)>3')
end