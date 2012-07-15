function dataMissedFcn(obj, eventdata)
%DATAMISSEDFCN Callback function invoked upon an Analog Input data missed event
%
%% CREDITS
%   Created 10/24/09, by Vijay Iyer
%% ************************************************

global gh

abortCurrent(false); %Do not set status string
setStatusString('Data Rate Too High!');

%Show dialog
hDlg = errordlg({'Input data was not processed fast enough - acquisition aborted!'; ...
    ''; ...
    'To avoid this error in the future, do one or more of the following: ' ; ...
    '  1) Reduce the data rate (frames per second, number channels, etc)'; ...
    '  2) Reduce the amount of background applications/activity'; ...
    '  3) Reduce the amount of GUI interaction during acquisition'} ...
    , 'Data Rate Too High','modal');

%Set position to just below current configurationGUI position (whether visible or not)
dlgPosn = getpixelposition(hDlg);
mainPosn = getpixelposition(gh.mainControls.figure1);
dlgPosn(1) = mainPosn(1);
dlgPosn(2) = mainPosn(2)-dlgPosn(4)-25;
setpixelposition(hDlg,dlgPosn);

%Bind deleteFcn callback
set(hDlg,'DeleteFcn',@closeErrDlg);

    function closeErrDlg(hObject,eventdata)
        setStatusString('');        
    end

end




