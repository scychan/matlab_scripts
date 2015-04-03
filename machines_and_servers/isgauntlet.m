function isgauntlet = isgauntlet()

[~,hostname] = unix('hostname');

if strfind(hostname,'gauntlet')
    isgauntlet = true;
else
    isgauntlet = false;
end