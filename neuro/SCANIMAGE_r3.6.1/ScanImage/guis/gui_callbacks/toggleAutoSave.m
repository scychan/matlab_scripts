function toggleAutoSave
% BSMOD - 1/1/2 - callback when user selects 'autoSave' from 'settings' menu
%% CHANGES


    global gh state
	% get the index of the standard mode selection of the settings menu
	children=get(gh.mainControls.Settings, 'Children');			
	index=getPullDownMenuIndex(gh.mainControls.Settings, 'Auto save');
	
	checkState=get(children(index), 'Checked'); % check state of check mark nexted to 'autosave' option

    if strcmp(checkState,'on')     % it is on, so turn it off
        state.files.autoSave=0;
    else
        state.files.autoSave=1;
    end
    
    %updateGUIByGlobal('state.files.autoSave','Callback',1); %This would be more elegant, but doesn't work because it only pertains to GUI controls, not menu items
    updateAutoSaveCheckMark;
    
       