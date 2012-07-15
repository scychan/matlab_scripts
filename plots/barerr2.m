function barerr2(x, y, e, varargin)
% BARERR - Bar graph with error bars and significance marks.
%
% Usage:
%  
%  barerr(x, y, e, ...)
%  barerr(x, y, e, 'p_vals', p, ...)
%
% BARERR will plot a bar graph with error bars and (optionally)
% significance asterisks indicating that a given bar is
% statistically significant. Inputs Y, E, and (optionally) P
% must all be the same dimensions, or empty.
%
% If Y is a matrix, bars are plotted in groups, with each group
% containing COLS(Y) bars and a total of ROWS(Y) groups. If Y is a
% vector, each bar is plotted separately. It does not matter
% whether Y is a row or column vector, just so long as the size of
% Y is exactly the size of E. 
%
% X should be a numeric vector or cell array of strings of size
% ROWS(Y) if Y is a matrix or LENGTH(Y) if Y is a vector; that is, X
% is a label for each group if Y is a matrix, or a label for each
% bar if Y is a vector.
%
% Optional Arguments:
%
%   'p_vals'   - A vector or matrix of p-values for each element in Y.
%
%   'p_thr'    - A vector of thresholds indicating significance
%                levels. If the value of p for a given bar is
%                beneath the I'th threshold, the symbol in
%                P_MARK{I} will be plotted above the bar. 
%                (Default: [0.05 0.005 0.0005]
%
%   'p_mark'   - A cell array of strings indicating significance
%                levels on the plot. (Default: one, two, and three stars.)
%               
%   'colormap' - The colormap to use to generate colors for bars,
%                used only if Y is a matrix.
%
%   'err_color'- The color of the error bars in RGB
%                values. (Default: black.)
%
%   'width'    - The width of the bars. (Default: 0.8 if Y is a
%                vector, 1.0 if Y is a matrix.) ('BarWidth' for BAR)
%
%   'STRING'   - Any additional optional args will be passed directly
%                to BAR (e.g., 'BaseValue' for adjusting baseline position
%                or 'BarWidth' to control bar width proportion.
%
%   'bar_props' - cell array of property-value pairs to be passed to BAR.
%                 E.G.: ...,'bar_props',{'BaseValue' 0.5},...
%
%   'err_props' - cell array of property-value pairs to be passed to BAR.
%                 E.G.: ...,'err_props',{'Colors' 0.5},...
%
% SEE ALSO
%    BAR, ERRORBAR

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

%% parse and validate arguments
defaults.p_vals = [];
defaults.p_mark = {'\ast','\ast\ast', '\ast\ast\ast'};
defaults.p_thr = [0.05 0.005 0.0005];
if ~isempty(e)
  defaults.p_height = double(max(y(:)+e(:))*1.05);
else
  defaults.p_height = double(max(y(:)*1.05));
end

defaults.colormap = jet;
defaults.err_color = 'm';

if isvector(y) == 1
  defaults.width = 0.8;
else
  defaults.width = 1;
end

[args barargs] = propval(varargin, defaults);

if rows(y) == 1;
  y = y'; e = e';
  args.p_vals = args.p_vals';
end


%% Make the basic plot
% N.B. We need to create a barcmd with all the optional properties expanded, then evaluate this barcmd.
barcmd = 'bar(y'; % start bar command
for i = 1:2:length(barargs)
    this_prop = barargs{i};
    this_val  = barargs{i+1};
    if ~isstr(this_prop)
        error('invalid optional arguments format.  properties must be strings')
    end
    barcmd = [barcmd sprintf(',''%s''',this_prop)];
    if isstr(this_val)
        barcmd = [barcmd sprintf(',''%s''',this_val)];
    else
        barcmd = [barcmd ',' num2str(this_val)];
    end
end
barcmd = [barcmd ');']; % finish bar command
eval(barcmd);

hold on
colormap(args.colormap);

%% error bars, plotted by each group
nbars = cols(y);
ngrps = rows(y);

grpwidth = min(0.8, nbars/(nbars+1.5));

for i = 1:nbars % Plot errors for the first group
  ex = (1:ngrps) - grpwidth/2 + (2*i-1) * grpwidth/(2*nbars);

  if ~isempty(e)
    h_err = errorbar(ex,y(:,i),e(:,i), 'Marker', 'None', 'LineStyle','None','Color', args.err_color);
    errorbar_tick(h_err,0,'units'); % this keeps things cleaner when there are lots of bars
 end
  
  % Plot significance
  if ~isempty(args.p_vals)    
    for j = 1:numel(args.p_vals(:,i))
      
      idx = find(args.p_vals(j,i) < args.p_thr);
      if ~isempty(idx)
        h = text(ex(j), args.p_height, args.p_mark{idx(end)});
        set(h,'HorizontalAlignment','center');
      end
      
    end        
  end
  
end

hold off;

% Label the X axis accordingly:

set(gca,'XTick', 1:ngrps);

if ~isempty(x) && iscell(x)  
  set(gca, 'XTickLabel', x);
elseif ~isempty(x) && isnumeric(x)
  for i = 1:numel(x)
    s{i} = num2str(x(i));
  end
  set(gca, 'XTickLabel', s);
end


function errorbar_tick(h,w,xtype)
%ERRORBAR_TICK Adjust the width of errorbars
%   ERRORBAR_TICK(H) adjust the width of error bars with handle H.
%      Error bars width is given as a ratio of X axis length (1/80).
%   ERRORBAR_TICK(H,W) adjust the width of error bars with handle H.
%      The input W is given as a ratio of X axis length (1/W). The result 
%      is independent of the x-axis units. A ratio between 20 and 80 is usually fine.
%   ERRORBAR_TICK(H,W,'UNITS') adjust the width of error bars with handle H.
%      The input W is given in the units of the current x-axis.
%
%   See also ERRORBAR
%

% Author: Arnaud Laurent
% Creation : Jan 29th 2009
% MATLAB version: R2007a
%
% Notes: This function was created from a post on the french forum :
% http://www.developpez.net/forums/f148/environnements-developpement/matlab/
% Author : Jerome Briot (Dut) 
%   http://www.mathworks.com/matlabcentral/newsreader/author/94805
%   http://www.developpez.net/forums/u125006/dut/
% It was further modified by Arnaud Laurent and Jerome Briot.

% Check numbers of arguments
error(nargchk(1,3,nargin))

% Check for the use of V6 flag ( even if it is depreciated ;) )
flagtype = get(h,'type');

% Check number of arguments and provide missing values
if nargin==1
	w = 80;
end

if nargin<3
   xtype = 'ratio';
end

% Calculate width of error bars
if ~strcmpi(xtype,'units')
    dx = diff(get(gca,'XLim'));	% Retrieve x limits from current axis
    w = dx/w;                   % Errorbar width
end

% Plot error bars
if strcmpi(flagtype,'hggroup') % ERRORBAR(...)
    
    hh=get(h,'children');		% Retrieve info from errorbar plot
    x = get(hh(2),'xdata');		% Get xdata from errorbar plot
    
    x(4:9:end) = x(1:9:end)-w/2;	% Change xdata with respect to ratio
    x(7:9:end) = x(1:9:end)-w/2;
    x(5:9:end) = x(1:9:end)+w/2;
    x(8:9:end) = x(1:9:end)+w/2;

    set(hh(2),'xdata',x(:))	% Change error bars on the figure

else  % ERRORBAR('V6',...)
    
    x = get(h(1),'xdata');		% Get xdata from errorbar plot
    
    x(4:9:end) = x(1:9:end)-w/2;	% Change xdata with respect to the chosen ratio
    x(7:9:end) = x(1:9:end)-w/2;
    x(5:9:end) = x(1:9:end)+w/2;
    x(8:9:end) = x(1:9:end)+w/2;

    set(h(1),'xdata',x(:))	% Change error bars on the figure
    
end


  


function [merged unused] = propval(propvals, defaults, varargin)

% Create a structure combining property-value pairs with default values.
%
% [MERGED UNUSED] = PROPVAL(PROPVALS, DEFAULTS, ...)
%
% Given a cell array or structure of property-value pairs
% (i.e. from VARARGIN or a structure of parameters), PROPVAL will
% merge the user specified values with those specified in the
% DEFAULTS structure and return the result in the structure
% MERGED.  Any user specified values that were not listed in
% DEFAULTS are output as property-value arguments in the cell array
% UNUSED.  STRICT is disabled in this mode.
%
% ALTERNATIVE USAGE:
% 
% [ ARGS ] = PROPVAL(PROPVALS, DEFAULTS, ...)
%
% In this case, propval will assume that no user specified
% properties are meant to be "picked up" and STRICT mode will be enforced.
% 
% ARGUMENTS:
%
% PROPVALS - Either a cell array of property-value pairs
%   (i.e. {'Property', Value, ...}) or a structure of equivalent form
%   (i.e. struct.Property = Value), to be merged with the values in
%   DEFAULTS.
%
% DEFAULTS - A structure where field names correspond to the
%   default value for any properties in PROPVALS.
%
% OPTIONAL ARGUMENTS:
% 
% STRICT (default = true) - Use strict guidelines when processing
%   the property value pairs.  This will warn the user if an empty
%   DEFAULTS structure is passed in or if there are properties in
%   PROPVALS for which no default was provided.
%
% EXAMPLES:
%
% Simple function with two optional numerical parameters:
% 
% function [result] = myfunc(data, varargin)
% 
%   defaults.X = 5;
%   defaults.Y = 10;
%
%   args = propvals(varargin, defaults)
%
%   data = data * Y / X;
% 
% >> myfunc(data)
%    This will run myfunc with X=5, Y=10 on the variable 'data'.
%
% >> myfunc(data, 'X', 0)
%    This will run myfunc with X=0, Y=10 (thus giving a
%    divide-by-zero error)
%
% >> myfunc(data, 'foo', 'bar') will run myfunc with X=5, Y=10, and
%    PROPVAL will give a warning that 'foo' has no default value,
%    since STRICT is true by default.
%

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

% Backwards compatibility
pvdef.ignore_missing_default = false;
pvdef.ignore_empty_defaults = false;

% check for the number of outputs
if nargout == 2
  pvdef.strict = false;
else
  pvdef.strict = true;
end

pvargs = pvdef;

% Recursively process the propval optional arguments (possible
% because we only recurse if optional parameters are given)
if ~isempty(varargin) 
  pvargs = propval(varargin, pvdef);
end

% NOTE: Backwards compatibility with previous version of propval
if pvargs.ignore_missing_default | pvargs.ignore_empty_defaults
  pvargs.strict = false;
end

% check for a single cell argument; assume propvals is that argument
if iscell(propvals) && numel(propvals) == 1 
  propvals = propvals{1};
end

% check for valid inputs
if ~iscell(propvals) & ~isstruct(propvals)
  error('Property-value pairs must be a cell array or a structure.');
end

if ~isstruct(defaults) & ~isempty(defaults)
  error('Defaults struct must be a structure.');
end

% check for empty defaults structure
if isempty(defaults)
  if pvargs.strict & ~pvargs.ignore_missing_default
   error('Empty defaults structure passed to propval.');
  end
  defaults = struct();
end

defaultnames = fieldnames(defaults);
defaultvalues = struct2cell(defaults);

% prepare the defaults structure, but also prepare casechecking
% structure with all case stripped
defaults = struct();
casecheck = struct();

for i = 1:numel(defaultnames)
  defaults.(defaultnames{i}) = defaultvalues{i};
  casecheck.(lower(defaultnames{i})) = defaultvalues{i};
end

% merged starts with the default values
merged = defaults;
unused = {};
used = struct();

properties = [];
values = [];

% To extract property value pairs, we use different methods
% depending on how they were passed in
if isstruct(propvals)   
  properties = fieldnames(propvals);
  values = struct2cell(propvals);
else
  properties = { propvals{1:2:end} };
  values = { propvals{2:2:end} };
end

if numel(properties) ~= numel(values)
  error(sprintf('Found %g properties but only %g values.', numel(properties), ...
                numel(values)));
end

% merge new properties with defaults
for i = 1:numel(properties)

  if ~ischar(properties{i})
    error(sprintf('Property %g is not a string.', i));
  end

  % convert property names to lower case
  properties{i} = properties{i};

  % check for multiple usage
  if isfield(used, properties{i})
    error(sprintf('Property %s is defined more than once.\n', ...
                  properties{i}));
  end
  
  % Check for case errors
  if isfield(casecheck, lower(properties{i})) & ...
    ~isfield(merged, properties{i}) 
    error(['Property ''%s'' is equal to a default property except ' ...
           'for case.'], properties{i});
  end  
    
  % Merge with defaults  
  if isfield(merged, properties{i})
    merged.(properties{i}) = values{i};
  else
    % add to unused property value pairs
    unused{end+1} = properties{i};
    unused{end+1} = values{i};    

    % add to defaults, just in case, if the user isn't picking up "unused"
    if (nargout == 1 & ~pvargs.strict)
      merged.(properties{i}) = values{i};
    end

    if pvargs.strict
      error('Property ''%s'' has no default value.', properties{i});
    end
    
  end

  % mark as used
  used.(properties{i}) = true;
end




function [r] = rows(X)

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

r = size(X,1);




function [c] = cols(X)

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

c = size(X,2);




