function varargout =saveCurrentConfigAs(curFileDefault)
%% function varargout =saveCurrentConfigAs(curFileDefault)
%   Save current configuration to user specified CFG file
%% SYNTAX
%   saveCurrentConfigAs()
%
%% CHANGES
%   VI020209A: No longer use 'cd' to change the default path option -- Vijay Iyer 2/2/09
%% *******************************************
global state

%%%VI020209A
% if ~isempty(state.configPath)
%     cd(state.configPath)
% end
%%%%%%%%%%%%

%%%VI020209A%%%%%%%%%%%%%
if ~isempty(state.configPath)
    defaultName = state.configPath;
else
    defaultName = cd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
   
[fname, pname]=uiputfile('*.cfg', 'Choose Configuration name...',defaultName); %VI020209A

if ~isnumeric(fname)
    setStatusString('Saving config...');

    periods=findstr(fname, '.');
    if any(periods)
        fname=fname(1:periods(1)-1);
    end
    state.configName=fname;
    state.configPath=pname;

    %%%VI020209A%%%%%%%%%
    if state.standardMode.standardModeOn
        state.standardMode.configName = state.configName;
        state.standardMode.configPath = state.configPath;
    end
    %%%%%%%%%%%%%%%%%%%%%%

    updateGUIByGlobal('state.configName');
    saveCurrentConfig;
    setStatusString('');
    state.internal.configurationNeedsSaving=0;
else
    setStatusString('Cannot open file');
end
