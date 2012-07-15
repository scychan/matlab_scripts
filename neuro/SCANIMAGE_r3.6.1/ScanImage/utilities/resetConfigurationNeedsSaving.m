function resetConfigurationNeedsSaving()
%RESETCONFIGURATIONNEEDSSAVING Reset configurationNeedsSaving flag and update GUI props accordingly

global state gh

state.internal.configurationNeedsSaving = 0;
set(gh.configurationGUI.pbSaveConfig, 'Enable','off','ForegroundColor',[0 0 0]);
set(gh.configurationGUI.configurationName,'BackgroundColor',get(0,'defaultUIControlBackgroundColor'));
