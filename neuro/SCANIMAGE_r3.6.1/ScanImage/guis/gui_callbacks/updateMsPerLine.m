function updateMsPerLine(handle)
%% function updateMsPerLine(handle)
% Callback function to handle changes to MsPerLine value
%
%% NOTES
%   DEPRECATED: MsPerLine is now stored actually in milliseconds, so the translation supplied here is no longer required -- Vijay Iyer 1/27/09
%
%   This is a INI-file designated callback, allowing it to be invoked by either GUI events or configuration loads.
%
%% CHANGES
%   VI011609A: Notify servo delay handler that msPerLine value has changed -- Vijay Iyer 1/16/09 
%   VI012709A: Remove VI011609A. Servo/acq delay now maintained as a number of AI samples. -- Vijay Iyer 1/27/09
%
%% CREDITS
%   Created 1/2/09 by Vijay Iyer
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global state gh

set(gh.basicConfigurationGUI.etMsPerLine, 'String', num2str(1000*state.acq.msPerLine));
set(gh.basicConfigurationGUI.etMsPerLine2, 'String', num2str(1000*state.acq.msPerLine));

%updateServoDelay(); %VI011609A, VI012709A
