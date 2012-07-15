function updateBinFactor(handle)
%% function updateBinFactor(handle)
% DEPRECATED: Now handled within updateAcquisitionParameters -- Vijay Iyer 2/20/09
global state

state.acq.binFactor = (state.acq.samplesAcquiredPerLine/state.acq.pixelsPerLine);
updateGUIByGlobal('state.acq.binFactor');
