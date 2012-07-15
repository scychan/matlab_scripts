function [ output_args ] = optimizeZoomArrays( input_args )
%% function [ output_args ] = optimizeZoomArrays( input_args )
%   
%% NOTES
%   DEPRECATED: The manually-set scan zoom array was used instead of this original 'smart' approach -- Vijay Iyer 10/26/09
%
%% ***************************************************

 function [incrementMultiplier numPosSlopePoints] = optimizeFillFrac(zoomFactor)

        numPosSlopePoints = [];
        minIncrementMultiplier = 0; %VI121108B
        maxIncrementMultiplier = 3;
        
        if state.acq.fastScanningX
            scanAmplitude = state.acq.scanAmplitudeX;
        else
            scanAmplitude = state.acq.scanAmplitudeY;
        end

        %while incrementMultiplier <= maxIncrementMultiplier
        incrementMultiplier = minIncrementMultiplier;
        while true
            totalIncrement = incrementMultiplier*linePeriodIncrement;
            if round(abs(totalIncrement/minLinePeriodIncrement)) - abs(totalIncrement/minLinePeriodIncrement) > 1e-10 %ensure that it rounds evenly, %VI120908A
                incrementMultiplier = incrementMultiplier+1;
                continue;
            end

            [fillFraction, linePeriod] = computeFillFrac(incrementMultiplier);
            numAOSamples = state.acq.outputRate * linePeriod; %guaranteed to be an integer, based on AO rate

            tooHigh = false;
            if ~state.acq.bidirectionalScan
                numPosSlopePoints = round(numAOSamples/(1+(2*abs(scanAmplitude)/zoomFactor)/(fillFraction*linePeriod*state.init.maxCommandSlope))); %VI122908A
                if numPosSlopePoints < round(fillFraction*numAOSamples)
                    tooHigh = true;
                end
            else
                numPosSlopePoints = numAOSamples;              
                slope = abs(2*scanAmplitude/zoomFactor)/activeLinePeriod; %VI121708B
                if slope > state.init.maxCommandSlope %VI122908A
                    tooHigh=true;
                end
            end

            if tooHigh
                if incrementMultiplier < maxIncrementMultiplier
                    incrementMultiplier = incrementMultiplier + 1;
                else
                    %%%VI010609A%%%%%%
                    incrementMultiplier = inf;
                    numPosSlopePoints = inf;
                    break;
                    %%%%%%%%%%%%%%%%%%
                end
            else
                break; %found the optimum FF!
            end

        end
        %%%VI010609A: Removed %%%%%%%%%%
        %         %Handle case where zoom was adjusted, i.e. couldn't satisfy max flyback rate with available FFs
        %         if adjZoom
        %             state.internal.minZoomFactor = zoomFactor;
        %         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

if isinf(optimizeFillFrac(1))
    resp = questdlg(['Exceeded max flyback rate with min fill fraction at current scan amplitude.' sprintf('\n') 'Shall we reduce the scan amplitude or reduce the scan speed?'], ...
        'Scan Amplitude Too High', 'Reduce Amplitude', 'Reduce Scan Speed','Reduce Amplitude');
    switch resp
        %%%VI010609A: Removed %%%%%%%%%%%%%%
        %         case 'Clamp Zoom'
        %             %state.acq.baseZoomFactor = max([state.acq.baseZoomFactor state.internal.minZoomFactor]); %VI123008A
        %             %updateGUIByGlobal('state.acq.baseZoomFactor', 'Callback', 1); %VI123008A
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        case 'Reduce Scan Speed'
            while true                
                state.internal.msPerLineGUI = state.internal.msPerLineGUI + 1;
                determineLinePeriodParams();
                if ~isinf(optimizeFillFrac(1))
                    break;
                end
            end
            
            updateGUIByGlobal('state.internal.msPerLineGUI');
        case 'Reduce Amplitude'
            while true
                %Adjust scan amplitude, while preserving fill fraction 
                aspectRatio = state.acq.scanAmplitudeY / state.acq.scanAmplitudeX;
                if state.acq.fastScanningX
                    state.acq.scanAmplitudeX = adjustScanAmplitude(state.acq.scanAmplitudeX);
                    state.acq.scanAmplitudeY = state.acq.scanAmplitudeX * aspectRatio;
                else
                    state.acq.scanAmplitudeY = adjustScanAmplitude(state.acq.scanAmplitudeY);
                    state.acq.scanAmplitudeX = state.acq.scanAmplitudeY / aspectRatio;
                end
                
                if ~isinf(optimizeFillFrac(1))
                    break;
                end
            end
            
            updateGUIByGlobal('state.acq.scanAmplitudeX');
            updateGUIByGlobal('state.acq.scanAmplitudeY');
    end

end
    function newAmplitude = adjustScanAmplitude(oldAmplitude)

        if state.acq.bidirectionalScan
            newAmplitude = fix(10 * sign(oldAmplitude) * activeLinePeriod * state.init.maxCommandSlope / 2) / 10; %VI122908A, VI010609B
        else
            newAmplitude = sign(oldAmplitude) * (abs(oldAmplitude) - 0.1);
        end
    end