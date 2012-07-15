%% function updateStackEndpoints
% Function that updates display of stack endpoints
%
%% CHANGES
%   VI111108A: Handle case where update is a clearing of stack start or stop; enable GRAB button only if stack start & stop are defined
%   VI112309A: Allow GRAB button on MotorGUI to appear if only start is defined, if the 'stackEndpointsDominate' flag is false  -- Vijay Iyer 11/23/09
%   VI112309B: Disable End controls when 'stackEndpointsDominate' is false, as End has no effect -- Vijay Iyer 11/23/09
%
%% CREDITS
%   Created 10/09/08 by Vijay Iyer
%% **************************

function updateStackEndpoints

global state gh

out=[];

if state.motor.motorOn
    if ~isempty(state.motor.stackStart)
        set(gh.motorGUI.etStackStart,'String', num2str(state.motor.stackStart(3) - state.motor.offsetZ));
    else
        set(gh.motorGUI.etStackStart,'String', ''); %VI111108A
    end
    
    if ~isempty(state.motor.stackStop)
        set(gh.motorGUI.etStackStop,'String', num2str(state.motor.stackStop(3) - state.motor.offsetZ));
    else
        set(gh.motorGUI.etStackStop,'String', ''); %VI111108A
    end
    
    %%%VI111108A%%%%
    if ~isempty(state.motor.stackStart) && (~isempty(state.motor.stackStop) || ~state.motor.stackEndpointsDominate) %VI112309A
        set(gh.motorGUI.GRAB,'Enable','on');
    else
        set(gh.motorGUI.GRAB,'Enable','off');
    end
    %%%%%%%%%%%%%%%%%
    
    %%%VI112309B%%%%
    endControls = [gh.motorGUI.setStackStopButton gh.motorGUI.etStackStop];
    if state.motor.stackEndpointsDominate
        set(endControls,'Enable','on');        
    else
        set(endControls,'Enable','off');
    end
    %%%%%%%%%%%%%%%%%
        
end
    

