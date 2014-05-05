function isdella = isdella()

[~,hostname] = unix('hostname');

if strfind(hostname,'della4')
    isdella = true;
else
    isdella = false;
end