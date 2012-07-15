function x = makeSawtoothX(t, scanOffsetX, scanAmplitudeX)
%% function x = makeSawtoothX(t, scanOffsetX, scanAmplitudeX);
% Function that defines the scanning mirror output for the fast mirror 
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makeSawtoothX.mold -- Vijay Iyer 1/23/09
%
%   The function is called makeSawtoothX(), but could/should be called makeSawtoothFast(), as it pertains to the fast mirror, whether X or Y
%
%% CHANGES
%   VI030309A: Add scan delay entirely to beginning of ramp, making command waveform asymmetric -- VIjay Iyer 3/3/09
%
%% CREDITS
%   Created 1/25/09, by Vijay Iyer
%   Derived from earlier version by Tom Pologruto
%% ********************************************************************

global state

state.internal.lengthOfXData = length(t); 
acqSamples = round(state.internal.lengthOfXData*state.acq.fillFraction);

if ~state.acq.bidirectionalScan   

    %Key parameters
    rampTime = state.acq.fillFraction * (1e-3 * state.acq.msPerLine); %The 'true' ramp period, not including the settlingTime 'extension'
    settlingTime = state.acq.scanDelay; %Time added to ramp portion of the waveform, extending the ramp amplitude and hence compensating for scan attenuation
    %settlingTime = 2 * state.acq.acqDelay; %Time added to ramp portion of the waveform, at its beginning, to allow for the response to settle
    flybackTime = (1e-3 * state.acq.msPerLine) - rampTime - settlingTime; % The period of the cycloid portion of the waveform  
    
    x = zeros(state.internal.lengthOfXData,1);
    
    %Ramp waveform portion
    slopex1 = 2*scanAmplitudeX/(1e-3 * state.acq.msPerLine * state.acq.fillFraction);              
    %interceptx1 = scanOffsetX - scanAmplitudeX - slopex1 * (settlingTime/2); %VI030309A
    interceptx1 = scanOffsetX - scanAmplitudeX - slopex1 * settlingTime; %VI030309A
    numRampPoints = round(state.internal.lengthOfXData * (rampTime + settlingTime) / (1e-3 * state.acq.msPerLine));
    
    x(1:numRampPoints) = slopex1*t(1:numRampPoints) + interceptx1;
    
    %Cycloid waveform portion
    cycloidVelocity = 2*pi/flybackTime;
    cycloidAmplitude = 2 * abs(scanAmplitudeX) + abs(slopex1) * (settlingTime + flybackTime); %Amplitude adjustments to account for added ramp time and ongoing ramp waveform req'd for initial conditon matching   
      
    t2 = t(numRampPoints+1:end) - t(numRampPoints);
    x(numRampPoints+1:end) = x(numRampPoints) + (-sign(scanAmplitudeX)) *(cycloidAmplitude/(2*pi)) * (cycloidVelocity*t2 - sin(cycloidVelocity * t2)) + slopex1*t2;   
    
    %state.internal.lineDelay = (numPosSlopePoints - acqSamples)/(state.internal.lengthOfXData);
    %state.internal.scanDelay= settlingTime / (state.acq.msPerLine * 1e-3);
else      
    numPosSlopePoints = state.internal.lengthOfXData;
    
    slopex1 = (2*scanAmplitudeX)/(1e-3*state.acq.msPerLine*state.acq.fillFraction); 
    slopex2 = -slopex1;    

    interceptx1 = scanOffsetX - (scanAmplitudeX/state.acq.fillFraction);
    interceptx2 = scanOffsetX + (scanAmplitudeX/state.acq.fillFraction);
    
    x1 = slopex1*t + interceptx1;
    x2 = slopex2*t + interceptx2;

    x = [x1'; x2'];    
    
    %     if mod(numPosSlopePoints - acqSamples,2) %Ensure that number of samples pertaining to line delay is even
    %         acqSamples = acqSamples + 1;
    %     end
    
    %state.internal.scanDelay = (numPosSlopePoints - acqSamples)/(2*state.internal.lengthOfXData);
end


end


