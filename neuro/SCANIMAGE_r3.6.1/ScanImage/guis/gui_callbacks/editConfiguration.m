function editConfiguration
% brings up configuration window for editting
global gh state

seeGUI('gh.configurationGUI.figure1'); %VI012809A

%%%VI012809A: Removed %%%%%%%%%
%     if strcmpi(get(gh.basicConfigurationGUI.figure1,'Visible'),'off') %VI092508A: Only reset flag and explicitly show GUI if it's not already showing
%         state.internal.configurationChanged=0;
%         updateGUIByGlobal('state.internal.configurationChanged','Callback',1);
%         seeGUI('gh.basicConfigurationGUI.figure1');
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
