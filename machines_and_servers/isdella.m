function isdella = isdella()

[~,hostname] = unix('hostname');

if strfind(hostname,'della')
    isdella = true;
else
    isdella = false;
end