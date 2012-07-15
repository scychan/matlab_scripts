function varargout = basicConfigurationGUI(varargin)
% BASICCONFIGURATIONGUI_OLD Application M-file for configurationGUI.fig
%    FIG = BASICCONFIGURATIONGUI_OLD launch configurationGUI GUI.
%    BASICCONFIGURATIONGUI_OLD('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 27-Jan-2009 11:46:57
% 
%% NOTES
%   DEPRECATED: these functionalities are now in the configurationGUI -- Vijay Iyer 1/27/09
%% *************************************

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

% --------------------------------------------------------------------
function flagConfigChange()  %VI092508A
global state
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
updateGUIByGlobal('state.internal.configurationChanged','Callback',1);

% --------------------------------------------------------------------
function scanAmplitude_Callback(h, eventdata, handles, varargin) %VI121608A
flagConfigChange; %VI092508A
genericCallback(h);
state.internal.aspectRatioChanged=1;

% --------------------------------------------------------------------
function cbBlankFlyback_Callback(hObject, eventdata, handles)
pockelsParam_Callback(hObject);


%%%%VI121408A: Newly created generic Pockels Cell control callback
% --------------------------------------------------------------------
function varargout = pockelsParam_Callback(hObject, eventdata, handles, varargin)
global state 
flagConfigChange;
genericCallback(hObject);
setPockelsAcqParameters(); %VI121208A -- only needed if pockelsClosedOnFlyback changes, but can be done always harmlessly
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A

% --------------------------------------------------------------------
function varargout = pixelsPerLine_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
flagConfigChange; %VI092508A
state.acq.pixelsPerLineGUI = get(h,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(h, state.acq.pixelsPerLineGUI));
genericCallback(h);

% --------------------------------------------------------------------
function varargout = fastScanRadioX_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.fastScanRadioX.
global gh state
%state.internal.configurationChanged=1;
flagConfigChange; %VI092508A
genericCallback(h);
state.acq.fastScanningY = 0;
updateGUIByGlobal('state.acq.fastScanningY');

% --------------------------------------------------------------------
function varargout = fastScanRadioY_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.fastScanRadioY.
global gh state
%state.internal.configurationChanged=1;
flagConfigChange; %VI092508A
genericCallback(h);
state.acq.fastScanningX = 0;
updateGUIByGlobal('state.acq.fastScanningX');

% --------------------------------------------------------------------
function varargout = linesPerFrame_Callback(h, eventdata, handles, varargin)
global state

flagConfigChange; %VI092508A
genericCallback(h);


% --------------------------------------------------------------------
function pbOK_Callback(hObject, eventdata, handles)

closeConfigurationGUI;

% --------------------------------------------------------------------
function pbApply_Callback(hObject, eventdata, handles)
global state

%Do the following to ensure that any queued callbacks are executed (MW Service Request  1-6D7KR)
hideGUI('gh.basicConfigurationGUI.figure1');
drawnow; %VI052308A
seeGUI('gh.basicConfigurationGUI.figure1'); %VI052308A

if state.internal.configurationChanged==1
    applyConfigurationSettings;
end

% --------------------------------------------------------------------
function tbShowAdvanced_Callback(hObject, eventdata, handles)
global gh

extraChars = 12.6; %how many extra characters to extend height of Fig
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
function varargout = pmFillFracConfig_Callback(hObject, eventdata, handles) %VI092408A: Renamed to pmFillFractOpts
flagConfigChange; %VI092508A
genericCallback(hObject);

global state gh
state.internal.fillFractionGUIArray(state.internal.configZoomFactor) = state.internal.fillFractionGUI;
updateConfigZoomFactor();
updateZoom();

% --------------------------------------------------------------------
function etScanDelayConfig_Callback(hObject, eventdata, handles)
flagConfigChange; 
genericCallback(hObject);

global state
state.internal.acqDelayConfig = constrainServoDelay(state.acq.servoDelayConfig);
updateGUIByGlobal('state.internal.acqDelayConfig');

state.internal.servoDelayArray(state.internal.configZoomFactor) = state.internal.acqDelayConfig;
updateConfigZoomFactor(); 
updateZoom();

%setAcquisitionParameters; %VI092408: Avoid the duplication previously seen.
%state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.etMsPerLine2; %VI031708A
%TPMODPockels
%basicConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.basicConfigurationGUI.pockelsClosedOnFlyback); %VI092408A

% --------------------------------------------------------------------
function etAcqAdjustConfig_Callback(hObject, eventdata, handles)
flagConfigChange; 
genericCallback(hObject);

global state

[fillFraction, msPerLine] = decodeFillFractionGUI(state.internal.fillFractionGUI);
state.internal.scanDelayConfig = constrainAccelerationTime(state.internal.scanDelayConfig, fillFraction, msPerLine);
updateGUIByGlobal('state.internal.scanDelayConfig');

state.internal.accelerationTimeArray(state.internal.configZoomFactor) = state.internal.scanDelayConfig;
updateConfigZoomFactor(); 
updateZoom();

% --------------------------------------------------------------------
function varargout = pmMsPerLine_Callback(h, eventdata, handles, varargin) %VI092408A: formerly etMsPerLine2_Callback in advancedConfigurationGUI
% Stub for Callback of the uicontrol handles.popupmenu1.
global state
flagConfigChange; %VI092508A
genericCallback(h);


%%%%VI122908A: Newly created dummy msPerLine callback
% --------------------------------------------------------------------
function varargout = msPerLine_Callback(h, eventdata, handles, varargin) 
genericCallback(h);

% %%%%VI092408A: No longer needed
% % --------------------------------------------------------------------
% function varargout = lineDelay_Callback(h, eventdata, handles, varargin)
% global state gh
% state.internal.configurationChanged=1;
% state.internal.configurationNeedsSaving=1;
% genericCallback(h);
% %state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.etMsPerLine2; %VI031708A
% setAcquisitionParameters; %VI031708B
% %TPMODPockels
% advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.cbBlankFlyback);

%%%VI121408A: Handle Pockels Cell controls with one callback%%%%%%
% TPMODPockels Changed again to be more efficient.....
% --------------------------------------------------------------------
% function varargout = pockelsCellLineDelay_Callback(h, eventdata, handles, varargin)
% global state;
% genericCallback(h);
% flagConfigChange; %VI092508A
% state.init.eom.changed(state.init.eom.scanLaserBeam) = 1;
% state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A
% 
% if state.acq.pockelsCellLineDelay < 0
%     state.acq.pockelsCellLineDelay=0;
% elseif state.acq.pockelsCellLineDelay > 1000*state.acq.etMsPerLine2 %Changed, so it never goes over state.acq.etMsPerLine2 - Tim O'Connor 7/28/03
%     state.acq.pockelsCellLineDelay=1000*state.acq.etMsPerLine2;
% elseif state.acq.pockelsCellLineDelay > 1  %VI092108A
%     state.acq.pockelsCellLineDelay = 1;
% end
% 
% updateGUIByGlobal('state.acq.pockelsCellLineDelay');
% 
% --------------------------------------------------------------------
% function varargout = pockelsCellFillFraction_Callback(h, eventdata, handles, varargin)
% global state;
% genericCallback(h);
% flagConfigChange; %VI092508A;
% state.init.eom.changed(state.init.eom.scanLaserBeam) = 1;
% state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A
% 
% --------------------------------------------------------------------
% function varargout = pockelsClosedOnFlyback_Callback(h, eventdata, handles, varargin)
% global state gh
% flagConfigChange; %VI092508A
% state.init.eom.changed(state.init.eom.scanLaserBeam) = 1;
% state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A
% 
% setPockelsAcqParameters; %VI121208A
% 
% %%VI121208A: Factored out %%%%%%%%%%%
% %%VI092408A: change all from advancedConfigurationGUI to basicConfigurationGUI
% if get(h, 'Value') == get(h, 'Max')
%     %state.acq.pockelsCellLineDelay = state.acq.lineDelay;
%     state.acq.pockelsCellLineDelay = state.internal.lineDelay; %VI092108A
%     %state.acq.pockelsCellFillFraction = state.acq.fillFraction+state.acq.etServoDelay;
%     state.acq.pockelsCellFillFraction = state.acq.fillFraction+ 2*(1/state.acq.outputRate)/state.acq.etMsPerLine2; %VI092108B
%     
%     set(gh.basicConfigurationGUI.pockelsCellFillFraction, 'Enable', 'Off');
%     set(gh.basicConfigurationGUI.pockelsCellLineDelay, 'Enable', 'Off');
%     set(gh.basicConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'Off');
% else
%     set(gh.basicConfigurationGUI.pockelsCellFillFraction, 'Enable', 'On');
%     if get(gh.basicConfigurationGUI.cbBidirectionalScan,'Value') == 0 %VI030508A
%         set(gh.basicConfigurationGUI.pockelsCellLineDelay, 'Enable', 'On');
%     end
%     set(gh.basicConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'On');
% end
% %%%%%%%%
% 
% updateGUIByGlobal('state.acq.pockelsCellFillFraction')
% updateGUIByGlobal('state.acq.pockelsCellLineDelay')
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% --------------------------------------------------------------------
% function varargout = pockelsCellFillFractionSlider_Callback(h, eventdata, handles, varargin)
% global state 
% 
% genericCallback(h);
% flagConfigChange; %VI092508A
% state.init.eom.changed(state.init.eom.scanLaserBeam) = 1;
% state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI010208A: Callback logic moved to updateBidirectionalScanning%%%%
% function cbBidirectionalScan_Callback(h, eventdata, handles)
% global state gh
% 
% flagConfigChange; %VI092508A
% genericCallback(h);
% 
% %VI030508A
% if get(h,'Value')
%     set(gh.basicConfigurationGUI.pockelsCellLineDelay,'Enable','Off');
% else
%     if get(gh.basicConfigurationGUI.cbBlankFlyback,'Value') == 0
%         set(gh.basicConfigurationGUI.pockelsCellLineDelay,'Enable','On');
%     else
%         set(gh.basicConfigurationGUI.pockelsCellLineDelay,'Enable','Off');
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function tbConfigChanged_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    set(hObject,'BackgroundColor',[1 0 0]);
else
    set(hObject,'BackgroundColor',[0 1 0]);
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
function etConfigZoomFactor_Callback(hObject, eventdata, handles)
genericCallback(hObject);


% --------------------------------------------------------------------
function pbIncZoom_Callback(hObject, eventdata, handles)
incrementConfigZoomFactor(1);

% --------------------------------------------------------------------
function pbDecZoom_Callback(hObject, eventdata, handles)
incrementConfigZoomFactor(-1);

function incrementConfigZoomFactor(increment)

global state

newval = state.internal.configZoomFactor + increment;
if newval >= 1 && newval <= state.acq.baseZoomFactor
    state.internal.configZoomFactor = newval;
    updateGUIByGlobal('state.internal.configZoomFactor','Callback',1);
end


% --------------------------------------------------------------------
function etFillFracAdjust_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function pbAutoOptimize_Callback(hObject, eventdata, handles)





% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etScanDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanDelay as text
%        str2double(get(hObject,'String')) returns contents of etScanDelay as a double


% --- Executes during object creation, after setting all properties.
function etScanDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbFineAcqAdj.
function cbFineAcqAdj_Callback(hObject, eventdata, handles)
% hObject    handle to cbFineAcqAdj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFineAcqAdj


% --- Executes on button press in pbDecScanAdjust.
function pbDecScanAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecScanAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncScanAdjust.
function pbIncScanAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncScanAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etAcqDelay as text
%        str2double(get(hObject,'String')) returns contents of etAcqDelay as a double


% --- Executes during object creation, after setting all properties.
function etAcqDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbDecAcqDelay.
function pbDecAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncAcqDelay.
function pbIncAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pmFillFrac.
function pmFillFrac_Callback(hObject, eventdata, handles)
% hObject    handle to pmFillFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pmFillFrac contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFillFrac


% --- Executes during object creation, after setting all properties.
function pmFillFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFillFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etMsPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to etMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etMsPerLine as text
%        str2double(get(hObject,'String')) returns contents of etMsPerLine as a double


% --- Executes during object creation, after setting all properties.
function etMsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit66_Callback(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


