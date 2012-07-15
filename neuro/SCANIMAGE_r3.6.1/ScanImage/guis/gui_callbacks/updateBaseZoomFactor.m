function updateBaseZoomFactor(handle)
%% function updateBaseZoomFactor(handle)
% Callback function that handles update to the base zoom factor 
%
%% NOTES
%   DEPRECATED: These functionalities now occur in configurationGUI() nad in the updateConfigZoomFactor() callback -- Vijay Iyer 1/30/09
%
%   Being an INI-named callback allows this to be called during either a GUI control or CFG/USR file loading event
%
%   This function accomplishes two things:
%       1) Ensure that the zoom index value is valid (because value 1 is always valid)
%       2) During configuration loading, the updateGUIByGlobal() call leads to invocation of callback for the configZoomFactor
%
%% CREDITS
%   Created 1/21/09, by Vijay Iyer
%% ******************************************************************
global state gh

%Reset array display to zoom=1
state.internal.configZoomFactor=1;
updateGUIByGlobal('state.internal.configZoomFactor','Callback',1);


    

    
