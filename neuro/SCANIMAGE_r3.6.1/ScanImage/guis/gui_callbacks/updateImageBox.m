function updateImageBox(handle)
%% function updateImageBox(handle)
% Callback function that handles update to the ImageBox (crosshair) checkbox
%
%% NOTES
%   Function is an INI-file callback, so it is invoked either upon adjusting the GUI control or loading a CFG file
%
%   Activating crosshairs requires that EraseMode of all image display figures be set to Normal.
%
%   Function is a cut-and-paste from original callback in userPreferenceGui.m, plus handling of EraseMode
%% CREDITS
%   Created 9/10/09, by Vijay Iyer
%% ******************************************************************

global state
val=get(handle,'Value');

if isfield(state.internal,'axis') %Ignore case when this is called from openini(). Wait till openusr().
    if val
        setAxisGrids(state.internal.axis, 2);
        set(state.internal.imagehandle,'EraseMode','normal'); %EraseMode must be normal if the crosshair is to display
    else
        setImagesToWhole;
        set(state.internal.axis, 'XGrid', 'off', 'YGrid', 'off', 'XColor', 'b', 'YColor', 'b', 'GridLineStyle', 'none','Layer','Bottom');
        set(state.internal.imagehandle,'EraseMode', 'none'); %This is fastest
    end
    rearrangeAxes(state.internal.axis);
end

        
        