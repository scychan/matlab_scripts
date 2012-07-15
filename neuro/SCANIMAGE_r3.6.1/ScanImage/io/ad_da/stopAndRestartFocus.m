%% CHANGES
%   11/24/03 Tim O'Connor - Start using the daqmanager object.
%   VI052008A - Used scim_parkLaser instead of parkLaser, for consistency -- Vijay Iyer 5/20/08
%   VI061908A - Call scim_parkLaser in a way that avoids shutter closing and limits mirror motion to the edge of the FOV-- Vijay Iyer 6/19/08
%   VI061908B - Removed redundant code -- Vijay Iyer 6/19/08
%   VI06208A - Use new maxOffsetX/Y and maxAmplitudeX/Y vars to determine 'fast' park location -- Vijay Iyer 6/25/08
%   VI121908A - Use scanAmplitudeX/Y rather than maxAmplitudeX/Y for 'fast' parking. maxAmplitudeX/Y vars have been eliminated.  -- Vijay Iyer 12/19/08
%   VI010809A - Use linTransformMirrorData instead of rotateAndShiftMirrorData() -- Vijay Iyer 1/08/09
%   VI102609A - Handle state.acq.scanAmplitudeX/Y and state.init.scanOffsetX/Y being specified in optical degrees. For former, using state.internal.scanAmplitudeX/Y suffices; latter is converted as needed. -- Vijay Iyer 10/26/09
%
%% ************************************************************
function stopAndRestartFocus
global gh state

%Stop everything that is happening now....
state.internal.abortActionFunctions = 1;
stopFocus;

%Remove this redundant code -- VI061908B
% if state.init.pockelsOn == 1
%     deviceList=[state.init.aiF state.init.ao2F];
% else
%     deviceList=[state.init.aiF];
% end
% stop(deviceList);
% 
% while ~any(strcmp(get(deviceList, 'Running'), repmat('Off', length(deviceList), 1)))
%     pause(0.001);
% end
%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scim_parkLaser([(state.internal.scanAmplitudeX + state.init.scanOffsetX * state.init.opticalDegreesConversion) (state.internal.scanAmplitudeY + state.init.scanOffsetY * state.init.opticalDegreesConversion)]); %VI102609A %VI061908A %VI062508A %VI121908A
%state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1 / state.acq.zoomFactor * state.acq.mirrorDataOutputOrg); %VI010809A
linTransformMirrorData(); %VI010809A
flushAOData;

resetCounters;
openShutter; %Note that it's not clear why this was done--the shutter wasn't originally closed at all 
if get(state.init.aiF, 'SamplesAvailable') > 0
    try
        flushdata(state.init.aiF);
    end
end
startFocus;
state.internal.stripeCounter = 0;
state.internal.stripeCounter2 = 0;
state.internal.forceFirst = 1;
dioTrigger;
state.internal.abortActionFunctions = 0;