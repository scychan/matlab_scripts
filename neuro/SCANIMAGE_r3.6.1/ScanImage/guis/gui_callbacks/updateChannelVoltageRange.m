function updateChannelVoltageRange(handle)
%% function updateChannelVoltageRange(handle)
% Callback function that handles update to voltage range value for a channel
%
%% NOTES
%   Being an INI-named callback allows this to be called during either a GUI control or CFG file loading event
%
%% CREDITS
%   Created 1/11/09, by Vijay Iyer
%% ******************************************************************
global state gh

inGlobalName = get(handle,'Tag');
chanNum = str2num(inGlobalName(end));

val = get(handle,'Value'); %VI110209A
switch val %VI110209A
    case {1,5} %VI110209A
        voltageRange = 1;        
    case {2,6} %VI110209A
        voltageRange = 2;
    case {3,7} %VI110209A
        voltageRange = 5;             
    case {4,8} %VI110209A
        voltageRange = 10;
end
invert = double(val > 4); %VI110209A

%eval(['state.acq.inputVoltageRange' num2str(chanNum) '=' num2str(voltageRange) ';']); %VI110209A
chanStr = num2str(chanNum);
state.acq.(['inputVoltageRange' chanStr]) = voltageRange;
state.acq.(['inputVoltageInvert' chanStr]) = invert;



        
        