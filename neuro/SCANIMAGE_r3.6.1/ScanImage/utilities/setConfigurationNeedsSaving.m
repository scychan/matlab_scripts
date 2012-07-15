function setConfigurationNeedsSaving()
%SETCONFIGURATIONNEEDSSAVING Set configurationNeedsSaving flag and update GUI props accordingly

global state gh

state.internal.configurationNeedsSaving=1;
set(gh.configurationGUI.pbSaveConfig,'Enable','on','ForegroundColor',[0 .5 0]);
set(gh.configurationGUI.configurationName,'BackgroundColor',[1 1 .7]);
