% USAGE:    ir = ranking(vec)              - ranking the whole vector
%           ir = ranking(vec,'val',val)    - find the ranking of a specific value
%           ir = ranking(vec,'ind',ind)    - find the ranking of the value at 'ind'

function ir = ranking(vec,instr,indorval)

[~,ix] = sort(vec);
[~,ir] = sort(ix);

if exist('instr','var')
    if strcmp(instr,'val')
        loc = vec==indorval;
    elseif strcmp(instr,'ind')
        loc = indorval;
    else
        error('invalid instruction for indorval')
    end
    ir = ir(loc);
end