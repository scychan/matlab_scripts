function filenames = dir_filenames(varargin)
% filenames = dir_filenames: no inputs - filenames for current directory
% filenames = dir_filenames(directory_name)
% filenames = dir_filenames(filename_specification) : can use wildcards
% filenames = dir_filenames(dir_or_filenamespec,1) : include sub-folder names
% filenames = dir_filenames(dir_or_filenamespec,include_subfolders,1) : include full path
% 
% Stephanie Chan 2011

if nargin == 0
    listing = dir;
else
    dir_or_filenamespec = varargin{1};
    listing = dir(dir_or_filenamespec);
end

include_subfolders = 0;
if nargin > 1
    if varargin{2} == 1
        include_subfolders = 1;
    elseif varargin{2} == 0
        include_subfolders = 0;
    else
        error('Error: Invalid second input.')
    end
end

include_full_path = 0;
if nargin > 2
    if varargin{3} == 1
        include_full_path = 1;
    elseif varargin{3} == 0
        include_full_path = 0;
    else
        error('Error: Invalid second input.')
    end
end

filenames = {};
for i = 1:length(listing)
    if listing(i).isdir && ~include_subfolders || strcmp(listing(i).name,'.') || strcmp(listing(i).name,'..')
        continue
    end
    if include_full_path
        if strfind(dir_or_filenamespec,'*')
            slash_locs = strfind(dir_or_filenamespec,'/');
            dirname = dir_or_filenamespec(1:slash_locs(end)-1);
        else
            dirname = dir_or_filenamespec;
        end
        filenames{end+1} = fullfile(dirname,listing(i).name);
    else
        filenames{end+1} = listing(i).name;
    end
end

filenames = filenames';

if length(filenames) == 1
    filenames = filenames{1};
end