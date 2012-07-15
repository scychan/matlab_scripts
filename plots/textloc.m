function yloc = textloc(ylims)
% function yloc = textloc(ylims)

yloc = 0.4*diff(ylims)+0.5*sum(ylims);