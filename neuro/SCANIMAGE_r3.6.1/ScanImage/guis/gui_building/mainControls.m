function varargout = mainControls(varargin)
% Author: Bernardo Sabatini with modifications by Tom Pologruto
%
% MAINCONTROLS Application M-file for mainControls.fig
%    FIG = MAINCONTROLS launch mainControls GUI.
%    MAINCONTROLS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 13-Feb-2009 13:33:49
%% CHANGES
% VI041308A: Disallow external triggering for multi-slice acquisitions -- Vijay Iyer 4/13/2008
% VI043008A: Specify key /release/ callback as a function handle in order to take advantage of eventdata feature-- Vijay Iyer 4/30/2008
% VI091508A: Employ absoute value with scanAmplitudeX/Y to handle case where scan direction is reversed by using negative value -- Vijay Iyer 9/15/2008
% VI091508B: Restored etServoDelay and phaseSlider controls (tied to cusp delay) and added FinePhaseControl checkbox -- Vijay Iyer 9/15/08
% VI091608A: Handle newly added autoSave checkbox -- Vijay Iyer 9/16/2008
% VI091808A: Handle newly added minimum-zoom property -- Vijay Iyer 9/18/2008
% VI092808A: All zoom processing now runs through setZoom, which now calls updateZoom() -- Vijay Iyer 9/24/2008
% VI110608A: New implementation allowing scanOffset update to be optionally written to current INI file
% VI120108A: Abort current scan (if any) quietly when toggling line scan -- Vijay Iyer 12/01/08
% VI121908A: Handle removal of maxOffsetX/Y and maxAmplitudeX/Y parameters (and updateScanFOV function) -- Vijay Iyer 12/19/08
% VI121908B: Warn user before parking at scan center -- Vijay Iyer 12/19/08
% VI010609A: Eliminate updateZoomStrings(); this is now in updateZoom() -- Vijay Iyer 1/06/09
% VI010809A: Cache old zoom value and flag changes that may cause fill fraction (line period) to change -- Vijay Iyer 1/08/09
% VI010909A: Route all zoom factor changes through setZoom, which can handle either the zoom 'dial' controls or other zoom changes (FULL/ROI/etc) -- Vijay Iyer 1/09/09
% VI011509A: (Refactoring) Remove explicit calls to setupAOData()/flushAOData(), as these are now called as part of setupDAQDevices_ConfigSpecific() -- Vijay Iyer 1/15/09
% VI011509B: Add increment/decrement buttons for servo delay, replacing slider. Allows update of servo delay in units of AI samples -- Vijay Iyer 1/15/09
% VI011609B: Handle conversion of state.acq.cuspDelay to state.internal/acq.servoDelay; servo delay now displayed/stored in time units -- Vijay Iyer 1/16/09
% VI012109A: msPerLine is now actually in milliseconds -- Vijay Iyer 1/21/09
% VI012809A: Don't change configurationChanged flag for change to line-scan checkbox
% VI021309A: Moved Set/Park Offset logic to alignGUI -- Vijay Iyer 2/13/09
% VI021809A: Use si_getrect() instead of getrect() -- Vijay Iyer 2/18/09
% VI021909B: User si_selectImageFigure() to select the image figure before user-interactive work -- Vijay Iyer 2/19/09
% VI030309A: Bypass si_selectImageFigure() if the callback is invoked from the dropdown menu of one of the figures -- Vijay Iyer 3/3/09
% VI030409A: Update current ROI in popup menu following the addition of an ROI -- Vijay Iyer 3/4/09
% VI030409B: Correctly reset the zoom value when the reset button is pressed -- Vijay Iyer 3/4/09
% VI042709A: Ignore rotation when selecting line scan with bidi scanning enabled -- Vijay Iyer 4/27/09
% VI043009A: For now, tether GUIs in all cases...don't allow (saved) repositinioning of tethered GUIs -- Vijay Iyer 4/30/09
% VI050509A: Correct ROI zoom factor determination for case of non-square aspect ratios -- Vijay iyer 5/21/09
% VI052009A: (REFACTOR) All calls to setupDaqDevices_ConfigSpecifig() also call preallocateMemory() -- Vijay Iyer 5/21/09
% VI102609A: Use state.internal.scanAmplitudeX/Y in lieu of state.acq.scanAmplitudeX/Y, as the internal value is now used to represent the actual command voltage -- Vijay Iyer 10/26/09
% VI111609A: BUGFIX - genericCallback() call was missing from zoomhundreds slider -- Vijay Iyer 11/16/09
% VI111609B: BUGFIX - CenterOnSelection was not working without Image Processing toolbox. It now uses newly created si_getpt(), instead of getpts(). Also it uses si_selectImageFigure() now first to identify target figure, as with other graphical interaction tools. -- Vijay Iyer 11/16/09
% VI071310A: Use getPointsFromAxes()/getRectFromAxes() in lieu of getpts/getline/getrect -- Vijay Iyer 7/13/10
%
%% ***************************************************

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
	% Stub for Callback of the uicontrol handles
	genericCallback(h);

% --------------------------------------------------------------------
function varargout = focusButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.focusButton.
 	global state gh
	figure(gh.mainControls.figure1);
	state.internal.whatToDo=1;
	executeFocusCallback(h);	
		
% --------------------------------------------------------------------
function varargout = grabOneButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.grabOneButton.
 	global state gh
	figure(gh.mainControls.figure1);
	state.internal.whatToDo=2;
	executeGrabOneCallback(h);

% --------------------------------------------------------------------
function varargout = startLoopButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.startLoopButton.
 	global gh
	figure(gh.mainControls.figure1);
	executeStartLoopCallback(h);
	
% --------------------------------------------------------------------
function varargout =  genericZoomRot_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = mainZoom_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = fullfield_Callback(h, eventdata, handles, varargin)
global gh state
setZoomValue(1); %VI010909A
%updateZoomStrings; %VI010609A
setScanProps(h);

%%%%%From 3.0%%%%
% updateGUIByGlobal('state.acq.zoomFactor');
% state.acq.zoomhundreds=0;
% state.acq.zoomtens=0;
% state.acq.zoomones=1;
% updateGUIByGlobal('state.acq.zoomhundreds');
% updateGUIByGlobal('state.acq.zoomtens');
% updateGUIByGlobal('state.acq.zoomones');
%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function varargout = scaleYShift_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = scaleXShift_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = right_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleXShift=state.acq.scaleXShift+1/state.acq.zoomFactor*state.acq.xstep;
if abs(state.acq.scaleXShift) < .0001
    state.acq.scaleXShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = left_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleXShift=state.acq.scaleXShift-1/state.acq.zoomFactor*state.acq.xstep;
if abs(state.acq.scaleXShift) < .0001
    state.acq.scaleXShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = down_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=state.acq.scaleYShift+1/state.acq.zoomFactor*state.acq.ystep;
if abs(state.acq.scaleYShift) < .0001
    state.acq.scaleYShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleYShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = up_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=state.acq.scaleYShift-1/state.acq.zoomFactor*state.acq.ystep;
if abs(state.acq.scaleYShift) < .0001
    state.acq.scaleYShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleYShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = zero_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=0;
updateGUIByGlobal('state.acq.scaleYShift');
state.acq.scaleXShift=0;
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = ROI_Callback(h, eventdata, handles, varargin)
global state gh
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    setUndo;
    done=drawROISI(h);
    if done
        setScanProps(gh.mainControls.ROI);
        snapShot(1);
    end
else
    beep;
    disp('Cant select ROI when acquiring or focusing.');
end

% --------------------------------------------------------------------
function done=drawROISI(handle)
global state
done=0;

%%%VI021909A%%%%
if ismember(handle,state.internal.GraphFigure) %VI030309A
    hax = get(handle,'CurrentAxes'); %VI030309A
else
    hax = si_selectImageFigure();
    if isempty(hax)
        return;
    end
end
%%%%%%%%%%%%%%%

[hax,volts_per_pixelX,volts_per_pixelY,sizeImage]=genericFigSelectionFcn(hax); %VI021909A
pos=getRectFromAxes(hax,'Cursor','crosshair','nomovegui',1); %VI071310A %VI021809B
if pos(3)==0 || pos(4)==0
    return
end

%%%VI050509A%%%%%%%%%%%%%
roiZoomFactor = min(sizeImage(1:2)./fliplr(pos(3:4)));
setZoomValue(ceil(state.acq.zoomFactor * roiZoomFactor));
%setZoomValue(ceil(state.acq.zoomFactor*round(sizeImage(1)./pos(3)))); %VI010909A %VI050509A: Removed
%%%%%%%%%%%%%%%%%%%%%%%%%e

%%%VI010909A: Removed %%%%%%%%%%%%
%state.acq.zoomFactor=ceil(state.acq.zoomFactor*round(sizeImage(1)./pos(3))); 
%updateGUIByGlobal('state.acq.zoomFactor');
%updateZoomStrings; %VI010609A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

centerX=(pos(1)+.5*pos(3));
centerY=(pos(2)+.5*pos(4));
state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-sizeImage(2)/2);
state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');
done=1;

% --------------------------------------------------------------------
function varargout = reset_Callback(h, eventdata, handles, varargin)
global state gh
state.acq.scaleXShift=state.acq.scaleXShiftReset;
state.acq.scaleYShift=state.acq.scaleYShiftReset;
state.acq.scanRotation=state.acq.scanRotationReset;
updateGUIByGlobal('state.acq.scaleYShift');
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scanRotation');
%%%VI010909A: Removed%%%%%%%%%%%%%%%%
% state.acq.zoomFactor=state.acq.zoomFactorReset;
% state.acq.zoomones=state.acq.zoomonesReset;
% state.acq.zoomtens=state.acq.zoomtensReset;
% state.acq.zoomhundreds=state.acq.zoomhundredsReset;
% updateGUIByGlobal('state.acq.zoomFactor');
% updateGUIByGlobal('state.acq.zoomhundreds');
% updateGUIByGlobal('state.acq.zoomtens');
% updateGUIByGlobal('state.acq.zoomones');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setZoomValue(state.acq.zoomFactorReset); %VI010909A, VI030409B
setScanProps(h); 
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    snapShot(1);
end
setUndo;
% -------------------------------------------------------------------
function varargout = ystep_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = xstep_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = showrotbox_Callback(h, eventdata, handles, varargin)
global state gh
currentString=get(h,'String');
pos=get(ancestor(h,'figure'),'position'); %VI070308A -- replace get(h,'Parent') with ancestor(h,'figure')
if strcmp(currentString,'>>')
    set(h,'String','<<');
    pos(3)=92.6;
    set(ancestor(h,'figure'),'position',pos); %VI070308A -- replace get(h,'Parent') with gcbf
else
    set(h,'String','>>');
    pos(3)=48;
    set(ancestor(h,'figure'),'position',pos); %VI070308A -- replace get(h,'Parent') with gcbf
end
state.internal.showRotBox=get(h,'String');

% --------------------------------------------------------------------
function varargout = linescan_Callback(h, eventdata, handles, varargin)
global state gh
genericCallback(h);
if strcmp(get(gh.mainControls.focusButton,'Visible'),'off')
    beep;
    disp('Cant switch to linescan during acquisition.  Must be Focusing');
    return
end
set(h,'Enable','off');
try
    focus=0;
    if ~strcmpi(get(gh.mainControls.focusButton,'String'),'FOCUS')
        focus=1;
    end    
    abortCurrent(0); %VI120108A
    if state.acq.linescan==1
        %state.internal.oldAmplitude=state.acq.scanAmplitudeY; %VI050509A: Removed
        %state.acq.scanAmplitudeY=0; %VI050509A: Removed
        
        %12/16/03 Tim O'Connor - Make things a little more obvious, when using a powerbox.
%         set(gh.powerControl.startFrametext, 'String', 'Start Line');
%         set(gh.powerControl.endFrametext, 'String', 'End Line');
        set(gh.powerBox.stFramesOrLines, 'String', 'Lines:'); %VI020609A
    else
        %state.acq.scanAmplitudeY=state.internal.oldAmplitude; %VI050509A: Removed
        
        %12/16/03 Tim O'Connor - Make things a little more obvious, when using a powerbox.
%         set(gh.powerControl.startFrametext, 'String', 'Start Frame');
%         set(gh.powerControl.endFrametext, 'String', 'End Frame');
        set(gh.powerBox.stFramesOrLines, 'String', 'Frames:'); %VI020609A
    end
    updateGUIByGlobal('state.acq.scanAmplitudeY');
    setImagesToWhole;
    checkConfigSettings;
	stopGrab;
	stopFocus;
	
	setupDAQDevices_ConfigSpecific;
	%preallocateMemory; %VI052109A
	%setupAOData; %VI011509A
    %flushAOData; %VI011509A
	resetCounters;
	updateHeaderString('state.acq.pixelsPerLine');
	updateHeaderString('state.acq.fillFraction');
	%state.internal.configurationChanged=0; %VI012809A
    %updateGUIByGlobal('state.internal.configurationChanged','Callback',1); %VI012809A %VI092508A (though need to investigate this entire callback further)
	startPMTOffsets;
    if focus
        executeFocusCallback(gh.mainControls.focusButton);
    end
    set(h,'Enable','on');
catch
    set(h,'Enable','on');
    rethrow(lasterror);
end

% --------------------------------------------------------------------
function varargout = phaseSlider_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% %%%VI020709A: Removed %%%%%%%%%%%%%%%%%%%%%
% % --------------------------------------------------------------------
% function done=setLS(handle)
% global state gh
% % done=0;
% % setImagesToWhole;
% % if nargin<1
% %     axis=state.internal.axis(logical(state.acq.imagingChannel));
% %     image=state.internal.imagehandle(logical(state.acq.imagingChannel));
% %     axis=axis(1);
% %     image=image(1);
% % elseif ishandle(handle)
% %     ind=find(handle==state.internal.axis);
% %     if isempty(ind)
% %         return
% %     end
% %     axis=handle;
% %     image=state.internal.imagehandle(ind);
% % else
% %     ~ishandle(handle)
% %     return
% % end
% % fractionUsedXDirection=state.acq.fillFraction;
% % x=get(axis,'XLim');
% % y=get(axis,'YLim');
% % sizeImage=[y(2) round(state.acq.roiCalibrationFactor*x(2))];
% % volts_per_pixelX=((1/state.acq.zoomFactor)*2*fractionUsedXDirection*abs(state.acq.scanAmplitudeX))/sizeImage(2); %VI091508A
% % volts_per_pixelY=((1/state.acq.zoomFactor)*2*abs(state.acq.scanAmplitudeY))/sizeImage(1); %VI091508A
% % [xpt,ypt]=getline(axis);
% % slope=(ypt(2)-ypt(1))/(xpt(2)-xpt(1));
% % state.acq.scanRotation=state.acq.scanRotation-(180/pi*atan(slope));
% % updateGUIByGlobal('state.acq.scanRotation');
% % 
% % centerX=.5*(xpt(1)+xpt(2));
% % centerY=.5*(ypt(1)+ypt(2));
% %  
% % state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-x(2)/2);
% % state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
% % updateGUIByGlobal('state.acq.scaleXShift');
% % updateGUIByGlobal('state.acq.scaleYShift');
% % 
% % done=1;


% --------------------------------------------------------------------
function varargout = abortCurrentAcq_Callback(h, eventdata, handles, varargin)
abortCurrent;

% --------------------------------------------------------------------
function varargout = zoomhundredsslider_Callback(h, eventdata, handles, varargin)
genericCallback(h); %VI111609A
setZoom(h);

% --------------------------------------------------------------------
function varargout = zoomtensslider_Callback(h, eventdata, handles, varargin)

global state
genericCallback(h);
if state.acq.zoomtens == 10 & state.acq.zoomhundreds<9
    state.acq.zoomtens=0;
    state.acq.zoomhundreds=state.acq.zoomhundreds+1;
elseif state.acq.zoomtens == 10 & state.acq.zoomhundreds>=9
    state.acq.zoomtens=9;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds>1
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=state.acq.zoomhundreds-1;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds==1
    state.acq.zoomones=9;
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=0;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds < 1
    state.acq.zoomtens=0;
end
%%%VI010909A%%%%%%%%%%%%%%%%%%%
% updateGUIByGlobal('state.acq.zoomones');
% updateGUIByGlobal('state.acq.zoomtens');
% updateGUIByGlobal('state.acq.zoomhundreds');
setZoom(h);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function varargout = zoomonesslider_Callback(h, eventdata, handles, varargin)
genericCallback(h);

global state
if state.acq.zoomones == 10 & state.acq.zoomtens<9
    state.acq.zoomones=0;
    state.acq.zoomtens=state.acq.zoomtens+1;
elseif state.acq.zoomones == 10 & state.acq.zoomtens>=9
    state.acq.zoomones=0;
    state.acq.zoomtens=0;
    state.acq.zoomhundreds=1;
elseif state.acq.zoomones < 0 & state.acq.zoomtens>=1
    state.acq.zoomones=9;
    state.acq.zoomtens=state.acq.zoomtens-1;
elseif state.acq.zoomones < 0 & state.acq.zoomtens<1 & state.acq.zoomhundreds>=1
    state.acq.zoomones=9;
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=state.acq.zoomhundreds-1;
end
%%%VI010909A%%%%%%%%%%%
% updateGUIByGlobal('state.acq.zoomones');
% updateGUIByGlobal('state.acq.zoomtens');
% updateGUIByGlobal('state.acq.zoomhundreds');
setZoom(h);
%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
%Generic handler for zoom 'dial' controls
function setZoom(h)
global state gh

%VI010909A: Defer processing to setZoomValue()
setZoomValue(str2num([num2str(round(state.acq.zoomhundreds))...
    num2str(round(state.acq.zoomtens)) num2str(round(state.acq.zoomones))]));

%Effect the change on the scan parameters
setScanProps(h);

% --------------------------------------------------------------------
function varargout = shutterDelay_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateShutterDelay;

% --------------------------------------------------------------------
function varargout = syncToPhysiology_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
%Primarily associated with line scan operation, this function actually generally allows rotation value to be graphically specified
function varargout = selectLineScanAngle_Callback(h, eventdata, handles, varargin)
global state gh

buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if si_isAcquiring()
    beep;
    disp('Cant select LS angle when acquiring or focusing.');
end

setUndo();%Cache values before adjusting rotation
setImagesToWhole(); %Ensure images are displayed correctly

try
    %%%VI0210909A%%%%%%%%%%
    axis = si_selectImageFigure();
    if isempty(axis)
        return;
    end    
    %axis = gca; %Removed
    %%%%%%%%%%%%%%%%%%%%%%%%%
    x=get(axis,'XLim');
    y=get(axis,'YLim');
    sizeImage=[y(2) x(2)];
    volts_per_pixelX = 2 * abs(state.internal.scanAmplitudeX) / (state.acq.zoomFactor * sizeImage(2)); %VI102609A
    volts_per_pixelY = 2 * abs(state.internal.scanAmplitudeY) / (state.acq.zoomFactor * sizeImage(1)); %VI102609A
    
    [xpt, ypt] = getPointsFromAxes(axis,'numberOfPoints',2,'Cursor','crosshair','nomovegui',1); %VI071310A
    if length(xpt) < 2 %VI071310A: Handle case where selection was cancelled
        return;
    end
    slope=(ypt(2)-ypt(1))/(xpt(2)-xpt(1));
    if ~state.acq.bidirectionalScan %VI042709A        
        state.acq.scanRotation=state.acq.scanRotation-(180/pi*atan(slope));
        updateGUIByGlobal('state.acq.scanRotation');
    end

    centerX=.5*(xpt(1)+xpt(2));
    centerY=.5*(ypt(1)+ypt(2));

    state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-x(2)/2);
    state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
    updateGUIByGlobal('state.acq.scaleXShift');
    updateGUIByGlobal('state.acq.scaleYShift');
catch
    rethrow(lasterror);
    return;
end

%Update scan properties and show to user
setScanProps(h);
snapShot(1);

% --------------------------------------------------------------------
function varargout = setReset_Callback(h, eventdata, handles, varargin)
defineReset;
global gh state
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
while ~all(strcmpi(get(buttonHandles,'Visible'),'on'))
    pause(.001);
end
index=~cellfun('isempty',state.acq.acquiredData);
channels=find(index==1);
data=state.acq.acquiredData(index);
new=[];
hi=[];
low=[];
if ~isempty(data)
    for j=1:length(data)
        low=min([low state.internal.lowPixelValue(channels(j))]);
        hi=max([hi state.internal.highPixelValue(channels(j))]);
        new=max(cat(3,new,data{j}(:,:,1)),[],3);
    end
    set(state.internal.roiimage,'CData',new)
    set(state.internal.roiaxis,'CLim',[low hi]);
end
state.acq.roiList=[];
set(gh.mainControls.roiSaver,'Value',1,'String',' ');
drawROIsOnFigure;

% --------------------------------------------------------------------
function varargout = addROI_Callback(h, eventdata, handles, varargin)
addROI;

% --------------------------------------------------------------------
function varargout = roiSaver_Callback(h, eventdata, handles, varargin)
gotoROI(h);

%---------------------------------------------------------------------
function defineReset
global state gh
state.acq.scaleXShiftReset=state.acq.scaleXShift;
state.acq.scaleYShiftReset=state.acq.scaleYShift;
state.acq.scanRotationReset=state.acq.scanRotation;
state.acq.zoomFactorReset=state.acq.zoomFactor;
state.acq.zoomonesReset=state.acq.zoomones;
state.acq.zoomtensReset=state.acq.zoomtens;
state.acq.zoomhundredsReset=state.acq.zoomhundreds;
mainControls('reset_Callback',gh.mainControls.reset);

%---------------------------------------------------------------------
function addROI
global state gh
updateMotorPosition;
state.acq.roiList=[state.acq.roiList; [state.acq.scaleXShift state.acq.scaleYShift state.acq.scanRotation...
            state.acq.zoomFactor state.acq.zoomones state.acq.zoomtens state.acq.zoomhundreds ...
            state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]];
set(gh.mainControls.roiSaver,'String',cellstr(num2str((1:size(state.acq.roiList,1))')));
set(gh.mainControls.roiSaver,'Value',size(state.acq.roiList,1)); %VI030409A
drawROIsOnFigure;

% --------------------------------------------------------------------
function varargout = dropROI_Callback(h, eventdata, handles, varargin)
global gh state
if isempty(state.acq.roiList)
    return
end
str=get(gh.mainControls.roiSaver,'String');
val=get(gh.mainControls.roiSaver,'Value');
if ~isempty(str) 
    state.acq.roiList(val,:)=[];
    set(gh.mainControls.roiSaver,'Value',max(val-1,1));
    set(gh.mainControls.roiSaver,'String',cellstr(num2str((1:size(state.acq.roiList,1))')));
end
drawROIsOnFigure;


% --------------------------------------------------------------------
function varargout = backROI_Callback(h, eventdata, handles, varargin)
global gh state
str=get(gh.mainControls.roiSaver,'String');
if ~iscellstr(str) 
    return
end
val=get(gh.mainControls.roiSaver,'Value');
if val == 1
    val=length(str);
else
    val=val-1;
end
set(gh.mainControls.roiSaver,'Value',val);
gotoROI(h);

% --------------------------------------------------------------------
function varargout = nextROI_Callback(h, eventdata, handles, varargin)
global gh state
str=get(gh.mainControls.roiSaver,'String');
if ~iscellstr(str) 
    return
end
val=get(gh.mainControls.roiSaver,'Value');
if val == length(str)
    val=1;
else
    val=val+1;
end
set(gh.mainControls.roiSaver,'Value',val);
gotoROI(h);

% --------------------------------------------------------------------
function varargout = snapShot_Callback(h, eventdata, handles, varargin)
global state
old=state.acq.acquireImageOnChange;
state.acq.acquireImageOnChange=1;
snapShot(state.acq.numberOfFramesSnap);
state.acq.acquireImageOnChange=old;


% --------------------------------------------------------------------
function varargout = numberOfFramesSnap_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = centerOnSelection_Callback(h, eventdata, handles, varargin)
global state gh
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    setUndo;
    %%%VI111609B%%%%%%%%%%
    axis = si_selectImageFigure();
    if isempty(axis)
        return;
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    done=centerOnSelection(axis); %VI111609B
    if done
        setScanProps(h);
        snapShot(1);
    end
else
    beep;
    disp('Cant select ROI when acquiring or focusing.');
end

% --------------------------------------------------------------------
function done=centerOnSelection(handle)
global state gh
done=0;
setImagesToWhole;
if nargin<1
    axis=state.internal.axis(logical(state.acq.imagingChannel));
    image=state.internal.imagehandle(logical(state.acq.imagingChannel));
    axis=axis(1);
    image=image(1);
elseif ishandle(handle)
    ind=find(handle==state.internal.axis);
    if isempty(ind)
        return
    end
    axis=handle;
    image=state.internal.imagehandle(ind);
else
    ~ishandle(handle)
    return
end
fractionUsedXDirection=state.acq.fillFraction;
x=get(axis,'XLim');
y=get(axis,'YLim');
sizeImage=[y(2) round(state.acq.roiCalibrationFactor*x(2))];
volts_per_pixelX=((1/state.acq.zoomFactor)*2*fractionUsedXDirection*abs(state.internal.scanAmplitudeX))/sizeImage(2); %VI102609A %VI091508A
volts_per_pixelY=((1/state.acq.zoomFactor)*2*abs(state.internal.scanAmplitudeY))/sizeImage(1); %VI102609A %VI091508A
[xpt,ypt] = getPointsFromAxes(axis,'numberOfPoints',1,'Cursor','crosshair','nomovegui',1); %VI071310A 
if isempty(xpt)
    return
elseif length(xpt)>1
    xpt=xpt(end);
    ypt=ypt(end);
end
centerX=(xpt);
centerY=(ypt);
state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-x(2)/2);
state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');
done=1;

% --------------------------------------------------------------------
function varargout = zeroRotate_Callback(h, eventdata, handles, varargin)
global state
state.acq.scanRotation=0;
updateGUIByGlobal('state.acq.scanRotation');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = undo_Callback(h, eventdata, handles, varargin)
global state gh

if ~isempty(state.acq.lastROIForUndo)
    state.acq.scaleXShift=state.acq.lastROIForUndo(1);
    state.acq.scaleYShift=state.acq.lastROIForUndo(2);
    state.acq.scanRotation=state.acq.lastROIForUndo(3);
    %state.acq.zoomFactor=state.acq.lastROIForUndo(4); %VI010909A
    setZoomValue(state.acq.lastROIForUndo(4)); %VI010909A
    updateGUIByGlobal('state.acq.scaleYShift');
    updateGUIByGlobal('state.acq.scaleXShift');
    updateGUIByGlobal('state.acq.zoomFactor'); %VI010909A
    updateGUIByGlobal('state.acq.scanRotation');
    setScanProps(h);
    buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
    if all(strcmpi(get(buttonHandles,'Visible'),'on'))
        snapShot(1);
    end
end


% --------------------------------------------------------------------
function tbExternalTrig_Callback(h, eventdata, handles)
global state

%Disallow external trigger for multi-slice acqusitions (VI041308A)
if state.acq.numberOfZSlices > 1
    state.acq.externallyTriggered = 0;
    updateGUIByGlobal('state.acq.externallyTriggered');
    setStatusString('Ext trig not possible');
    disp('External triggering not possible for multi-slice acquisitions');
else
    genericCallback(h);
end


% --------------------------------------------------------------------
function cbInfiniteFocus_Callback(h, eventdata, handles)
genericCallback(h);

% ------------------------(VI091508B)------------------------------------
function cbFinePhaseAdjust_Callback(hObject, eventdata, handles)

genericCallback(hObject); %VI011509A

%%%VI011509A: Removed%%%%%%%%%%
% global gh
% 
% sliderStep = get(gh.mainControls.phaseSlider,'SliderStep');
% 
% if get(hObject,'Value')
%     sliderStep(1) = .005;
% else
%     sliderStep(1) = .025;
% end
% 
% set(gh.mainControls.phaseSlider,'SliderStep',sliderStep); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ------------------------(VI091608A)------------------------------------
function cbAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

genericCallback(hObject);


% --------------------------------------------------------------------
function tbShowAlignGUI_Callback(hObject, eventdata, handles)
genericCallback(hObject);

global state 
if state.internal.showAlignGUI
    tetherGUIs('mainControls','alignGUI','rightcenter'); %VI043009A    
    seeGUI('gh.alignGUI.figure1');
    set(hObject,'String', 'ALIGN <<');
else
    hideGUI('gh.alignGUI.figure1');
    set(hObject,'String', 'ALIGN >>');
end    

% --------------------------------------------------------------------
function tbShowConfigGUI_Callback(hObject, eventdata, handles)
genericCallback(hObject);

global state 
if state.internal.showCfgGUI
    tetherGUIs('mainControls','configurationGUI','righttop'); %VI043009A
    seeGUI('gh.configurationGUI.figure1');
    set(hObject,'String', 'CFG <<');
else
    hideGUI('gh.configurationGUI.figure1');
    set(hObject,'String', 'CFG >>');
end
    


% --------------------------------------------------------------------
function tbFastConfig1_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);

% --------------------------------------------------------------------
function tbFastConfig2_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);

% --------------------------------------------------------------------
function tbFastConfig3_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);

% --------------------------------------------------------------------
function tbFastConfig4_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);

% --------------------------------------------------------------------
function tbFastConfig5_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);

% --------------------------------------------------------------------
function tbFastConfig6_Callback(hObject, eventdata, handles)
toggleFastConfig(hObject);



