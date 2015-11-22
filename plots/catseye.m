function CI = catseye(boots,offset,eyewidth,varargin)
% function catseye(boots,offset,eyewidth,varargin)
%
% INPUTS:
% boots     - the bootstrap distribution of interest
% offset    - where the cat's eye should be centered, on the independent axis
% eyewidth  - the width of the cat's eye
%
% OPTIONAL INPUTS
% alphaCI  - the alpha-value for the desired confidence interval (e.g. 0.05)
% sided     - 'both', 'lower', or 'upper'
% horzvert  - 'v' or 'h'
% CIonly    - set to 1 if only the part corresponding to the CI is desired
% nhist     - default 15 - number of histogram bins (might want to try different values until curves look smooth)
% fillcolor - color of the plot, e.g. 'k'

pairs = {...
    'alphaCI'         0.05
    'sides'         'both'
    'horzvert'      'v'
    'CIonly'        0
    'nhist'         15
    'fillcolor'     'k'
    }; parseargs(varargin, pairs);

%% find the confidence interval for given alphaCI

switch sides
    case 'both'
        lower = prctile(boots,100*alphaCI/2);
        upper = prctile(boots,100*(1 - alphaCI/2));
        CI = [lower upper];
    case 'lower'
        lower = prctile(boots,100*alphaCI);
        upper = max(boots);
        CI = [lower nan];
    case 'upper'
        lower = min(boots);
        upper = prctile(boots,100*(1 - alphaCI));
        CI = [nan upper];
end

%% compute the histogram for the bootstrap distribution

[N,X] = hist(boots,nhist);
N = N/max(N)*eyewidth/2;

%% find the curve-values for the confidence interval

lowerXind = find(X > lower,1);
if strcmp(sides,'upper')
    lowerN = N(1);
else
    frac = (lower-X(lowerXind-1)) / (X(lowerXind)-X(lowerXind-1));
    lowerN = N(lowerXind-1) + frac * diff(N([lowerXind-1,lowerXind]));
end

upperXind = find(X < upper,1,'last');
if strcmp(sides,'lower')
    upperN = N(end);
else
    frac = (upper-X(upperXind)) / (X(upperXind+1)-X(upperXind));
    upperN = N(upperXind) + frac * diff(N([upperXind,upperXind+1]));
end

%%

figure(gcf); hold on

switch horzvert
    
    case 'h'
        
        if CIonly
            
            % fill in the cat's eye, only between 'upper' and 'lower'
            fill([lower lower X(lowerXind:upperXind) upper upper fliplr(X(lowerXind:upperXind))],...
                offset + [-lowerN lowerN N(lowerXind:upperXind) upperN -upperN -fliplr(N(lowerXind:upperXind))],...
                fillcolor)
            
            switch sides 
                case 'upper'
                    % draw the rest of the lower line
                    xlims = get(gca,'xlim');
                    plot([xlims(1) X(1)],offset*[1 1],fillcolor)
                case 'lower'
                    % draw the rest of the upper line
                    xlims = get(gca,'xlim');
                    plot([X(end) xlims(end)],offset*[1 1],fillcolor)
            end
            
        else
                        
            % plot the two curves
            plot(X,offset+N,fillcolor);
            plot(X,offset-N,fillcolor);
            
            % fill in the cat's eye, only between 'upper' and 'lower'
            fill([lower lower X(lowerXind:upperXind) upper upper fliplr(X(lowerXind:upperXind))],...
                offset + [-lowerN lowerN N(lowerXind:upperXind) upperN -upperN -fliplr(N(lowerXind:upperXind))],...
                fillcolor)
            
            % draw the rest of the line
            xlims = get(gca,'xlim');
            plot([xlims(1) X(1)],offset*[1 1],fillcolor)
            plot([X(end) xlims(end)],offset*[1 1],fillcolor)
            
        end
        
    case 'v'
        
        if CIonly
            
            % fill in the cat's eye, only between 'upper' and 'lower'
            fill(offset + [-lowerN lowerN N(lowerXind:upperXind) upperN -upperN -fliplr(N(lowerXind:upperXind))],...
                [lower lower X(lowerXind:upperXind) upper upper fliplr(X(lowerXind:upperXind))],...
                fillcolor)
            
            switch sides 
                case 'upper'
                    % draw the rest of the lower line
                    ylims = get(gca,'ylim');
                    plot(offset*[1 1],[ylims(1) X(1)],fillcolor)
                case 'lower'
                    % draw the rest of the upper line
                    ylims = get(gca,'ylim');
                    plot(offset*[1 1],[X(end) ylims(end)],fillcolor)
            end
            
        else
            
            % plot the two curves
            plot(offset+N,X,fillcolor);
            plot(offset-N,X,fillcolor);
            
            % fill in the cat's eye, only between 'upper' and 'lower'
            fill(offset + [-lowerN lowerN N(lowerXind:upperXind) upperN -upperN -fliplr(N(lowerXind:upperXind))],...
                [lower lower X(lowerXind:upperXind) upper upper fliplr(X(lowerXind:upperXind))],...
                fillcolor)
            
            % draw the rest of the line
            ylims = get(gca,'ylim');
            plot(offset*[1 1],[ylims(1) X(1)],fillcolor)
            plot(offset*[1 1],[X(end) ylims(end)],fillcolor)
            
        end
end