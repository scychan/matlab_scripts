error('This is not a useful script!! It''s just an example to be copied!')

if isrondo || isdella
    need_to_convert = {'X','Y','Z'};
    for inputstrnum = 1:length(need_to_convert)
        inputstr = need_to_convert{inputstrnum};
        if any(strcmp(varargin,inputstr))
            str2num_set(inputstr)
        end
    end
end