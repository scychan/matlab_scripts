function newarray = structarray_add_entry(origarray,arrayind,entry,samefieldsrequired)
% function newarray = structarray_add_entry(origarray,structind,entry,[samefieldsrequired])
% 
% Similar to origarray(structind) = entry, but allows entry to have
% different/more fields than origarray
% 
% If origarray is 1-D, arrayind > length(origarray) is OK.

if ~exist('samefieldsrequired','var')
    samefieldsrequired = 1;
end

if samefieldsrequired
    if ~all(strcmp(sort(fieldnames(origarray)),...
            sort(fieldnames(entry))))
        error('Fieldnames not the same for origarray and entry')
    end
end

newarray = origarray;

fields = fieldnames(entry);
for f = 1:length(fields)
    newarray(arrayind).(fields{f}) = entry.(fields{f});
end