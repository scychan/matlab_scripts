%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHANGES
%           12/15/03 by Tim O'Connor - Power array support (see below).
%           12/18/03 by Tim O'Connor - UncagingPulseImporter support.
%           TPMOD_1: Modified 12/31/03 Tom Pologruto - Fixes bug with
%           array being =0;
%           2/26/04 Tim O'Connor (TO22604d) - Reinitialize the eom stuff.
%           6/23/08 Vijay Iyer (VI062308) - Ensure that state.acq.saveDuringAcquisition is updated by the standardMode value
%           11/07/08 Vijay Iyer (VI110708) - Change messaging in case where no configuration is specified
%           12/01/08 Vijay Iyer (VI120108A) - Restore 2 commented-out lines that allow array variables to be properly read
%           9/24/08 Vijay Iyer (VI092408A) - Handled unified configuration GUI
%           12/12/08 Vijay Iyer (VI121208A) - Call setPockelsAcqParameters() rather than Configuration GUI callback
%           1/02/09 Vijay Iyer (VI010209A) - Remove call to setPockelsAcqParameters() altogether. Should be handled via applyChannelSettings >> applyConfigurationSettings()
%           1/16/09 Vijay Iyer (VI011609A) - Changed state.init.pockelsOn to state.init.eom.pockelsOn
%           1/22/09 Vijay Iyer (VI012209A) - Unpack newly created array CFG vars, using their associated string var
%           2/02/09 Vijay Iyer (VI020209A) - Reset configNeedsSaving flag upon loading configuration successfully
%           2/10/09 Vijay Iyer (VI021009A) - Refactored associated GUI actions during config loading into this function
%
%% CREDITS
% Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%% ************************************************************
function loadStandardModeConfig()
global state gh
out=0;

%%%VI021009A%%%%%%
turnOffMenus;
turnOffExecuteButtons;
%%%%%%%%%%%%%%%%%%



state.configName=state.standardMode.configName;
state.configPath=state.standardMode.configPath;
configSelected=1;

if isnumeric(state.configName) | length(state.configName)==0
    configSelected=0;
else	
    [flag, fname, pname, ext]=initGUIs([state.configPath '\' state.configName '.cfg']);
    if flag==0
        configSelected=0;
    end
end

if configSelected
    setStatusString('Config loaded');
    state.configName=fname;
    state.configPath=pname;
else
    setStatusString('Using default config'); %VI110708A
    disp('loadStandardModeConfig: No configuration selected.  Using ''default'' values (i.e. those from current INI file).'); %VI110708A
    state.configName='Default';
    state.configPath='';
end

%TO22604d - Reinitialize the eom stuff. Tim O'Connor 2/26/04
% if state.init.pockelsOn
%     try    
%      startEomGui;
%     catch
%      e = lasterror;
%      fprintf(2, 'ERROR: %s\n', e.message);
%     end
% end

state.acq.numberOfFrames=state.standardMode.numberOfFrames;
updateGUIByGlobal('state.acq.numberOfFrames');

state.internal.secondsCounter=state.standardMode.repeatPeriod;
updateGUIByGlobal('state.internal.secondsCounter');

state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
updateGUIByGlobal('state.acq.numberOfZSlices');

state.acq.zStepSize=state.standardMode.zStepPerSlice;
updateHeaderString('state.acq.zStepSize');

state.acq.averaging=state.standardMode.averaging;
updateHeaderString('state.acq.averaging');

state.acq.returnHome=state.standardMode.returnHome;
updateHeaderString('state.acq.returnHome');

%%%VI062308A
state.acq.saveDuringAcquisition=state.standardMode.saveDuringAcquisition;
updateGUIByGlobal('state.acq.saveDuringAcquisition'); %updateHeaderString may be sufficient..
%%%%

%%%VI012209A%%%%%%%%%%
% state.internal.fillFractionGUIArray = eval(state.internal.fillFractionGUIArrayString);
% state.internal.servoDelayArray = eval(state.internal.servoDelayArrayString);
%%%%%%%%%%%%%%%%%%%%%%

applyChannelSettings; %This calls applyConfigurationSettings() 
%TPMODPockels
%basicConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.basicConfigurationGUI.pockelsClosedOnFlyback); %VI092408A, VI121208A
% Load the strings for the arrays in the Power Transition editor....
if state.init.eom.pockelsOn %VI011609A
    
    %setPockelsAcqParameters; %VI121208A, VI010209A
    
    %Kluge for loading the power array matrix. -- Tim O'Connor 12/15/03
    powerTransitions('loadProtocolsFromString');
    
    %Removed the old kluge. -- Tim (again) 12/15/03
    %     if ~isempty(state.init.eom.powerTransitions.powerString) & ischar(state.init.eom.powerTransitions.powerString)
    %         state.init.eom.powerTransitions.power = eval(state.init.eom.powerTransitions.powerString);
    %         for beamCounter = 1 : length(state.init.eom.min)
    %             state.init.eom.powerTransitions.power(beamCounter,state.init.eom.powerTransitions.power<state.init.eom.min(beamCounter))=...
    %                 state.init.eom.min(beamCounter);
    %         end
    %         state.init.eom.powerTransitions.time = eval(state.init.eom.powerTransitions.timeString);
    %         state.init.eom.powerTransitions.transitionCount = eval(state.init.eom.powerTransitions.transitionCountString);
    %         powerTransitions('beamMenu_Callback', gh.powerTransitions.beamMenu);
    %     end
    %     if length(state.init.eom.uncagingMapper.) < state.init.eom.numberOfBeams
    %         state.init.eom.uncagingMapper.(state.init.eom.numberOfBeams) = 0;
    %     end
    %     if length(state.init.eom.uncagingMapper.) < state.init.eom.numberOfBeams
    %         state.init.eom.uncagingMapper.(state.init.eom.numberOfBeams) = 0;
    %     end
    %     if length(state.init.eom.uncagingMapper.) < state.init.eom.numberOfBeams
    %         state.init.eom.uncagingMapper.(state.init.eom.numberOfBeams) = 0;
    %     end

    %%%VI020809A: Removed %%%%%%%%%%%%%%%%%%%%%%%%
    %Most of this should be already (or will be) taken care of in verifyEomConfig()
    %     try
    %       %
    %       %Load the strings for the arrays in the Power Box editor....
    %       if ~isempty(state.init.eom.showBoxArrayString) & ischar(state.init.eom.showBoxArrayString)
    %           state.init.eom.showBoxArray = eval(state.init.eom.showBoxArrayString);
    %           state.init.eom.endFrameArray = eval(state.init.eom.endFrameArrayString);
    %           state.init.eom.startFrameArray = eval(state.init.eom.startFrameArrayString);
    %           %         state.init.eom.boxPowerArray = eval(state.init.eom.boxPowerArrayString);
    %           state.init.eom.boxPowerArray(:) = 0;
    %           state.init.eom.showBox(:) = 0;
    %           state.init.eom.powerBoxNormCoords(:) = 0;
    %           powerControl('beamMenu_Callback', gh.powerControl.beamMenu);
    %           %%%VI120108A%%%%%%%%%%%%%%%
    %           if ischar(state.init.eom.uncagingMapper.pixels)
    %               state.init.eom.uncagingMapper.pixels = ndArrayFromStr(state.init.eom.uncagingMapper.pixels);
    %           end
    %           if ischar(state.init.eom.uncagingMapper.enabled)
    %               state.init.eom.uncagingMapper.enabled = ndArrayFromStr(state.init.eom.uncagingMapper.enabled);
    %           end
    %           %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       end
    %     catch
    %         warning(lasterr);
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %     %Update the uncagingPulseImporter's configuration.
    %     % start TPMOD_1 12/31/03
    %     if ~isempty(state.init.eom.uncagingPulseImporter.cycleArrayString) & ~isnumeric(state.init.eom.uncagingPulseImporter.cycleArrayString)
    %     % end TPMOD_1 12/31/03
    %         state.init.eom.uncagingPulseImporter.cycleArray = str2num(state.init.eom.uncagingPulseImporter.cycleArrayString);
    %     else
    if length(state.init.eom.uncagingPulseImporter.cycleArray) < state.init.eom.numberOfBeams %VI013009A
        state.init.eom.uncagingPulseImporter.cycleArray = zeros(state.init.eom.numberOfBeams, 1);
    end
    state.init.eom.uncagingPulseImporter.position = 1;
    updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position');
    uncagingPulseImporter('positionText_Callback', gh.uncagingPulseImporter.positionText);
    uncagingPulseImporter('lineConversionFactorText_Callback', gh.uncagingPulseImporter.lineConversionFactorText);
    uncagingPulseImporter('pathnameText_Callback', gh.uncagingPulseImporter.pathnameText);
    if exist(state.init.eom.uncagingPulseImporter.pathnameText) == 7 %It's a directory.
        set(gh.uncagingPulseImporter.expandWindowButton, 'Enable', 'On');
        set(gh.uncagingPulseImporter.enableToggleButton, 'Enable', 'On');
        
        %Count the available pulses.
        %This method of counting is a bit of a cheat, maybe the filename prefix will be needed for specificity.
        state.init.eom.uncagingPulseImporter.pulseCount = length(dir(strcat(state.init.eom.uncagingPulseImporter.pathnameText, '*.mpf')));
    end
    
    state.init.eom.changed(:) = 1;
end

setStatusString('');

set(gh.userFcnGUI.UserFcnSelected,'Value',1,'String', state.userFcnGUI.UserFcnSelected); %VI120109A


verifyEomConfig;
resetConfigurationNeedsSaving(); %VI020209A

%%%VI021009A%%%%%%%%%
turnOnMenus;
turnOnExecuteButtons;
%%%%%%%%%%%%%%%%%%%%%

