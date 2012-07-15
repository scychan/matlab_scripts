function resetConfigurationChanged()
%RESETCONFIGURATIONCHANGED Reset configurationChanged flag and update GUI props accordingly

global state gh

state.internal.configurationChanged=0;
set(gh.configurationGUI.pbApplyConfig,'Enable','off','ForegroundColor',[0 0 0]); 
turnOnExecuteButtons('state.internal.configurationChanged'); 