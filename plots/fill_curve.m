function fill_curve(color,X,Y,Y2)

if ~exist('Y2','var') % SHADE UNDER A SINGLE CURVE
    xlims = get(gca,'xlim');
    ylims = get(gca,'ylim');
    fill([xlims(1) X xlims(2)],[ylims(1) Y ylims(1)],color)
    
else % SHADE BETWEEN TWO CURVES
    Y2 = fliplr(Y2);
    Y2 = flipud(Y2);
    X2 = fliplr(X);
    X2 = flipud(X2);
    fill([X X2],[Y Y2],color)
end