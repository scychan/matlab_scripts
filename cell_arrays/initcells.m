function [] = initcells(variable_names,cellsize)
% function [] = initcells(variable_names,cellsize)

nvars = length(variable_names);

cellsizestr = '';
for dim = 1:length(cellsize)
    cellsizestr = sprintf('%s,%i',cellsizestr,cellsize(dim));
end
cellsizestr = cellsizestr(2:end);

for v = 1:nvars
    evalin('caller',sprintf('%s = cell(%s);',variable_names{v},cellsizestr));
end