function [B,BINT,R,RINT,STATS] = plotregression(x,y,add_ones,colorcode_significance)
% function [B,BINT,R,RINT,STATS] = plotregression(x,y[,add_ones,colorcode_significance])
% assumes x is one-dimensional

%% fill in parameters

if ~exist('addones','var')
    add_ones = 1;
end

if ~exist('colorcode_significance','var')
    colorcode_significance = 1;
end

%% regression

if add_ones
    x = [x ones(size(y))];
end

[B,BINT,R,RINT,STATS] = regress(y,[x ones(size(x))]);

%% plot

if colorcode_significance
    if STATS(3) < 0.05
        color = 'm';
    else
        color = 'b';
    end
end

xlims = get(gca,'xlim');
plot(xlims,B(1)*xlims + B(2),color)