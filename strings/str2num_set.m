function str2num_set(varargin)
% If any of the variables named are strings, convert to num.
% e.g. str2num_set('variable1','variable2')

for i = 1:length(varargin)
    varname = varargin{i};
    valstr = evalin('caller',varname);
    if evalin('caller',['isstr(' varname ')'])
        assignin('caller',varname,str2num(valstr)); %#ok<ST2NM>
    end
end