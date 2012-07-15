function turnOffMenus
%% NOTES
%   This function is called during GRAB/LOOP/SNAPSHOT acquisitions, preventing actions from occuring during acquisition
%% CHANGES
%   VI020309A: Hide configuration GUI now as well, but don't toggle the Show/Hide button -- Vijay Iyer 2/2/09
%   VI021309A: Hide alignment GUI -- Vijay Iyer 2/13/09
%% ******************************************

global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','off');
set(gh.mainControls.File,'Enable','off');
set(setdiff(findobj(gh.imageGUI.figure1,'-not','Type','uipanel'),gh.imageGUI.figure1), 'Enable', 'Off'); %VI022009A
state.internal.oldRotBoxString=state.internal.showRotBox;
if strcmp(state.internal.oldRotBoxString,'<<')
    state.internal.showRotBox='>>';
    updateMainControlSize;
end
set(gh.mainControls.showrotbox,'Enable','off');
set(gh.mainControls.reset, 'Enable', 'Off');
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'Off');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'Off');
set(gh.mainControls.cyclePosition, 'Enable', 'Off');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'Off');
hideGUI('gh.configurationGUI.figure1'); %VI012909A
updateGUIByGlobal('state.internal.showAlignGUI','Value',0,'Callback',1); %VI021309A
enableEomGui(0);    %TPMODPockels


