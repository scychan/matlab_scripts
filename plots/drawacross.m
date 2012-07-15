function drawacross(horizvert,val,linestyle)

if ~exist('horizvert')
    horizvert = 'h';
end

if ~exist('val')
    val = 0;
end

if ~exist('linestyle')
    linestyle = 'k--';
end

if horizvert=='h'
    plot(get(gca,'xlim'),[val val],linestyle)
elseif horizvert=='v'
    plot([val val],get(gca,'ylim'),linestyle)
end