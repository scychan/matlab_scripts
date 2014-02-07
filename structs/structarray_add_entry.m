function newarray = structarray_add_entry(origarray,arrayind,entry)
% function newarray = structarray_add_entry(origarray,structind,entry)
% 
% Similar to origarray(structind) = entry, but allows entry to have
% different/more fields than origarray
% 
% If origarray is 1-D, arrayind > length(origarray) is OK.

newarray = origarray;

fields = fieldnames(entry);
for f = 1:length(fields)
    newarray(arrayind).(fields{f}) = entry.(fields{f});
end