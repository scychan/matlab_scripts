function closeChannelGUI
% closeChannelGUI.m****
% Function that executes if the X is hit on the channelGUI window.
% Will reload the configurationa dn reconfigure the AI devices.
%% CHANGES
%   VI011109A: Handle update to merge figure properties upon closing the channel GUI -- Vijay Iyer 1/11/09
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 31, 2001
%% **************************
global state

if state.internal.channelChanged == 1;
	hideGUI('gh.channelGUI.figure1');
	applyChannelSettings;
else
	hideGUI('gh.channelGUI.figure1');
	state.internal.channelChanged=0;
end
	
updateChannelMergeParameters(); %VI011109A