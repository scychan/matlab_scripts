function updatePixelTime(handle)
%% function updatePixelTime(handle)
% DEPRECATED: Now handled within updateAcquisitionParameters -- Vijay Iyer 2/20/09

global state

state.acq.pixelTime = ((state.acq.fillFraction * 1e-3 * state.acq.msPerLine)/state.acq.pixelsPerLine); %VI012109A
updateGUIByGlobal('state.acq.pixelTime');



