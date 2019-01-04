function ls_filenames(directory)

list_temp = ls(directory);
nchar = length(list_temp)
list = {};

curr_word = [];
for i = 1:nchar
    char = list_temp(i);
    if i == nchar || strcmp(char,sprintf('\t'))
        list = [list; curr_word];
        curr_word = [];
    else
        curr_word = [curr_word, char];
    end
end
