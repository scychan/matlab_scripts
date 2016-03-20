function commit_id = get_git_id

commit_id = unix('git --no-pager log -1 --format="%h"');