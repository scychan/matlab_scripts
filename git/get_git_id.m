function commit_id = get_git_id

[~,commit_id] = unix('git --no-pager log -n 1 --format="%h"');
commit_id = commit_id(1:end-1); % remove the newline