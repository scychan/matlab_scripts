function updateScanAmplitude(handle)
%% function updateScanAmplitude(handle)
% Callback function that handles update to the scan amplitude X or Y values
%
%% NOTES
%   Function is an INI-file callback, so it is invoked either upon adjusting the GUI control or loading a CFG file
%
%% CREDITS
%   Created 10/26/09, by Vijay Iyer
%% ******************************************************************
global state gh

%Flag aspect ratio change (regardless of whether value has changed). Forces image displays to reset their aspect ratios.
state.internal.aspectRatioChanged=1;

%Update 'internal' scanAmplitude values
state.internal.scanAmplitudeX = state.acq.scanAmplitudeX * state.init.opticalDegreesConversion;
state.internal.scanAmplitudeY = state.acq.scanAmplitudeY * state.init.opticalDegreesConversion;


    




        
        