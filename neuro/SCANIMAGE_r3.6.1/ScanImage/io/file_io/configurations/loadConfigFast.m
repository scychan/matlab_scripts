function out = loadConfigFast(number)
%% function out = loadConfigFast(number)
%Loads a configuration quickly with a hotkey or toggle button
%% SYNTAX
%   out = loadConfigFast(number)
%       number: Integer-valued number identifying fast configuration to load
%       out: 1 if configuration was loaded successfully, 0 otherwise
%
%% CHANGES
% VI043008A Vijay Iyer 04/30/08 -- Place focus (back) on mainControls window following fast configuration loading
% VI052208A Vijay Iyer 05/22/08 -- Give user some feedback when configuration is switching
% VI021009A Vijay Iyer 02/10/09 -- Refactor some common code to loadStandardModeConfig
% VI021009B Vijay Iyer 02/10/09 -- Add return value 'out' indicating whether load was successful or not
% VI021009C Vijay Iyer 02/10/09 -- Defer updating toggle button control to toggleFastConfig()
%
%% ********************************************************

global state gh

out = 0;

setStatusString('Switching config...'); %VI052208A
if ~isfield(state.files,['fastConfig' num2str(number)]) || isempty(getfield(state.files,['fastConfig' num2str(number)]))
    setStatusString(['Fast Config ' num2str(number) ' Not Set']);
    return
end
%status=state.internal.statusString;
[pname,fname,ext]=fileparts(getfield(state.files,['fastConfig' num2str(number)]));
state.standardMode.configName=fname;
state.standardMode.configPath=pname;

%%%VI021009A: Refactored%%%%
% turnOffMenus;
% turnOffExecuteButtons;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    loadStandardModeConfig;
catch   
    rethrow(lasterror);
    return;
end

%%%VI021009A: Refactored%%%
% turnOnMenus;
% turnOnExecuteButtons;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%setStatusString(status);
figure(gh.mainControls.figure1); %VI043008A

out = 1; %VI02109B
