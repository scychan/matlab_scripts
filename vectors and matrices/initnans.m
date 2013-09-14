function [] = initnans(variable_names,m,n)
% function [] = initnans(variable_names,m,n)

nvars = length(variable_names);
for v = 1:nvars
    evalin('caller',sprintf('%s = nan(%i,%i);',variable_names{v},m,n));
end