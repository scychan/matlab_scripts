function setPockelsAcqParameters
%% function setPockelsAcqParameters
%   Sets acquisition-time parameters related to the Pockels Cell
%
%% NOTES
%       DEPRECATED: PockelsCellLineDelay and PockelsCellFillFraction vars have been removed -- Vijay Iyer 1/27/09
%
%       This function created so either configuration GUI changes or configuration loading can funnel to the same place
%       
%       Code copied/pasted from basicConfigurationGUI's pockelsClosedOnFlyback_Callback()
%
%% CREDITS
%   Created 12/12/08 by Vijay Iyer
%% CHANGES
%   VI010209A: Pockels Cell line delay now tied to internal line delay parameter, and not user adjustable -- Vijay Iyer 1/02/09
%   VI011909A: Account for AO Rate multiplier in setting the default Pockels fill fraction -- Vijay Iyer 1/19/09
%   VI012109A: msPerLine is now actually in milliseconds -- Vijay Iyer 1/21/09
%% 
global state gh

%VI010209A: Do this, regardless of whether pockelsClosedOnFlyback is selected
state.acq.pockelsCellLineDelay = state.internal.lineDelay; %VI092108A

if state.acq.pockelsClosedOnFlyback
    %state.acq.pockelsCellLineDelay = state.acq.lineDelay;

    %%%VI011909A%%%%%%%
    fillFracExtraSamples = 2;    
    if state.internal.increaseAORates
       fillFracExtraSamples = fillFracExtraSamples * state.internal.featureAORateMultiplier;
    end
    %%%%%%%%%%%%%%%%%%%
    
    %state.acq.pockelsCellFillFraction = state.acq.fillFraction+state.acq.cuspDelay;
    state.acq.pockelsCellFillFraction = state.acq.fillFraction +  fillFracExtraSamples * (1/state.acq.outputRate) / (1e-3 * state.acq.msPerLine); %VI092108B, VI011909A, VI012109A
    
    set(gh.basicConfigurationGUI.pockelsCellFillFraction, 'Enable', 'Off');
    %set(gh.basicConfigurationGUI.pockelsCellLineDelay, 'Enable', 'Off'); %VI010209A
    set(gh.basicConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'Off');
else
    set(gh.basicConfigurationGUI.pockelsCellFillFraction, 'Enable', 'On');
    %%%VI010209A: Removed %%%%%%
    %     if get(gh.basicConfigurationGUI.cbBidirectionalScan,'Value') == 0 %VI030508A
    %         set(gh.basicConfigurationGUI.pockelsCellLineDelay, 'Enable', 'On');
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gh.basicConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'On');
end

updateGUIByGlobal('state.acq.pockelsCellFillFraction')
updateGUIByGlobal('state.acq.pockelsCellLineDelay')
