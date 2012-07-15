function [finalMirrorDataOutput] = rotateAndShiftMirrorData(finalMirrorDataOutput)
%% function [finalMirrorDataOutput] = rotateAndShiftMirrorData(finalMirrorDataOutput)
% This function takes a N x 2 array, typically the X and Y mirror data outputs where N depends on the D-to-A rate,
% It then applies all the major linear transformations to it -- rotation, and offset (in that order). 
%% NOTES
%   DEPRECATED: linTransformMirrorData() is now used instead -- Vijay Iyer 1/08/09
%
%% CHANGES
%   VI022308A Vijay Iyer 2/23/08 - No longer declare lengthofframedata as a global -- not seemingly used anywhere else
%   VI091208A: Add scanOffsetX/Y in addition to the scaleX/YShift
%   VI092208A: Compute state.internal.scanAmplitudeX/Y here...not very elegant, but this is the endpoint at which the scaling is fd
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% November 29, 2000
%% ********************************************

global state % lengthofframedata (VI022308A)

rotatedImage = finalMirrorDataOutput;

%%%VI092208A -- ideally would actually do the amplitude scaling here too...
state.internal.scanAmplitudeX = state.acq.scanAmplitudeX/state.acq.zoomFactor;
state.internal.scanAmplitudeY = state.acq.scanAmplitudeY/state.acq.zoomFactor;
%%%%%%%%%%

lengthofframedata = size(finalMirrorDataOutput);
lengthofframedata = lengthofframedata(1,1);

c = cos(state.acq.scanRotation*pi/180);
s = sin(state.acq.scanRotation*pi/180);

a = 1:lengthofframedata;
finalMirrorDataOutput(a,1)=finalMirrorDataOutput(a,1);
finalMirrorDataOutput(a,2)=finalMirrorDataOutput(a,2);
rotatedImage(a,1) = c*finalMirrorDataOutput(a,1) + s*finalMirrorDataOutput(a,2)+ state.acq.scaleXShift + state.init.scanOffsetX; %VI091208A
rotatedImage(a,2) = c*finalMirrorDataOutput(a,2) - s*finalMirrorDataOutput(a,1)+ state.acq.scaleYShift + state.init.scanOffsetY; %VI091208A

finalMirrorDataOutput = rotatedImage;
