function filenames = dir_filenames(varargin)
% filenames = dir_filenames: no inputs - filenames for current directory
% filenames = dir_filenames(directory_name)
% filenames = dir_filenames(filename_specification) : can use wildcards
% filenames = dir_filenames(dir_or_filenamespec,1) : include sub-folder names
% 
% Stephanie Chan 2011

if nargin == 0
    listing = dir;
else
    dir_or_filenamespec = varargin{1};
    listing = dir(dir_or_filenamespec);
end

include_subfolders = 0;
if nargin == 2
    if varargin{2} == 1
        include_subfolders = 1;
    else
        error('Error: Invalid second input.')
    end
end

filenames = {};
for i = 1:length(listing)
    if listing(i).isdir && ~include_subfolders || strcmp(listing(i).name,'.') || strcmp(listing(i).name,'..')
        continue
    end
    filenames{end+1} = listing(i).name;
end

filenames = filenames';

% 
% 
%  z = fullfile(EXPT.SubjectDir{sub},filetype);
%         name = dir(fullfile(z,fname));
%         files = dir2char(name,z);
%         
%         
% 
% function x = dir2char(f,d)
%     
%     for i = 1:length(f)
%         x(i,:) = fullfile(d,f(i).name);
%     end
%     
% end
