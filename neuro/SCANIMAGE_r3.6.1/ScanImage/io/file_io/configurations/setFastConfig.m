function setFastConfig(hObject) %VI020909A
%% function setFastConfig(hObject)
%   Callback handler for actions causing fastConfig setting
%% NOTES
%   Implemented as INI-file callback so as to be called either via a UI action or USR/CFG loading
%
%% CHANGES
%   VI020909A: Take an object handle rather than a number as the primary argument -- Vijay Iyer 02/09/09
%   VI020909B: Use configPath or lastFastConfigPath as starting path to uigetfile, without actually changing directory -- Vijay Iyer 02/09/09
%   VI020909C: Store fast config filename in tooltip of mainControl toggle button -- Vijay Iyer 02/09/09
%   VI021009A: Defer GUI update based on newly set fastConfig to updateFastConfig() -- Vijay Iyer 02/10/09
%   VI021009B: Don't allow duplicate fastConfig settings -- Vijay Iyer 02/10/09
%   VI050409A: Revert VI0201009B -- Vijay Iyer 05/04/09
%
%% *****************************************

global state gh

%%%VI020909A%%%%%%%%%%
configNumStr = deblank(get(hObject,'Tag'));
configNum = str2num(configNumStr(end)); %Last value is the config number (only handle single digit values at moment)
%%%%%%%%%%%%%%%%%%%%%%


if ~isempty(state.configPath) && isdir(state.configPath)
    %cd(state.configPath); %VI020909B
    startPath = state.configPath; %VI020909B
elseif ~isempty(getfield(state.files,'lastFastConfigPath')) && isdir(getfield(state.files,'lastFastConfigPath')) %VI020909B
     %cd(getfield(state.files,'lastFastConfigPath')); %VI020909B
     startPath = getfield(state.files,'lastFastConfigPath'); %VI020909B
else
    startPath = cd; %VI020909B
end

%%%VI020909B: Ensure that path has slash at end
if ~strcmpi(startPath(end),filesep)
    startPath = [startPath filesep];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fname, pname]=uigetfile([startPath '*.cfg'], 'Choose Configuration name...');
if isnumeric(fname)
    disp('No Quick Configuration Set');
    return
end

%%%VI050409A: Removed %%%%%%%%%%%%%%%
% %%%VI021009B: Don't allow a duplicate fast config%%%%%%
% if any(arrayfun(@(num)strcmpi(fullfile(pname,fname), state.files.(['fastConfig' num2str(num)])), 1:state.files.numFastConfigs))
%     disp('Duplicate Fast Config settings not allowed');
%     return;
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI021009A%%%%%%%
state.files.lastFastConfigPath = pname; 
state.files.(['fastConfig' num2str(configNum)]) = fullfile(pname,fname); 
updateFastConfig(configNum); 
%%%%%%%%%%%%%%%%%%%

%%%VI021009A: Removed %%%%%%%%%
% if isfield(state.files,['fastConfig' num2str(number)])
%     state.files=setfield(state.files,['fastConfig' num2str(number)],[pname fname]);
%     state.files=setfield(state.files,'lastFastConfigPath', pname);
%     h=getfield(gh.mainControls,['fastConfig' num2str(number)]);
%     label=get(h,'Label');
%     ind=findstr(label,' ');
%     label(1:ind(end))=[];
%     label=[fname '   ' label];
%     set(h,'Label',label);
%     
%     set(gh.mainControls.(['tbFastConfig' num2str(number)]),'TooltipString',fname); %VI020909C
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
