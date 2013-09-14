function drawacross(horizvert,val,linestyle,linewidth)
% function drawacross(horizvert,val,linestyle,linewidth)
% 
% All inputs are optional:
%   horizvert   - default 'h'
%   val         - default 0
%   linestyle   - default 'k--'
%   linewidth   - default 1


if ~exist('horizvert')
    horizvert = 'h';
end

if ~exist('val')
    val = 0;
end

if ~exist('linestyle')
    linestyle = 'k--';
end

if ~exist('linewidth')
    linewidth = 1;
end

if horizvert=='h'
    plot(get(gca,'xlim'),[val val],linestyle,'linewidth',linewidth)
elseif horizvert=='v'
    plot([val val],get(gca,'ylim'),linestyle,'linewidth',linewidth)
end