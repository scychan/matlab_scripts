function rondo_wrapper(fn,varargin)
% Stephanie Chan 2012

% params = convert_rondo_params(varargin);
params = varargin;
nparam = length(params);

callstr = ['%s(',repmat('%s,',1,nparam)];
callstr(end) = ')';

eval(sprintf(callstr,fn,params{:}))