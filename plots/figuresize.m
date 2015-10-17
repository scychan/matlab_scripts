function figuresize(setting,fignum)
% function figuresize(setting,[fignum])
% settings:
%  'fullscreen'
%  'quarterscreen'
%  'wide'
%  'long'

if ~exist('fignum','var')
    fignum = gcf;
end

scrsz = get(0,'ScreenSize');
swidth = scrsz(3);
sheight = scrsz(4);

switch setting % [left bottom width height]
    case 'fullscreen'
        set(fignum,'Position',[1 sheight swidth sheight]) 
    case 'quarterscreen'
        set(fignum,'Position',[1 sheight/2 swidth/2 sheight/2])
    case 'wide'
        set(fignum,'Position',[1 sheight/2 swidth sheight/2]) 
    case 'wide_lower'
        set(fignum,'Position',[1 1 swidth sheight/2]) 
    case 'wide_skinny'
        set(fignum,'Position',[1 sheight/4 swidth sheight/4]) 
    case 'long'
        set(fignum,'Position',[1 sheight swidth/2 sheight]) 
end