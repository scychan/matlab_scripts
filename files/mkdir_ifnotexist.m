function mkdir_ifnotexist(dirname)

if ~exist(dirname,'dir')
    mkdir(dirname)
end