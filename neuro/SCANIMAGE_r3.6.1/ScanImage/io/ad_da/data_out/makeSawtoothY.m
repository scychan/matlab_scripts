function y = makeSawtoothY(t, scanOffsetY, scanAmplitudeY)
%% function y = makeSawtoothY(t, scanOffsetY, scanAmplitudeY)
% Function that defines the frame scanning mirror output.
%
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makeSawtoothY.mold -- Vijay Iyer 1/31/09
%
%   The function is called makeSawtoothY(), but could/should be called makeSawtoothSlow(), as it pertains to the slow mirror, whether X or Y
%
%% CHANGES
%   VI102209A: Handle slow dimension flyback options -- Vijay Iyer 10/22/09
%
%% CREDITS
%   Created 1/31/09, by Vijay Iyer
%   Derived from earlier version by Tom Pologruto
%% ************************************************************************

global state

%%%VI102209A%%%%%%%%
if state.acq.slowDimFlybackFinalLine
    rampLinesPerFrame = state.acq.linesPerFrame - 1; 
else
    rampLinesPerFrame = state.acq.linesPerFrame;
end
%%%%%%%%%%%%%%%%%%%%    

slopey1 = (2*scanAmplitudeY)/(1e-3 * state.acq.msPerLine*rampLinesPerFrame); %VI102209A   
intercepty1 = scanOffsetY - scanAmplitudeY; 

if state.acq.slowDimFlybackFinalLine %VI102209A
    slopey2 = -(2*scanAmplitudeY)/(1e-3 * state.acq.msPerLine); %flyback in the time it takes for one line
    intercepty2 = scanOffsetY + scanAmplitudeY;
end

numberOfPositiveSlopePointsY = rampLinesPerFrame*state.internal.lengthOfXData; %VI102209A

y1 = slopey1*t + intercepty1;
y2 = []; %VI102209A: Initialize y2, in case it's never set below
if ~state.acq.bidirectionalScan 
    %y2 = slopey2*t + intercepty2;
    if state.acq.slowDimFlybackFinalLine %VI102209A
        y2 = slopey2*(t-(1e-3*state.acq.msPerLine*rampLinesPerFrame)) + intercepty2; %should probably use this, as with bidi? %VI102209A
    end        
else
    if state.acq.staircaseSlowDim
        y1    = zeros(1,numberOfPositiveSlopePointsY);

        %y1 = y(1:((state.acq.linesPerFrame-1)* state.internal.lengthOfXData));
        stepVals = scanOffsetY + linspace(-scanAmplitudeY, scanAmplitudeY, rampLinesPerFrame); %VI102209A
        for i=1:length(stepVals)
            y1(((i-1)*state.internal.lengthOfXData+1):(i*state.internal.lengthOfXData)) = stepVals(i);
        end

        %Account for data shift that can arise with long acqDelay values...
        overage = round((state.acq.acqDelay + state.acq.scanDelay + state.acq.fillFraction * state.acq.msPerLine * 1e-3) ...
            * state.acq.outputRate) + 1 - state.internal.lengthOfXData;
        if overage > 0
            y1 = circshift(y1,overage);
        end
    end

    if state.acq.slowDimFlybackFinalLine %VI102209A
        y2 = slopey2*(t-(1e-3*state.acq.msPerLine*rampLinesPerFrame)) + intercepty2; %VI102209A
    end
end

y = [y1(1:numberOfPositiveSlopePointsY)'; y2(numberOfPositiveSlopePointsY+1:end)']; 
