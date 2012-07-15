
function linTransformMirrorData()
%% function linTransformMirrorData()
% This function is responsible for all the linear transformations to mirror data -- scaling, rotation, and offset (in that order)
%
%% NOTES
%  This function was based on rotateAndShiftMirrorData(), but then modified it to be a state-transformer and added the handling of scaling -- Vijay Iyer 9/28/08
%
%  In the case that a change in the msPerLine value has been detected, both the AO and AI buffers must be recomputed
%
%% CHANGES
%   VI022308A Vijay Iyer 2/23/08 - No longer declare lengthofframedata as a global -- not seemingly used anywhere else
%   VI091208A: Add scanOffsetX/Y in addition to the scaleX/YShift
%   VI092208A: Compute state.internal.scanAmplitudeX/Y here...not very elegant, but this is the endpoint at which the scaling is found
%   VI092808A: Add scaling here and make this a state variable processing function (rather than an input/output processor)
%   VI120908A: Correctly use state.internal.baseZoomFactor vs state.acq.baseZoomFactor
%   VI010809A: Recompute base mirror data if timing parameters have changed -- Vijay Iyer 1/08/09
%   VI011509A: (Refactoring) Remove explicit call to setupAOData(), as this is now called as part of setupDAQDevices_ConfigSpecific() -- Vijay Iyer 1/15/09
%   VI012809A: Recompute base mirror data if scan delay has changed -- Vijay Iyer 1/28/09
%   VI013109A: Recompute if acq delay has changed also -- Vijay Iyer 1/31/09
%   VI013109B: Remove differential scaling for above/below base zoom factor -- Vijay Iyer 1/31/09
%   VI030409A: Don't recompute scan following acq delay change if the change is not 'significant' (i.e. if it doesn't change Pockels or Y command signals) -- Vijay Iyer 3/4/09
%   VI052009A: (REFACTOR) All calls to setupDaqDevices_ConfigSpecifig() also call preallocateMemory() -- Vijay Iyer 5/21/09
%   VI102609A: State variable state.internal.scanAmplitudeX/Y is now used to represent the full scan amplitude in the scanner units (i.e. volts). It is no longer (and had not been) used for representing the value at each zoom level. -- Vijay Iyer 10/26/09
%
%% CREDITS
%   Created 9/28/08, by Vijay Iyer
%   Based on rotateMirrorData(), written by Tom Pologruto, 9/29/00
%% ********************************************

global state 

%%%VI030409A%%%%%%
sigAcqDelayChange = (state.acq.acqDelay ~= state.internal.mirrorDataOutputAcqDelay) && ...
    ((state.init.eom.pockelsOn && state.acq.pockelsClosedOnFlyback) || state.acq.staircaseSlowDim); 
%%%%%%%%%%%%%%%%%%

if state.acq.msPerLine ~= state.internal.mirrorDataOutputMsPerLine || ... %VI010809A, VI012809A, VI013109A, VI030409A
        state.acq.scanDelay ~= state.internal.mirrorDataOutputScanDelay || sigAcqDelayChange 
        %state.acq.acqDelay ~= state.internal.mirrorDataOutputAcqDelay  %% && state.init.pockelsOn && state.acq.pockelsClosedOnFlyback)  [This is a nice idea, but doesn't really save much time in the end]
    %%%VI010809A%%%%%
    setStatusString('Recomputing Scan');
    setupDAQDevices_ConfigSpecific;    
	%preallocateMemory; %VI052109A
    %setupAOData();  %VI011509A
    return; %linTransformMirrorData() will get called    
    %%%%%%%%%%%%%%%%%%
end

%Scale the base mirror data 
scaledMirrorDataOutput = state.acq.mirrorDataOutputOrg / state.acq.zoomFactor; %VI013109B
%%%VI013109B: Removed %%%%%%%%%
% if state.acq.zoomFactor < state.acq.baseZoomFactor
%     scaledMirrorDataOutput = state.acq.mirrorDataOutputOrg / state.acq.zoomFactor;
% else
%     scaledMirrorDataOutput= state.acq.mirrorDataOutputOrg/(state.acq.zoomFactor/state.acq.baseZoomFactor); %VI092808A, VI120908A
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI102609A: Removed %%%%%%%%%
%%%VI092208A
% state.internal.scanAmplitudeX = state.acq.scanAmplitudeX/state.acq.zoomFactor;
% state.internal.scanAmplitudeY = state.acq.scanAmplitudeY/state.acq.zoomFactor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lengthofframedata = size(scaledMirrorDataOutput,1); %VI092808A
%lengthofframedata = lengthofframedata(1,1);

c = cos(state.acq.scanRotation*pi/180);
s = sin(state.acq.scanRotation*pi/180);

a = 1:lengthofframedata;
% finalMirrorDataOutput(a,1)=finalMirrorDataOutput(a,1);
% finalMirrorDataOutput(a,2)=finalMirrorDataOutput(a,2);
state.acq.mirrorDataOutput = zeros(lengthofframedata,2); %VI010809A
state.acq.mirrorDataOutput(a,1) = c*scaledMirrorDataOutput(a,1) + s*scaledMirrorDataOutput(a,2)+ state.acq.scaleXShift + state.init.scanOffsetX; %VI091208A
state.acq.mirrorDataOutput(a,2) = c*scaledMirrorDataOutput(a,2) - s*scaledMirrorDataOutput(a,1)+ state.acq.scaleYShift + state.init.scanOffsetY; %VI091208A

%finalMirrorDataOutput = rotatedImage;
