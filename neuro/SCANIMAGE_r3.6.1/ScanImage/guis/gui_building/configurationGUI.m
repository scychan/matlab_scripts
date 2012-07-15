function varargout = configurationGUI(varargin)
% BASICCONFIGURATIONGUI_OLD Application M-file for configurationGUI.fig
%    FIG = BASICCONFIGURATIONGUI_OLD launch configurationGUI GUI.
%    BASICCONFIGURATIONGUI_OLD('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 21-Oct-2009 18:00:04
%
%% NOTES
%   Function was created anew, derived from basicConfigurationGUI -- Vijay Iyer 1/27/09
%
%% CHANGES
%   VI013109A: Determine whether to restart FOCUS based on Pockels parameters; use setScanProps() instead of stopAndRestartFocus() directly -- Vijay Iyer 1/31/09
%   VI0120209A: Defer to setConfigurationNeedsSaving() when setting that flag -- Vijay Iyer 2/2/09
%   VI021809A: Correctly determine the zoom array index based on current zoom level -- Vijay Iyer 2/18/09
%   VI022009A: Ensure that msPerLine display is updated when changing the fill fraction -- Vijay Iyer 2/20/09
%   VI031009A: Change state.init.pockelsOn to state.init.eom.pockelsOn -- Vijay Iyer 3/10/09
%   VI032409A: Allow scan delay to be incremented in steps of the AO period, not 2x that value (since scan delay is asymmetrically applied now) -- Vijay Iyer 3/24/09
%   VI032409B: Handle acq delay increment uniformly now between bidi and sawtooth cases; coarse value is now determined as value required to make integer steps -- Vijay Iyer 3/24/09
%   VI040509A: Handle new input/output rate scheme
%   VI041009A: Handle new input/output rate auto-adjust options. The heavy lifting is in updateAcquisitionParameters(). -- Vijay Iyer 4/10/09
%   VI041209A: constrainAcqDelay() and computeAcqDelayIncrement() moved to external functions to allow reuse -- Vijay Iyer 4/12/09
%   VI041209B: Complete VI032409A by allowing scan delay to be incremented, not just specified, in steps of AO period, rather than 2x that value -- Vijay Iyer 4/12/09
%   VI042709A: Replace generic_callback() calls with explicitly coded callbacks, albeit slightly redundant -- Vijay Iyer 4/27/09
%   VI043009A: Update frame rate var/display upon changing fill fraction -- Vijay Iyer 4/30/09
%   VI102609A: Defer scanAmplitude callback processing to updateScanAmplitude() -- Vijay Iyer 10/26/09
%
%% *********************************************************

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
    set(fig,'KeyPressFcn',@genericKeyPressFunction); %VI043008A
    %%%%VI070308 -- Ensure all children respond to key presses, when they have the focus (for whatever reason)
    kidControls = findall(fig,'Type','uicontrol');
    for i=1:length(kidControls)
        if ~strcmpi(get(kidControls(i),'Style'),'edit')
            set(kidControls(i),'KeyPressFcn',@genericKeyPressFunction');
        end
    end
    %%%%%%
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end
    
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = generic_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
% state.internal.configurationChanged=1;
% state.internal.configurationNeedsSaving=1;
flagConfigChange; %VI092508A
genericCallback(h);
%%%VI121608A%%%%%
% if any(strcmp(get(h,'tag'),{'xScanAmplitude','yScanAmplitude'}))
%     state.internal.aspectRatioChanged=1;
% end
%%%%%%%%%%%%%%%%%

function scanAmplitude_Callback(h) 
flagConfigChange; 
genericCallback(h);
%state.internal.aspectRatioChanged=1; %VI102609A

% --------------------------------------------------------------------
function xScanAmplitude_Callback(hObject, eventdata, handles)
scanAmplitude_Callback(hObject);

% --------------------------------------------------------------------
function yScanAmplitude_Callback(hObject, eventdata, handles)
scanAmplitude_Callback(hObject);

% --------------------------------------------------------------------
function cbBlankFlyback_Callback(hObject, eventdata, handles)
pockelsParam_Callback(hObject);

% --------------------------------------------------------------------
function etFillFracAdjust_Callback(hObject, eventdata, handles)
pockelsParam_Callback(hObject);

% --------------------------------------------------------------------
function varargout = pockelsParam_Callback(hObject, eventdata, handles, varargin)
global state 
flagConfigChange;
genericCallback(hObject);
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A

% --------------------------------------------------------------------
function varargout = pixelsPerLine_Callback(h, eventdata, handles, varargin)
global state
flagConfigChange;
state.acq.pixelsPerLineGUI = get(h,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(h, state.acq.pixelsPerLineGUI));
genericCallback(h);

% --------------------------------------------------------------------
function varargout = fastScanRadioX_Callback(h, eventdata, handles, varargin)
global gh state
flagConfigChange; 
genericCallback(h);
state.acq.fastScanningY = 0;
updateGUIByGlobal('state.acq.fastScanningY');

% --------------------------------------------------------------------
function varargout = fastScanRadioY_Callback(h, eventdata, handles, varargin)
global gh state
flagConfigChange; 
genericCallback(h);
state.acq.fastScanningX = 0;
updateGUIByGlobal('state.acq.fastScanningX');

% --------------------------------------------------------------------
function varargout = linesPerFrame_Callback(h, eventdata, handles, varargin)
global state
flagConfigChange;
genericCallback(h);

% --------------------------------------------------------------------
function pbApplyConfig_Callback(hObject, eventdata, handles)
global state

%Do the following to ensure that any queued callbacks are executed (MW Service Request  1-6D7KR)
hideGUI('gh.configurationGUI.figure1');
drawnow; 
seeGUI('gh.configurationGUI.figure1'); 

if state.internal.configurationChanged==1
    applyConfigurationSettings;
end

% --------------------------------------------------------------------
function tbShowAdvanced_Callback(hObject, eventdata, handles)
global gh

extraChars = 16.2; %how many extra characters to extend height of Fig
parentFig = ancestor(hObject,'figure');
kidControls = [findobj(parentFig,'Type','uicontrol'); findobj(parentFig,'Type','uipanel')];
posn = get(parentFig,'Position');
if get(hObject,'Value')
    posn2Adj = -extraChars;
    posn4Adj = extraChars;
    set(hObject,'String','/\');       
else
    posn2Adj = extraChars;
    posn4Adj = -extraChars;
    set(hObject,'String','\/');
end
posn(2) = posn(2) + posn2Adj;
posn(4) = posn(4) + posn4Adj;
set(parentFig,'Position',posn);
for i=1:length(kidControls)    
    if ~strcmpi(get(kidControls(i),'Type'),'uipanel') && isempty(ancestor(kidControls(i),'uipanel')) %only shift non panel controsl
        kidPosn = get(kidControls(i),'Position');
        kidPosn(2) = kidPosn(2) - posn2Adj;
        set(kidControls(i),'Position',kidPosn);
    elseif strcmpi(get(kidControls(i),'Type'),'uipanel') %shift the panel itself
        kidPosn = get(kidControls(i),'Position');
        kidPixPosn = getpixelposition(kidControls(i));
        pixCharConversion = kidPixPosn(4)/kidPosn(4);
        kidPixPosn(2) = kidPixPosn(2) - posn2Adj*pixCharConversion;
        setpixelposition(kidControls(i),kidPixPosn);
    end
end

% --------------------------------------------------------------------
function pbOptimizeScanAmp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function etScanDelay_Callback(hObject, eventdata, handles)
genericCallback(hObject);

%Update scan delay var (subject to all constraints) and its various internal representations
updateScanDelay();

%Update config array display
updateConfigZoomFactor();

%Flag configuration change, and trigger applyConfiguration if change occurred during FOCUS
flagConfigChange(true); 

% --------------------------------------------------------------------
function pbDecScanDelay_Callback(hObject, eventdata, handles)
stepScanDelay('dec');

% --------------------------------------------------------------------
function pbIncScanDelay_Callback(hObject, eventdata, handles)
stepScanDelay('inc');

% --------------------------------------------------------------------
function etAcqDelay_Callback(hObject, eventdata, handles)
genericCallback(hObject);

global state gh

%Contrain/store current acq delay value
state.internal.acqDelayGUI = constrainAcqDelay(state.internal.acqDelayGUI,true);
updateGUIByGlobal('state.internal.acqDelayGUI');
state.acq.acqDelay = state.internal.acqDelayGUI * 1e-6;

%Update array (and its display)
state.internal.acqDelayArray(getConfigZoomFactor()) = state.internal.acqDelayGUI;
updateConfigZoomFactor();

%Flag configuration change, and allow it to occur during FOCUS
acqDelayCmdEffect = (state.init.eom.pockelsOn && state.acq.pockelsClosedOnFlyback) || state.acq.staircaseSlowDim; %VI020509A: Determine if acq delay change requires change in command waveform(s)
flagConfigChange(true,acqDelayCmdEffect); %VI013109A, VI020509A

% --------------------------------------------------------------------
function pbDecAcqDelay_Callback(hObject, eventdata, handles)
stepAcqDelay('dec');

% --------------------------------------------------------------------
function pbIncAcqDelay_Callback(hObject, eventdata, handles)
stepAcqDelay('inc');

% --------------------------------------------------------------------
function cbFineAcqAdjust_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function pmFillFrac_Callback(hObject, eventdata, handles)
genericCallback(hObject);

global state 

%Update fill frac var, and its various internal/GUI representations
[state.acq.fillFraction state.acq.msPerLine] = decodeFillFractionGUI(state.internal.fillFractionGUI);
state.internal.fillFractionGUIArray(getConfigZoomFactor()) = state.internal.fillFractionGUI;
updateGUIByGlobal('state.acq.msPerLine'); %VI022009A

%Update scan delay, as it may have to change based on new FF var
updateScanDelay();

%Update config array display
updateConfigZoomFactor();

%Update frame rate var/display
updateFrameRate(); %Vi043009A

%Flag configuration change, and allow it to occur during FOCUS
flagConfigChange(true); 

% --------------------------------------------------------------------
function varargout = pmFillFracConfig_Callback(hObject, eventdata, handles) %VI092408A: Renamed to pmFillFractOpts
flagConfigChange; 
genericCallback(hObject);

global state gh

state.internal.fillFractionGUIArray(state.internal.configZoomFactor) = state.internal.fillFractionGUIConfig;

%Refresh scanDelayConfig given new fillFractionConfig value
updateGUIByGlobal('state.internal.scanDelayConfig','Callback',1);

%Update array/current display
updateConfigZoomFactor();
updateZoom();

% --------------------------------------------------------------------
function etAcqDelayConfig_Callback(hObject, eventdata, handles)
flagConfigChange; 
genericCallback(hObject);

global state
state.internal.acqDelayConfig = constrainAcqDelay(state.internal.acqDelayConfig,true);
updateGUIByGlobal('state.internal.acqDelayConfig');

state.internal.acqDelayArray(state.internal.configZoomFactor) = state.internal.acqDelayConfig;
updateConfigZoomFactor(); 
updateZoom();

% --------------------------------------------------------------------
function etScanDelayConfig_Callback(hObject, eventdata, handles)
flagConfigChange; 
genericCallback(hObject);

global state

%Ensure value satisfies discretization & FF constraints
[fillFraction, msPerLine] = decodeFillFractionGUI(state.internal.fillFractionGUIConfig);
state.internal.scanDelayConfig = constrainScanDelay(state.internal.scanDelayConfig, fillFraction, msPerLine);
updateGUIByGlobal('state.internal.scanDelayConfig');

state.internal.scanDelayArray(state.internal.configZoomFactor) = state.internal.scanDelayConfig;

%Update array/current display
updateConfigZoomFactor(); 
updateZoom();

% --------------------------------------------------------------------
function varargout = pmMsPerLine_Callback(h, eventdata, handles, varargin) %VI092408A: formerly etMsPerLine2_Callback in advancedConfigurationGUI
global state
flagConfigChange; 
genericCallback(h);

%Update the Config Scan Delay values, which applies constraint if needed
lastConfigZoomFactor = state.internal.configZoomFactor;
for i=1:state.acq.baseZoomFactor
    state.internal.configZoomFactor = i;
    updateConfigZoomFactor();
    updateGUIByGlobal('state.internal.scanDelayConfig','Callback',1);
end
state.internal.configZoomFactor = lastConfigZoomFactor;
updateConfigZoomFactor();

% --------------------------------------------------------------------
function tbConfigChanged_Callback(hObject, eventdata, handles)

global gh 

if get(hObject,'Value')
    set(hObject,'BackgroundColor',[1 0 0]);
    set(gh.configurationGUI.pbApplyConfig,'Enable','on');    
    set(gh.configurationGUI.pbSaveConfig,'Enable' ,'on');
else
    set(hObject,'BackgroundColor',[0 1 0]);
    set(gh.configurationGUI.pbApplyConfig,'Enable','off');
end


% --------------------------------------------------------------------
function etMaxFlybackRate_Callback(hObject, eventdata, handles)

global state

choice = questdlg(['The max flyback rate should be changed with caution. Are you sure of your change?' sprintf('\n') ...
    'NOTE: Changes to this parameter are not saved with configuration. To save change, edit your INI file (typ. standard.ini)'], 'WARNING', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        genericCallback(hObject);
    case 'No'
        updateGUIByGlobal('state.internal.maxFlybackRate'); %Restores past value
end


% --------------------------------------------------------------------
function etMinZoom_Callback(hObject, eventdata, handles)
flagConfigChange; 
genericCallback(hObject);

% --------------------------------------------------------------------
function etBaseZoom_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

global state 
%Reset config zoom factor to valid value, if needed
if state.internal.configZoomFactor > state.acq.baseZoomFactor
    state.internal.configZoomFactor = state.acq.baseZoomFactor;
end 
updateGUIByGlobal('state.internal.configZoomFactor','Callback',1);


% --------------------------------------------------------------------
function etConfigZoomFactor_Callback(hObject, eventdata, handles)
genericCallback(hObject);


% --------------------------------------------------------------------
function pbIncZoom_Callback(hObject, eventdata, handles)
incrementConfigZoomFactor(1);

% --------------------------------------------------------------------
function pbDecZoom_Callback(hObject, eventdata, handles)
incrementConfigZoomFactor(-1);

% --------------------------------------------------------------------
function pbAutoCompute_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function etShutterDelay_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

% --------------------------------------------------------------------
function cbStaircaseSlowDim_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

% --------------------------------------------------------------------
function cbDisableStriping_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

%%%VI040509A: Removed %%%%%%%%%%
% % --------------------------------------------------------------------
% function cbIncreaseAORates_Callback(hObject, eventdata, handles)
% flagConfigChange();
% genericCallback(hObject);
% 
% global state
% if state.internal.increaseAORates 
%     state.acq.outputRate = state.internal.baseOutputRate * state.internal.featureAORateMultiplier;
% else
%     state.acq.outputRate = state.internal.baseOutputRate; 
% end
% updateGUIByGlobal('state.acq.outputRate');
% 
% %Actually handle update of channel AO rates in this callback
% %Do it here, rather than in general configuration handler, since in most cases, it isn't needed
% 
% %Update sample rate of Pockels channels
% if state.init.eom.pockelsOn %VI031009A
%     for i = 1:state.init.eom.numberOfBeams
%         setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'SampleRate', state.acq.outputRate);
%     end
% end
% 
% %Update sample rate of mirror channels
% warning('off','daq:set:propertyChangeFlushedData');
% set([state.init.ao2 state.init.ao2F],'SampleRate',state.acq.outputRate)
% warning('on','daq:set:propertyChangeFlushedData');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function pbSaveConfig_Callback(hObject, eventdata, handles)
pbApplyConfig_Callback(); %This will apply configuration settings, if they remain unapplied
saveCurrentConfig();

% --------------------------------------------------------------------
function pbSaveConfigAs_Callback(hObject, eventdata, handles)
pbApplyConfig_Callback(); %This will apply configuration settings, if they remain unapplied
saveCurrentConfigAs();

% --------------------------------------------------------------------
function pbLoadConfig_Callback(hObject, eventdata, handles)
openAndLoadConfiguration();

% --------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global state
state.internal.showCfgGUI = 0;
updateGUIByGlobal('state.internal.showCfgGUI','Callback',1);


%%%VI040509A%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function pmAIRate_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

% --------------------------------------------------------------------
function pmAORate_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI041009A%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function cbAutoAIRate_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

% --------------------------------------------------------------------
function cbAutoAORate_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%VI042709A%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function cbBidirectionalScan_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI102209A%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function cbFlybackFinalLine_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);

% --------------------------------------------------------------------
function cbDiscardFlybackLine_Callback(hObject, eventdata, handles)
flagConfigChange();
genericCallback(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% HELPERS
function incrementConfigZoomFactor(increment)

global state

newval = state.internal.configZoomFactor + increment;
if newval >= 1 && newval <= state.acq.baseZoomFactor
    state.internal.configZoomFactor = newval;
    updateGUIByGlobal('state.internal.configZoomFactor','Callback',1);
end


% --------------------------------------------------------------------
function stepAcqDelay(incOrDec)
global state

incVal = computeAcqDelayIncrement();

switch(lower(incOrDec))
    case 'inc'
        state.internal.acqDelayGUI = constrainAcqDelay(state.internal.acqDelayGUI + incVal,state.internal.fineAcqDelayAdjust,@floor);
    case 'dec'
        state.internal.acqDelayGUI = constrainAcqDelay(state.internal.acqDelayGUI - incVal,state.internal.fineAcqDelayAdjust,@ceil);
    otherwise
        error('Argument should be either ''inc'' or ''dec''');               
end      

%state.acq.servoDelay = state.internal.servoDelay * state.acq.msPerLine * 1e3; %Store/display value in microseconds %VI012109A
updateGUIByGlobal('state.internal.acqDelayGUI','Callback',1);


% --------------------------------------------------------------------
function stepScanDelay(incOrDec)
global state

incVal = state.internal.minAOPeriodIncrement * 1e6; %VI041209A: Allow scan delay increments in single AO sample increments

switch (lower(incOrDec))
    case 'inc'
        state.internal.scanDelayGUI = state.internal.scanDelayGUI + incVal;
    case 'dec'
        state.internal.scanDelayGUI = state.internal.scanDelayGUI - incVal;
end
updateGUIByGlobal('state.internal.scanDelayGUI','Callback',1);


% --------------------------------------------------------------------
function updateScanDelay()
global state

%Constrain scan delay value to proper increments/values, accounting for current Fill Fraction & Ms/Line
state.internal.scanDelayGUI = constrainScanDelay(state.internal.scanDelayGUI, state.acq.fillFraction, state.acq.msPerLine);

%Update GUI and non GUI scanDelay representations
updateGUIByGlobal('state.internal.scanDelayGUI');
state.acq.scanDelay = state.internal.scanDelayGUI * 1e-6;
state.internal.scanDelayArray(getConfigZoomFactor()) = state.internal.scanDelayGUI;

% --------------------------------------------------------------------
function scanDelayOut = constrainScanDelay(scanDelayIn, fillFraction, msPerLine)
global state 

%Constrain scan delay value to proper increments/values, accounting for current Fill Fraction & Ms/Line
maxScanDelay = (1 - fillFraction) * msPerLine * 1e3;
scanDelayIncrement = state.internal.minAOPeriodIncrement * 1e6; %VI032409B: Allow steps of one AO sampling period (using minimum supported AO rate)

discretizedScanDelayGUI = round(scanDelayIn  / scanDelayIncrement) * scanDelayIncrement;
maxScanDelay = floor(maxScanDelay  / scanDelayIncrement) * scanDelayIncrement;

scanDelayOut = min(discretizedScanDelayGUI, maxScanDelay);


return;

% --------------------------------------------------------------------
function configZoomFactor = getConfigZoomFactor()
global state
configZoomFactor = min(state.acq.zoomFactor,state.acq.baseZoomFactor); %VI021809A

% --------------------------------------------------------------------
function flagConfigChange(allowDuringFocus, recomputeDuringFocus)  
global state gh

if nargin < 1
    allowDuringFocus = false;
end
if nargin < 2
    recomputeDuringFocus = true;
end

setConfigurationNeedsSaving(); %VI020209A

focusingNow = strcmp(get(gh.mainControls.focusButton, 'String'), 'ABORT');
if focusingNow
    if allowDuringFocus 
        if recomputeDuringFocus
            setScanProps(); %VI013109A: this will stop and restart focus
            %stopAndRestartFocus(); %VI013109A
        end
        return;
    else
        abortFocus(); 
    end
end
%Set Configuration Changed flag
state.internal.configurationChanged=1;
set(gh.configurationGUI.pbApplyConfig,'Enable','on','ForegroundColor',[0 .5 0]);
turnOffExecuteButtons('state.internal.configurationChanged');







