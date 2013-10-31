function [] = initnans(variable_names,arraysize)
% function [] = initnans(variable_names,m,n)

nvars = length(variable_names);

arraysizestr = '';
for dim = 1:length(arraysize)
    arraysizestr = sprintf('%s,%i',arraysizestr,arraysize(dim));
end
arraysizestr = arraysizestr(2:end);

for v = 1:nvars
    evalin('caller',sprintf('%s = nan(%s);',variable_names{v},arraysizestr));
end