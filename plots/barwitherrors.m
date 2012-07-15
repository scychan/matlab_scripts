function barwitherrors(x,y,L,varargin)

pairs = {...
	'barcolor'          'k'   ; ...
	'errcolor'			'm'	; ...
    'U'                 L; ...
    'width'             0.8; ...
    'setylim'           1; ...
    'nobars'            0; ...
}; parseargs(varargin, pairs);

if nobars==0
if ischar(barcolor)
    bar(x,y,width,barcolor)
else
    bar(x,y,width,'facecolor',barcolor)
end
end

if logical(setylim) && min(L)>0
    ylim([0 1.1*(max(y)+max(L))])
end

hold on ;
if ischar(errcolor)
errorbar(x,y,L,U,[errcolor,'+'],'LineWidth',2);
else
errorbar(x,y,L,U,'+','LineWidth',2,'color',errcolor);
end
hold off ;