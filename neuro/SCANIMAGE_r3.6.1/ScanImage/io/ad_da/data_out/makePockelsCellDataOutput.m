function pockelsOn = makePockelsCellDataOutput(beam, flybackOnly)
%% function pockelsOn = makePockelsCellDataOutput(beam, flybackOnly)
%  Function that constructs the Pockels Cell Data Output
%
%% SYNTAX
%    function pockelsOn = makePockelsCellDataOutput(beam)
%    function pockelsOn = makePockelsCellDataOutput(beam, flybackOnly)
%       beam: Integer indicating which beam to compute the command waveform for
%       flybackOnly: Logical indicating, when true, to compute flyback blanking (if enabled) rather than 'special feature' waveform. Default value is false.  
%   
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makePockelsCellDataOutput.mold -- Vijay Iyer 1/27/09
%
%   This function produces the flyback blanking signal -- a square wave which is 'on' during the acquisition window, and 'off' otherwise. 
%   If any 'special feature' is used -- i.e. the powerBox-- the function implementPockelsCellTiming() is used instead.   
%
%% CHANGES
%   VI011609A Vijay Iyer 1/16/09 -- Changed state.init.pockelsOn to state.init.eom.pockelsOn
%   VI102209A Vijay Iyer 10/22/09 -- Handle slow dimension flyback options
%
%% CREDITS
%  Created 0/09, by Vijay Iyer
%  Based heavily on earlier version by Tom Pologruto and Tim O'Connor
%% ************************************************************************
global state

sampleShift = 0; %Variable for case that acquisition window 'leaks' beyond line period

% warning(state.init.eom.pockelsCellNames{beam});
if ~state.init.eom.pockelsOn %VI011609A
    error('Pockels cell disabled.');
end

if nargin < 2
    flybackOnly = 0;
end

if isempty(state.init.eom.lut)
    return;
end

%Identify if a special feature is being used
specialFeature = ~flybackOnly && (state.init.eom.usePowerArray || any(state.init.eom.showBoxArray) || any(state.init.eom.uncagingMapper.enabled)); %VI030708A %VI041808A %VI041808B

state.init.eom.min = round(state.init.eom.min);

if state.init.eom.min(beam) > 100
    fprintf(2, 'WARNING: Minimum power for beam %s is over 100%%. Forcing it to 99%%...\n', num2str(beam));
    state.init.eom.min(beam) = 99;
elseif state.init.eom.min(beam) < 1
    fprintf(2, 'WARNING: Minimum power for beam %s is below 1%%. Forcing it to 1%%...\n', num2str(beam));
    state.init.eom.min(beam) = 1;
end
   
if ~specialFeature 
    %Pre load array with minimum value
    pockelsOn = state.init.eom.lut(beam, state.init.eom.min(beam)) + zeros(state.internal.lengthOfXData, 1);   
    
    if state.acq.pockelsClosedOnFlyback
        startGoodPockelsDataBase = (state.acq.scanDelay + state.acq.acqDelay - state.acq.pockelsFillFracAdjust/2) * state.acq.outputRate;
        startGoodPockelsData = round(startGoodPockelsDataBase) + 1;
        endGoodPockelsData = round(startGoodPockelsDataBase + state.internal.lengthOfXData*state.acq.fillFraction + (state.acq.pockelsFillFracAdjust/2) * state.acq.outputRate);

        %%%Handle case where acq window is shifted if startGoodPockelsData < 1 
        if startGoodPockelsData < 1
            sampleShift = 1 - startGoodPockelsData;
            startGoodPockelsData = 1;
            pockelsOn(end-sampleShift+1:end) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
        end                                
        
        %%%Handle case where acquisition window leaks beyond edge of line period
        if endGoodPockelsData > state.internal.lengthOfXData
            sampleShift = max(sampleShift,endGoodPockelsData - state.internal.lengthOfXData);
            endGoodPockelsData = state.internal.lengthOfXData;
            pockelsOn(1:sampleShift) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
        end       
       
    else
        startGoodPockelsData = 1;
        endGoodPockelsData = state.internal.lengthOfXData;
    end

    %Fill in the 'on' portion of the command waveform
    pockelsOn(startGoodPockelsData:endGoodPockelsData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    
    %Repeat Pockels Data to create for one frame; this will be the repeated unit
    pockelsOn = repmat(pockelsOn, [state.acq.linesPerFrame 1]);

    %%%VI102209A: Handle slow dimension flyback case %%%%%%%
    if state.acq.slowDimFlybackFinalLine && state.acq.pockelsClosedOnFlyback
        pockelsOn(end-state.internal.lengthOfXData+1:end) = state.init.eom.lut(beam, state.init.eom.min(beam));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else %Handle case where a special feature is used
    pockelsOn = implementPockelsCellTiming(beam);
end
