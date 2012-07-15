function setZoomValue(zoomVal)
%% function setZoomValue(zoomVal)
% Sets zoom to a new value, accounting for all constraints and possible side-effects
%
%% SYNTAX
%   setZoomValue(zoomVal)
%       zoomVal: New zoom value
%% NOTES
%   This helper was created to unify handling in mainControls and in genericKeyPressFuncton()
%   
%% CREDITS
%   Created 1/09/09, by Vijay Iyer
%% ***************************************************

global state

oldZoomFactor = state.acq.zoomFactor;

state.acq.zoomFactor = max(round(zoomVal),1); %zoom value must be integer-valued and at least 1

%Flag if the fill fraction (line period) may have changed due to the zoom factor change
if state.acq.zoomFactor >= state.acq.baseZoomFactor && oldZoomFactor < state.acq.baseZoomFactor
    state.internal.fillFracChange = 1;
elseif state.acq.zoomFactor < state.acq.baseZoomFactor
    state.internal.fillFracChange = 1;
else
    state.internal.fillFracChange = 0;
end

%This updates GUI controls, and makes acquisition parameter changes (if any)
updateZoom();