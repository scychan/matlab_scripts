function setupDAQDevices_ConfigSpecific
%% function setupDAQDevices_ConfigSpecific
% sets the configuration specific properties of AI and AO objects
%
%
%% CHANGES
% Modified 11/24/03 Tim O'Connor - Start using the daqmanager object.
% Modified 02/15/08 Vijay Iyer - Use continous, rather than finite, acquisition in focus mode
%                                 since the AI object will be explicitly stopped anyway. This 
%                                 solves problem where moderately long finite acqs are disallowed in DAQmx. (VI021508A)
% Modified 02/21/08 Vijay Iyer - Don't set 'RepeatOutput' property for focus mode AO object here -- leave this to startFocus()
% Modified 03/08/08 Vijay Iyer - Use continuous, rather than finite, acquisition in grab mode as well (VI030808A)
% Modified 01/15/09 Vijay Iyer - (Refactoring) Moved AO object changes to setupAOData(). Call setupAOData() from this function, as they always go together. (VI011509A)
% Modified 1/21/09 Vijay Iyer - msPerLine is now actually in milliseconds
% Modified 5/21/09 Vijay Iyer - Moved selectNumberOfStripes() code into here, as this is only place it's called. 
% VI052009B: (REFACTOR) All calls to setupDaqDevices_ConfigSpecifig() also call preallocateMemory(), so call it here -- Vijay Iyer 5/21/09
% VI091009A: Remove change of EraseMode based on number of stripes. Mode of 'none' does provide best performance in all cases, so should not be changed. -- Vijay Iyer 9/10/09
% VI102209A: Use state.internal.storedLinesPerFrame where appropriate -- Vijay Iyer 10/22/09
% VI102409A: Use state.internal.nominalMsPerLine for determining number of stripes -- Vijay Iyer 10/24/09
% VI072610A: Revert VI102209A -- striping should be determined by acquired linesPerFrame, not storedLinesPerFrame -- Vijay Iyer 7/26/10
%
%% CREDITS
% Written by: Thomas Pologruto & Bernardo Sabatini
% Cold Spring Harbor Labs
% 8-11-03
%% *************************************************************************

global state gh

%Set number of focus frames to ensure proper time regardless of image size...
state.internal.numberOfFocusFrames=ceil(state.internal.focusTime/(state.acq.linesPerFrame * 1e-3 * state.acq.msPerLine)); %VI012109A

%%%VI011509A: Refactored Out %%%%%%%%
% % GRAB output: set number of frames in GRAB output object to drive mirrors
% set(state.init.ao2, 'RepeatOutput', (state.acq.numberOfFrames -1));
% 
% % FOCUS output: set number of frames in FOCUS output object to drive mirrors
% %set(state.init.ao2F, 'RepeatOutput', (state.internal.numberOfFocusFrames -1)); %VI022108A
% 
% % 	if state.init.pockelsOn == 1			% and pockel cell, if on
% % 		set(getfield(state.init,['ao'  num2str(state.init.eom.scanLaserBeam) 'F']), 'RepeatOutput', (state.internal.numberOfFocusFrames -1));
% % 	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectNumberOfStripes;	% select number of stripes based on # channels and resolution

% GRAB acquisition: set up total acquisition duration
actualInputRate = get(state.init.ai, 'SampleRate');
state.internal.samplesPerLine = round(actualInputRate * 1e-3 * state.acq.msPerLine); %VI012109A
state.internal.samplesPerFrame = state.internal.samplesPerLine*state.acq.linesPerFrame;

% GRAB acquisition: set up action function trigger (1 per stripe)
%set(state.init.ai, 'SamplesPerTrigger', state.internal.samplesPerFrame*state.acq.numberOfFrames); %VI030808A
set(state.init.ai,'SamplesPerTrigger',inf); %VI030808A
set(state.init.ai, 'SamplesAcquiredFcnCount', state.internal.samplesPerFrame/state.internal.numberOfStripes);

% FOCUS acquisition: set up total acquisition duration
actualInputRate = get(state.init.aiF, 'SampleRate');
state.internal.samplesPerLineF = round(actualInputRate * 1e-3 * state.acq.msPerLine); %VI012109A
state.internal.samplesPerStripe = state.internal.samplesPerLineF*state.acq.linesPerFrame/state.internal.numberOfStripes;
set(state.init.aiF,'SamplesPerTrigger',inf); %VI02152008A
% 	set(state.init.aiF, 'SamplesPerTrigger', ...
% 		state.internal.samplesPerStripe*state.internal.numberOfStripes*state.internal.numberOfFocusFrames);

% FOCUS acquisition: set up action function trigger (1 per stripe)
set(state.init.aiF, 'SamplesAcquiredFcnCount', state.internal.samplesPerStripe);

% PMT Offset: set up total acquisition duration
actualInputRate = get(state.init.aiPMTOffsets, 'SampleRate');
totalSamplesInputOffsets = 50*state.acq.samplesAcquiredPerLine;		% acquire 50 lines of Data
set(state.init.aiPMTOffsets, 'SamplesPerTrigger', totalSamplesInputOffsets);
set(state.init.aiPMTOffsets, 'SamplesPerTrigger', totalSamplesInputOffsets);

% PMT Offset: set up trigger for end of PMT offset acquisition
set(state.init.aiPMTOffsets, 'SamplesAcquiredFcnCount', totalSamplesInputOffsets);

%Handle the AO side of things, which includes creating the AO data
setupAOData(); %VI011509A


%%%VI052109A%%%%%%%%%%
function selectNumberOfStripes()
global state gh

if ~isempty(find(factor(state.acq.linesPerFrame) ~= 2)) || state.acq.disableStriping
    state.internal.numberOfStripes = 1;
else
    targetLinesPerStripe = state.internal.targetUpdatePeriod / (1e-3*state.internal.nominalMsPerLine); %VI102409A

    if targetLinesPerStripe >= state.acq.linesPerFrame
        state.internal.numberOfStripes = 1;
    else
        possibleLinesPerStripe = min(2.^[0:10],state.acq.linesPerFrame);
        idx = find(targetLinesPerStripe <= possibleLinesPerStripe,1);

        state.internal.numberOfStripes = state.acq.linesPerFrame / possibleLinesPerStripe(idx);
    end

end

%%%VI091090A: Removed %%%%%%%%
% %If not striping, might as well use 'normal' erase mode, which actually benchmarks as faster
% imageHandles = [state.internal.imagehandle state.internal.mergeimage];
% if state.internal.numberOfStripes == 1
%     set(imageHandles,'EraseMode','normal');
% else
%     set(imageHandles,'EraseMode','none');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

preallocateMemory(); %VI052109B

return;
%%%%%%%%%%%%%%%%%%%%%
    