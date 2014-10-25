function taskID = gettaskID
% get Rondo/Della array task ID #

if isrondo
    taskID = eval(getenv('SGE_TASK_ID'));
elseif isdella
    taskID = eval(getenv('SLURM_ARRAY_TASK_ID'));
else
    error('Error: not running on Rondo or Della');
end