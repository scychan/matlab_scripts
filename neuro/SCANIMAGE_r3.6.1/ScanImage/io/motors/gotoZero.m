function gotoZero
% Moves motor to last zeroed position
%
%% CHANGES
%   VI100608A: Defer motor velocity changes to setMotorPosition() -- Vijay Iyer 10/06/08
%   VI101008A: Defer updateRelativeMotorPosition() to setMotorPosition() -- Vijay Iyer 10/10/08
%   VI060610A: Prevent gotoZero() operation if relative origin has not been set (for all dimensions) -- Vijay Iyer 6/6/10
%
%% ************************************************************

	global state
		
    
    %%%VI060610A%%%%%
    if any([state.motor.offsetX state.motor.offsetY state.motor.offsetZ]==0)
        fprintf(2,'WARNING: Relative origin must be defined (for all dimensions) in order to move to relative origin\n');
        return;
    end
    %%%%%%%%%%%%%%%%%
    
	setStatusString('Moving to (0,0,0)');
	%MP285SetVelocity(state.motor.velocityFast); %VI100608A
	state.motor.absXPosition=state.motor.offsetX;
	state.motor.absYPosition=state.motor.offsetY;
	state.motor.absZPosition=state.motor.offsetZ;
	setMotorPosition;
	%updateRelativeMotorPosition; %VI101008A
	%MP285SetVelocity(state.motor.velocitySlow); %VI100608A
	disp(['*** Staged moved to relative (0,0,0) ***']);
	setStatusString('');
		