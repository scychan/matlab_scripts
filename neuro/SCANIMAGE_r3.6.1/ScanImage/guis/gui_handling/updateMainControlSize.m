function updateMainControlSize
% Thsi function checks to see if the main controls are 
% set correctly...
global state gh
currentState=get(gh.mainControls.showrotbox,'String');
if ~strcmp(currentState,state.internal.showRotBox)
    mainControls('showrotbox_Callback',gh.mainControls.showrotbox);
end
