function varargout = channelGUI(varargin)
global state
% CHANNELGUI Application M-file for channelGUI.fig
%    FIG = CHANNELGUI launch channelGUI GUI.
%    CHANNELGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 06-Feb-2009 14:34:42

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
%%
	end

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
function varargout = cbAcquire1_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cbSave2.
% updates all the checkboxes accross a row when you acquire one channel.
global gh state
state.internal.channelChanged=1;
genericCallback(h);
val = get(h, 'Value');
	if val == 1
		state.acq.savingChannel1 = 1;
		updateGUIByGlobal('state.acq.savingChannel1');
		state.acq.imagingChannel1 = 1;
		updateGUIByGlobal('state.acq.imagingChannel1');
		state.acq.maxImage1 = 0;
		updateGUIByGlobal('state.acq.maxImage1');
		updateNumberOfChannels;
		
	elseif val == 0 
		state.acq.savingChannel1 = 0;
		updateGUIByGlobal('state.acq.savingChannel1');
		state.acq.imagingChannel1 = 0;
		updateGUIByGlobal('state.acq.imagingChannel1');
		state.acq.maxImage1 = 0;
		updateGUIByGlobal('state.acq.maxImage1');
		updateNumberOfChannels;
	else
	end

% --------------------------------------------------------------------
function varargout = cbAcquire2_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cbImage1.
% updates all the checkboxes accross a row when you acquire one channel.
global gh state
state.internal.channelChanged=1;
genericCallback(h)
val = get(h, 'Value');
if val == 1
    state.acq.savingChannel2 = 1;
    updateGUIByGlobal('state.acq.savingChannel2');
    state.acq.imagingChannel2 = 1;
    updateGUIByGlobal('state.acq.imagingChannel2');
    state.acq.focusingChannel2 = 1;
    updateGUIByGlobal('state.acq.maxImage2');
    updateNumberOfChannels;
elseif val == 0
    state.acq.savingChannel2 = 0;
    updateGUIByGlobal('state.acq.savingChannel2');
    state.acq.imagingChannel2 = 0;
    updateGUIByGlobal('state.acq.imagingChannel2');
    state.acq.maxImage2 = 0;
    updateGUIByGlobal('state.acq.maxImage2');
    updateNumberOfChannels;
else
end



% --------------------------------------------------------------------
function varargout = cbAcquire3_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cbImage2.
% updates all the checkboxes accross a row when you acquire one channel.
global gh state
state.internal.channelChanged=1;
genericCallback(h)
val = get(h, 'Value');
if val == 1
    state.acq.savingChannel3 = 1;
    updateGUIByGlobal('state.acq.savingChannel3');
    state.acq.imagingChannel3 = 1;
    updateGUIByGlobal('state.acq.imagingChannel3');
    state.acq.maxImage3 = 0;
    updateGUIByGlobal('state.acq.maxImage3');
    updateNumberOfChannels;
elseif val == 0
    state.acq.savingChannel3 = 0;
    updateGUIByGlobal('state.acq.savingChannel3');
    state.acq.imagingChannel3 = 0;
    updateGUIByGlobal('state.acq.imagingChannel3');
    state.acq.maxImage3 = 0;
    updateGUIByGlobal('state.acq.maxImage3');
    updateNumberOfChannels;
else
end

%--------------------------------------------------------------------
function cbAcquire4_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cbAcquire4.
% updates all the checkboxes accross a row when you acquire one channel.
global gh state
state.internal.channelChanged=1;
genericCallback(h)
val = get(h, 'Value');
if val == 1
    state.acq.savingChannel4 = 1;
    updateGUIByGlobal('state.acq.savingChannel4');
    state.acq.imagingChannel4 = 1;
    updateGUIByGlobal('state.acq.imagingChannel4');
    state.acq.maxImage4 = 0;
    updateGUIByGlobal('state.acq.maxImage4');
    updateNumberOfChannels;
elseif val == 0
    state.acq.savingChannel4 = 0;
    updateGUIByGlobal('state.acq.savingChannel4');
    state.acq.imagingChannel4 = 0;
    updateGUIByGlobal('state.acq.imagingChannel4');
    state.acq.maxImage4 = 0;
    updateGUIByGlobal('state.acq.maxImage4');
    updateNumberOfChannels;
else
end

% --------------------------------------------------------------------
function pmVoltageRange1_Callback(h, eventdata, handles)
generic_Callback(h);

% --------------------------------------------------------------------
function pmVoltageRange2_Callback(h, eventdata, handles)
generic_Callback(h);

% --------------------------------------------------------------------
function pmVoltageRange3_Callback(h, eventdata, handles)
generic_Callback(h);

% --------------------------------------------------------------------
function pmVoltageRange4_Callback(h, eventdata, handles)
generic_Callback(h);   

% --------------------------------------------------------------------
function varargout = generic_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.checkbox14.
global gh state
state.internal.channelChanged=1;
genericCallback(h)

% --------------------------------------------------------------------
function cbMergeChannel_Callback(h, eventdata, handles)
genericCallback(h);

%%%VI011109A: Removed %%%%%%%%%%%%%%
% if get(h,'Value') %turn on color merge    
%     set(state.internal.MergeFigure,'Visible','on');
%     set(gh.channelGUI.cbMergeFocusOnly,'Enable','on');     
%     set(gh.channelGUI.cbMergeBlueAsGray,'Enable','on'); %VI111708A
% else %turn off color merge
%     set(state.internal.MergeFigure,'Visible','off');
%     set(gh.channelGUI.cbMergeFocusOnly,'Enable','off');
%     set(gh.channelGUI.cbMergeBlueAsGray,'Enable','off'); %VI111708A
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


% --------------------------------------------------------------------
function cbMergeFocusOnly_Callback(h, eventdata, handles)
genericCallback(h);


% --------------------------------------------------------------------
function pmMergeColor1_Callback(h, eventdata, handles)
genericCallback(h);

% --------------------------------------------------------------------
function pmMergeColor2_Callback(h, eventdata, handles)
genericCallback(h);

% --------------------------------------------------------------------
function pmMergeColor3_Callback(h, eventdata, handles)
genericCallback(h);

% --------------------------------------------------------------------
function pmMergeColor4_Callback(h, eventdata, handles)
genericCallback(h);


% --------------------------------------------------------------------
function pbSaveCFG_Callback(hObject, eventdata, handles)
saveCurrentConfig();

% --------------------------------------------------------------------
function pbSaveUSR_Callback(hObject, eventdata, handles)
saveCurrentUserSettings();
