function figuresize(fignum,setting)

scrsz = get(0,'ScreenSize');

switch setting
    case 'fullscreen'
        set(fignum,'Position',[1 scrsz(4) scrsz(3) scrsz(4)]) 
    case 'quarterscreen'
        set(fignum,'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
end