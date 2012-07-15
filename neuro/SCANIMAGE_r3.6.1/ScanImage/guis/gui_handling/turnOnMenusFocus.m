function turnOnMenusFocus
% Controls to turn back on following FOCUS mode acquisition
%% CHANGES
%   VI101708A: imageGUI controls are now left on during FOCUS acquistion, so no need to turn them back on here
%   VI011609A: Changed state.init.pockelsOn to state.init.eom.pockelsOn -- Vijay Iyer 1/16/09
%% ***********************************************
global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','on');
set(gh.mainControls.File,'Enable','on');
%set(get(gh.imageGUI.figure1,'Children'),'Enable','on'); %VI101708A
%updateImageGUI; %VI101708A
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'On');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'On');
set(gh.mainControls.cyclePosition, 'Enable', 'On');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'On');
userPreferenceGUI('imageBox_Callback',gh.userPreferenceGUI.imageBox);
%TPMODPockels
if state.init.eom.pockelsOn %VI011609A
    set([gh.powerControl.Settings gh.powerControl.maxPower_Slider],'Enable','on');  %TPMODPockels
end
figure(gh.mainControls.figure1); %VI070208A

%%%VI020209A%%%%%%%%%%
set(gh.configurationGUI.pbLoadConfig,'Enable','On');
if state.internal.configurationNeedsSaving
    setConfigurationNeedsSaving(); %Refresh GUI changes associated with positive flag state
end
%%%%%%%%%%%%%%%%%%%%%%