function header = scim_openTifHeader(filename)
%% function header = scim_openHeader(filename)
% Opens a ScanImage-generated TIF file and extracts header contents stored in file into a Matlab structure variable
%
%% SYNTAX
%   header = scim_openTifHeader()
%   header = scim_openTif(filename)
%       filename: Name of TIF file, with or without '.tif' extension. If omitted, a dialog is launched to allow interactive selection.
%       header: Structure comprising information stored by ScanImage into TIF header
%
%% NOTES
%   This function is simply a 'macro', for calling scim_openTif() in a common use case
%   
%% CREDITS
%   Created 11/23/09, by Vijay Iyer
%
%% ****************************************************************

if nargin >= 1
    header = scim_openTif(filename,'header');
else
    header = scim_openTif('header');
end

