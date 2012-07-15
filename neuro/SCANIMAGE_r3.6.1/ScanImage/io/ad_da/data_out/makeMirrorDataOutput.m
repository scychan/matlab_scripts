function finalMirrorDataOutput = makeMirrorDataOutput()
%% function finalMirrorDataOutput = makeMirrorDataOutput()
% Function that assembles the data matrix sent to the DAQ Analog output Engine for controlling the laser scanning mirrors
%% SYNTAX
%   finalMirrorDataOutput = makeMirrorDataOutput()
%       finalMirrorDataOutput: A Nx2 matrix containing FAST and SLOW mirror signals, following all linear transformations (i.e. zoom, rotation, shift)
%
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makeMirrorDataOutput.mold -- Vijay Iyer 1/23/09
%
% A side effect of this function is the computation of state.acq.mirrorDataOutputOrg, which is the 'original'
%   mirror data output prior to any linear transformation (i.e. shift, rotation, zoom)
%
% This function will also rotate the mirror scanning functions if necessary.
%   
% NoLinTrans option was added so that function can be used to compute the base sawtooth waveform only--i.e. the waveform at the baseZoomFactor
%% CHANGES
%   VI102609A: Use state.internal.scanAmplitudeX/Y in lieu of state.acq.scanAmplitudeX/Y, as the internal value is now used to represent the actual command voltage --  Vijay Iyer 10/26/09
%
%% CREDITS
% Created 5/5/09 by Vijay Iyer
% Derived from earlier version by Tom Pologruto
%% ***********************************

global state 

updateZoom; %This ensures FF/line period are correctly specified for the current zoom

sampleRate = get(state.init.ao2, 'SampleRate');
samplesPerLine = round(sampleRate * state.acq.msPerLine * 1e-3);  %Will be integer-valued naturally, but this ensures no numerical error 

if state.acq.fastScanningX
    scanAmplitudeFast = state.internal.scanAmplitudeX; %VI102609A
    scanAmplitudeSlow = state.internal.scanAmplitudeY; %VI102609A
else
    scanAmplitudeFast = state.internal.scanAmplitudeY; %VI102609A
    scanAmplitudeSlow = state.internal.scanAmplitudeX; %VI102609A
end

if state.acq.linescan
    scanAmplitudeSlow = 0;
end


fast = makeSawtoothX(linspace(0,state.acq.msPerLine * 1e-3,samplesPerLine), 0, scanAmplitudeFast); 
fast = makeMirrorDataX(fast); %VI091708A

slow = makeSawtoothY(linspace(0,(state.acq.linesPerFrame * state.acq.msPerLine * 1e-3), ... %Use true (scanned) lines-per-frame to determine length of time vector -- Vijay Iyer 10/22/09
    (samplesPerLine * state.acq.linesPerFrame)), 0, scanAmplitudeSlow); 

if state.acq.fastScanningX
    finalMirrorDataOutput = [fast slow];
else
    finalMirrorDataOutput = [slow fast];
end

%Cache original waveform (at base zoom), and the scan parameters used to make this waveform
state.acq.mirrorDataOutputOrg = finalMirrorDataOutput; 
state.internal.mirrorDataOutputMsPerLine = state.acq.msPerLine; 
state.internal.mirrorDataOutputScanDelay = state.acq.scanDelay; 
state.internal.mirrorDataOutputAcqDelay = state.acq.acqDelay; 

%Now transform data (zoom, rotation,etc)
linTransformMirrorData(); %VI120908A
finalMirrorDataOutput=state.acq.mirrorDataOutput; 

end
