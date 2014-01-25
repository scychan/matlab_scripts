function name = hostname()

[~, name] = system('echo $HOSTNAME');
name = name(1:end-1);