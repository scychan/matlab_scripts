function updateAcqDelay()
%% function updateAcqDelay()
% Callback function for changes to acq delay parameter
%
%% NOTES 
%   DEPRECATED: This logic has been returned to the configurationGUI callback -- Vijay Iyer 1/29/09
%
%   This function constrains the servo delay to valid values: integer multiples of the AI Sampling Period
%
%   This function is /not/ an INI-named Callback %
%% CHANGES
%
%% CREDITS
%   Created 1/16/09 by Vijay Iyer
%% ***************************

global state gh

%Contrain/store current acq delay value
state.internal.acqDelayGUI = constrainAcqDelay(state.internal.acqDelayGUI);
updateGUIByGlobal('state.internal.acqDelayGUI');
state.acq.acqDelay = state.internal.acqDelayGUI * 1e-6;

%Update array (and its display)
state.internal.acqDelayArray(max(state.acq.zoomFactor,state.acq.baseZoomFactor)) = state.internal.acqDelayGUI;
updateConfigZoomFactor();

%Maintain internal acqDelay representation as a fraction, for legacy reasons
state.internal.acqDelay = state.acq.acqDelay / (1e-3 * state.acq.msPerLine);

