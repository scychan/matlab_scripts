function dirname = get_dirname(path_to_file)

slashlocs = strfind(path_to_file,'/');

if strcmp(path_to_file(end),'/')
    lastslash = slashlocs(end-1);
else
    lastslash = slashlocs(end);
end

dirname = path_to_file(1:lastslash-1);