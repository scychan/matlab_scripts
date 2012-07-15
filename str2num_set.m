function str2num_set(varargin)
for i = 1:length(varargin)
    varname = varargin{i};
    valstr = evalin('caller',varname);
    assignin('caller',varname,str2num(valstr));
end