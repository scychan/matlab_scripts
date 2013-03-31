function set_tick_integers(x_or_y)

if ismember(x_or_y,{'x','both'})
    current_xticks = get(gca,'xtick');
    xmin = current_xticks(1);
    xmax = current_xticks(end);
    set(gca,'xtick',xmin:xmax)
end

if ismember(x_or_y,{'y','both'})
    current_yticks = get(gca,'ytick');
    ymin = current_yticks(1);
    ymax = current_yticks(end);
    set(gca,'ytick',ymin:ymax)
end