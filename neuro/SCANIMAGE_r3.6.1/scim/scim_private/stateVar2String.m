function stringVal = stateVar2String(stateVar,state)
%STATEVAR2STRING Convert a ScanImage state variable to a string
%
%% SYNTAX
%   stringVal = stateVar2String(stateVar)
%   stringVal = stateVar2String(stateVar, stateStruct)
%       stateVar: String containing name of a ScanImage state variable, in full structure format (e.g. 'state.acq.numPixels')
%       state: Structure variable representing the ScanImage state variable, allowing function to be used without obtaining 'state' from global workspace 
%
%% NOTES
%   Created to factor out common code used in CFG and Header saving
%   String value for variable is in a format that can be correctly parsed by initGUIsFromCellArray()
%
%   ArrayString variables (due to be phased out) are not correctly supported in 'user mode', where state is passed in as a structure variable -- Vijay Iyer 6/24/09
%
%% CHANGES
%   VI062409A: Support case where state is passed in as a structure variable, rather than relying on global workspace -- Vijay Iyer 6/24/09
%   VI0710109A: Need isempty() now with strfind() call to handle logical AND with userMode test from VI062409A -- Vijay Iyer 7/1/09
%   
%% CREDITS
%   Created 3/15/09, by Vijay Iyer
%% ******************************************

%%%VI062409A%%%%%
if nargin < 2
    global state %#ok<REDEF>
    userMode = false;
else
    userMode = true;
end
%%%%%%%%%%%%%%%%%

val=[];

if ~userMode && ~isempty(strfind(stateVar,'ArrayString'))%VI070109A %%%ArrayString values are due to be phased out...can now store arrays directly
    eval(['val= mat2str(' stateVar(1:end-6) ');']);
else
    eval(['val=' stateVar ';']);
end
%%%%%%%%%%%%%%%%%%%%%%%%

if iscell(val) %don't convert cell array vars
    stringVal = [];
elseif isnumeric(val)
    if ndims(val) > 2
        stringVal = ['''' ndArray2Str(val) '''']; %Use custom ndArray2Str() to deal with ND arrays; store as 'string string' to be loaded correctly by initGUIsFromCellArray()
    elseif isscalar(val) || isempty(val)
        stringVal = mat2str(val);
    else
        stringVal = ['''' mat2str(val) '''']; %Store 2D arrays as a 'string string' to be loaded correctly by initGUIsFromCellArray()
    end
else %should be a string...convert to a 'string string'
    stringVal = ['''' val ''''];
end
