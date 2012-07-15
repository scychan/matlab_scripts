function updateIncreaseAORates(handle)
%% function updateIncreaseAORates(handle)
% Callback function that handles update to the user preference indicating that AO rates should be augmented
%
%% NOTES
%   DEPRECATED - This is now a CFG, rather than USR setting. Because changes are automatically applied on loading, no need to be an INI callback -- Vijay Iyer 2/13/09
%   
%   Being an INI-named callback allows this to be called during either a GUI control or CFG/USR file loading event
%
%% CHANGES
%   VI011909A: Use state.init.eom.featureAORateMultiplier -- Vijay Iyer 1/19/09
%   VI012309A: Store AO period increment value here -- Vijay Iyer 1/23/09
%% CREDITS
%   Created 1/16/09, by Vijay Iyer
%% ******************************************************************
global state gh

state.acq.outputRate = 50000;
state.internal.minAOPeriodIncrement = 1/state.acq.outputRate; %VI012309A
if state.internal.increaseAORates %VI011909A
    state.acq.outputRate = state.acq.outputRate * state.internal.featureAORateMultiplier;
end
updateGUIByGlobal('state.acq.outputRate');

if ~isempty(state.acq.dm) %Screen out startup case where this is invoked prior to @daqmanager being enabled
    %Update sample rate of Pockels channels
    if state.init.eom.pockelsOn 
        for i = 1:state.init.eom.numberOfBeams
            setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'SampleRate', state.acq.outputRate);
        end
    end

    %Update sample rate of mirror channels
    warning('off','daq:set:propertyChangeFlushedData');
    set([state.init.ao2 state.init.ao2F],'SampleRate',state.acq.outputRate)
    warning('on','daq:set:propertyChangeFlushedData');

    %Refresh mirror data, and flag Pockels data for (last-second) refreshing
    if ~isempty(state.init.eom.lut) %VI020909A: Screen out near startup case where this is invoked prior to Pockels calibration 
        applyConfigurationSettings();
    end
end







        
        