function barwitherrors(x,y,L,varargin)
% barwitherrors(x,y,L,varargin)
% 
% Defaults on optional arguments:
% 	'barcolor'          'k'
% 	'errcolor'			'm'
%   'U'                 L
%   'width'             0.8
%   'setylim'           1
%   'nobars'            0


pairs = {...
	'barcolor'          'k'   ; ...
	'errcolor'			'm'	; ...
    'U'                 L; ...
    'width'             0.8; ...
    'setylim'           0; ...
    'nobars'            0; ...
}; parseargs(varargin, pairs);

if nobars==0
if ischar(barcolor)
    bar(x,y,width,barcolor)
else
    bar(x,y,width,'facecolor',barcolor)
end
end

hold on ;
if ischar(errcolor)
errorbar(x,y,L,U,[errcolor,'+'],'LineWidth',2);
else
errorbar(x,y,L,U,'+','LineWidth',2,'color',errcolor);
end
hold off ;

if logical(setylim) && min(L)>0
    ylim([min(y)-1.1*max(L), max(y)+1.1*max(L)])
end