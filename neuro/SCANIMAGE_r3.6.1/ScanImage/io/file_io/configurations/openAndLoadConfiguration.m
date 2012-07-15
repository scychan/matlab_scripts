function out=openAndLoadConfiguration
% Allows user to select a configuration from disk and loads it
%
%% CHANGES
%   Tim O'Connor 2/19/04 TO21904a - Make messages more understandable.
%   TO3204b - Pick up path from standard.ini, for convenience.
%   VI012709A: Use resetConfigurationNeedsSaving() -- Vijay Iyer 1/27/09
%   VI021009A: Refactor some common code to loadStandardModeConfig -- Vijay Iyer 2/10/09
%   VI021009B: Update fast config toggle buttons following manual configuration load -- Vijay Iyer 2/10/09
%   VI021009C: Don't use 'cd' to direct initial configruration path choice -- Vijay Iyer 2/10/09
%   VI021009D: Set status string to final state of operation, rather than restoring original state -- Vijay Iyer 2/10/09
%% CREDITS
%   Author: Bernardo Sabatini
%% ***********************************'

out=0;

global state

status=state.internal.statusString;
setStatusString('Loading Configuration...');
if state.internal.configurationNeedsSaving==1

    if ~isempty(state.configName)
        button = questdlg(['Do you want to save changes to ''' state.configName '''?'],'Save changes?','Yes','No','Cancel','Yes');
    else
        %TO21904 - Don't just print a set of empty quotes.
        button = questdlg(['Do you want to save changes to the current configuration?'],'Save changes?','Yes','No','Cancel','Yes');
    end

    if strcmp(button, 'Cancel')
        disp(['*** LOAD CYCLE CANCELLED ***']);
        setStatusString('Cancelled');
        return
    elseif strcmp(button, 'Yes')
        if ~isempty(state.configName)
            disp(['*** SAVING CURRENT CONFIGURATION = ' state.configPath '\' state.configName ' ***']);
            flag=saveCurrentConfig;
            if ~flag
                disp(['openAndLoadConfiguration: Error returned by saveCurrentCycle.  Cycle may not have been saved.']);
                setStatusString('Error saving file');
                return
            end
        else
            %TO21904a - Need to choose a name.
            saveCurrentConfigAs;
        end
        %state.internal.configurationNeedsSaving=0; %VI012709A
        resetConfigurationNeedsSaving(); %VI012709A
    end
end

%%%VI021009C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(state.configPath) & isdir(state.configPath)
    startPath = state.configPath;
elseif ~isempty(state.standardMode.configPath)
    startPath = state.standardMode.configPath;
else
    startPath = cd;
end
if ~strcmpi(startPath(end),filesep) %Ensure startPath ends with a slash
    startPath = [startPath filesep];
end
[fname, pname] = uigetfile([startPath '*.cfg'], 'Choose configuration to load');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI021009C: Redone%%%%%%%%%%%%%%%%
% if ~isempty(state.configPath) & isdir(state.configPath)
%     try
%         cd(state.configPath)
%     end
% end
% %TO3204b - Use a prespecified path from standard.ini, if possible.
% if ~isempty(state.standardMode.configPath)
%     %Make sure it's terminated with a '\' character.
%     if state.standardMode.configPath(end) ~= '\'
%         state.standardMode.configPath = [state.standardMode.configPath '\'];
%     end
%     [fname, pname] = uigetfile([state.standardMode.configPath '*.cfg'], 'Choose configuration to load');
% else
%     [fname, pname] = uigetfile('*.cfg', 'Choose configuration to load');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isnumeric(fname)
    periods=findstr(fname, '.');
    if any(periods)
        fname=fname(1:periods(1)-1);
    else
        disp('openAndLoadConfiguration: Error: found file name without extension');
        setStatusString('Can''t open file');
        return
    end
    
    state.standardMode.configName=fname;
    state.standardMode.configPath=pname;
    
    %%%VI021009A: Refactored%%%%%%
    %     turnOffMenus;
    %     turnOffExecuteButtons;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%VI021009A: Removed%%%%%%%%%%%%
    %     try
    %         if state.init.pockelsOn
    %             for j = 1 : state.init.eom.numberOfBeams
    %                 h=findobj('Type','Rectangle','Tag', sprintf('PowerBox%s', num2str(j)));
    %                 if ~isempty(h)
    %                     delete(h);
    %                 end
    %             end
    %         end
    %     catch
    %         warning(lasterr)
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    loadStandardModeConfig;
    
    %%%VI021009B%%%%%%%%%%%%
    configName = fullfile(state.configPath,[state.configName '.cfg']);   
    configMatch = find(arrayfun(@(num)strcmpi(configName, state.files.(['fastConfig' num2str(num)])), 1:state.files.numFastConfigs));
    if configMatch %loaded configuration matched a fastConfig
        toggleFastConfig(configMatch,1); %this will automatically turn off all the others
    else %loaded configuration didn't match any of the fastConfigs
        arrayfun(@(num)toggleFastConfig(num,0), 1:state.files.numFastConfigs); %turn off all the toggle buttons
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%VI021009A: Refactored%%%%%%
    %     turnOnMenus;
    %     turnOnExecuteButtons;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    setStatusString('Config Loaded'); %VI021009D
else
    setStatusString(''); %VI021009D
end

%    closeConfigurationGUI; %VI092508A
%Note, this call is probably not necesary--the call to loadStandardmodeConfig calls applyConfigurationSettings(). -- Vijay Iyer 9/27/08
applyConfigurationSettings; %VI092508A
