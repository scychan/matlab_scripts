function struct2var(s)
% function struct2var(s)
% 
% Loads all the fields of a struct into the BASE workspace.
% 
% WARNING: This loads into the BASE workspace, not the calling workspace!
% To load into the workspace of the calling function, use the following
% line:
% cellfun(@(n,v) assignin('caller',n,v),fieldnames(stim_to_use),struct2cell(stim_to_use));

cellfun(@(n,v) assignin('base',n,v),fieldnames(s),struct2cell(s));