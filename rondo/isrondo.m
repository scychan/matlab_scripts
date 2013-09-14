function isrondo = isrondo()

[~,hostname] = unix('hostname');

if strfind(hostname,'cluster')
    isrondo = true;
else
    isrondo = false;
end