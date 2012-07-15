%   [] = parsestrargs(arguments, pairs, singles)
%
% Same as parseargs, except 'arguments' assumes that values are given as
% strings. Useful for running Matlab on Rondo.


function [] = parsestrargs(arguments, pairs, singles)
   
   if nargin < 3, singles = {}; end;

   for i=1:size(pairs,1),
      assignin('caller', pairs{i,1}, pairs{i,2});
   end;
   for i=1:size(singles,1),
      assignin('caller', singles{i,2}, singles{i,4});
   end;
   if isempty(singles), singles = {'', '', [], []}; end; 
   if isempty(pairs),   pairs   = {'', []}; end; 
   
   arg = 1; while arg <= length(arguments),
      
      switch arguments{arg},
	 
	 case pairs(:,1),
	 if arg+1 <= length(arguments)
        
	    assignin('caller', arguments{arg}, eval(arguments{arg+1}));
	    arg = arg+1;
	 end;
      
	 case singles(:,1),
	 u = find(strcmp(arguments{arg}, singles(:,1)));
	 assignin('caller', singles{u,2}, singles{u,3});
	 
	 otherwise
	 arguments{arg}
	 mname = evalin('caller', 'mfilename');
	 error([mname ' : Didn''t understand above parameter']);
	 
      end; 
   arg = arg+1; end;
   
   return;
