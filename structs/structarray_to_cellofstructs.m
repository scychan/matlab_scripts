function array = structarray_to_cellofstructs(structarray)

nstructs = length(structarray);
for istr = 1:nstructs
    array{istr} = structarray(istr);
end