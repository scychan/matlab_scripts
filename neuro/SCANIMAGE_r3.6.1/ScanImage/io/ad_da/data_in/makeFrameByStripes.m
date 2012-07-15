function makeFrameByStripes(ai, SamplesAcquired)
%% function makeFrameByStripes(ai, SamplesAcquired)
% This is the 'SamplesAcqiredFcn' for GRAB/LOOP mode operation
% Takes data from data acquisition engine and formats it into a proper intensity image.
% Function also handles averaging, tracking of # frames/slices, and disk-logging capabilities
%
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makeFrameByStripes.mold -- Vijay Iyer 2/16/09
%   
%   The averaging and non-averaging cases are now interleaved, rather than handled wholly separately.
%
%% CHANGES
%   VI030409A: Allow for 'Focus'-like GRAB acquisitions where data is neither written nor buffered, when 'saveDuringAcq' is on but 0 frames/file is specified -- Vijay Iyer 3/4/09
%   VI050509A: Increase getdata() speed by using uddobject -- Vijay Iyer 5/5/09
%   VI062609A: Do pixel binning operation in one line, significantly improving performance (>2X) -- Vijay Iyer 6/26/09
%   VI063009A: Capture trigger time directly in this function, rather than via getTriggerTime. Use the DAQ Toolbox's DAQ engine value, rather than Matlab clock() function value. -- Vijay Iyer 6/30/09
%   VI063009B: Remove triggerTimeInSeconds field altogether (and unneeded associated in-the-loop processing). This can easily be computed post-hoc using startupTime value which is stored to header with each acquisition. -- Vijay Iyer 6/30/09
%   VI070109A: Move logic specific to first stripe to acquisitionStartedFcn -- Vijay Iyer 7/1/09
%   VI071509A: Correct VI062609A to properly handle the sawtooth scanning case -- Vijay Iyer 7/15/09
%   VI090609A: Bin correctly (as in not at all) when state.acq.binFactor=1 -- Vijay Iyer 9/6/09
%   VI091009A: Separate out 'plot' operation from 'compute' operation, to match makeStripe() mode. Remove use of eval(). -- Vijay Iyer 9/10/09
%   VI091309A: Remove drawnow() call. It's not necessary for figure update..only adds unnecessary time. -- Vijay Iyer 9/13/09
%   VI091509A: Do circular shift with colon notation -- this is much faster than circshift() itself. -- Vijay Iyer 9/15/09
%   VI102209A: Handle slow dimension flyback options, handling case of both odd and even # of lines -- Vijay Iyer 10/22/09
%   VI102709A Vijay Iyer 10/27/09 - Use state.internal.repeatPeriod for determining countdown time in midst of acquisition 
%   VI102909A Vijay Iyer 10/29/09 - Use the stack trigger time, rather than the individual acquisition trigger time, for countdown/countup timer display
%   VI110409A Vijay Iyer 11/04/09 - Restore drawnow() call (removed in VI091309A) to ensure that the frame counter display updates in the MainControls dialog -- Vijay Iyer 11/04/09
%   VI073010A Vijay Iyer 7/30/10 - Determine whether current stripe is the last stripe once, and store in 'lastStripe' -- Vijay Iyer 7/30/10
%   VI073010B Vijay Iyer 7/30/10 - BUGFIX: Fix dimension mismatch errors, and unnecessary augmentation of preallocated arrays, related to flyback line discard -- Vijay Iyer 7/30/10
%   
%% CREDITS
%  Created 2/16/09, by Vijay Iyer
%  Based heavily on earlier version by Tom Pologruto
%% ********************************************************
global state gh

%t1=tic();
%[getTime,wrapTime,computeTime,drawTime,mergeTime,writeTime] = deal(0);

% Write complete header string  for only the first frame
if state.internal.abortActionFunctions
    abortInActionFunction;
    return
end

%Reset counters, if needed
if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end

%Open the shutter if it's time
if state.shutter.shutterOpen==0
    if all(state.shutter.shutterDelayVector==[state.internal.frameCounter state.internal.stripeCounter])
        openShutter;
    end
end

if state.internal.stripeCounter==0  

    %Handle displayed seconds counter, which behaves differently for external/internally triggered cases
    if state.internal.looping==1 && ~state.acq.externallyTriggered %count-down timer
        state.internal.secondsCounter=max(round(state.internal.repeatPeriod-etime(clock,state.internal.stackTriggerTime)),0); %VI102909A %VI102709A
    else %count-up timer
        state.internal.secondsCounter=floor(etime(clock,state.internal.stackTriggerTime)); %VI102909A
    end

    set(gh.mainControls.secondsCounter,'String',num2str(state.internal.secondsCounter));

end

try
    %Is this the last time through this callback?
    if state.internal.frameCounter == state.acq.numberOfFrames && state.internal.stripeCounter==state.internal.numberOfStripes-1
        closeShutter;
        stopGrab;
        if state.acq.numberOfZSlices > 1
            if MP285RobustAction(@startMoveStackFocus, 'move to next slice in stack', mfilename) %VI101508A
                abortCurrent;
                return;
            end
        end
    end

    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    end

    %%%Determine start/stop lines and columns for data to get
    linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
    startLine =1 + state.internal.stripeCounter*linesPerStripe;
    stopLine = startLine+linesPerStripe-1;
    stopLineLoopDiscard = stopLine; %VI073010B - stopLine value to use in handling line-discard cases within loop over channels

    %Compute start/end columns
    [startColumnForFrameData endColumnForFrameData] = determineAcqColumns();
    
   %%%Get the data
%tic;
    frameFinalData = uint16(getdata(state.init.aiUDD, state.internal.samplesPerFrame/state.internal.numberOfStripes)); %VI050509A %VI042208A
%getTime = toc;

%tic;
    %%%Handle case where acquired data wraps beyond line period 'boundary'
    if endColumnForFrameData > state.internal.samplesPerLine
        if state.internal.numberOfStripes == 1            
            sampleShift = endColumnForFrameData - state.internal.samplesPerLine;
            startColumnForFrameData = startColumnForFrameData - sampleShift;
            endColumnForFrameData = state.internal.samplesPerLine;

            frameFinalData(1:sampleShift,:) = 0;
            frameFinalData = [frameFinalData(sampleShift+1:end,:);  frameFinalData(1:sampleShift,:)]; %VI091509A
            %frameFinalData = circshift(frameFinalData,-sampleShift); %VI091509A: Removed
        else %this should have been prevented at start of acquisition
            fprintf(2,'WARNING (%s): Acquisition delay is too high. Aborting acquisition. Reduce acquisition delay or turn off image striping\n',mfilename);
            abortCurrent();
            return;
        end
    end
%wrapTime=toc;    

    lastStripe = (state.internal.stripeCounter == (state.internal.numberOfStripes - 1)); %VI073010A

    %%%VI102209A: Discard last line if indicated %%%%%%
    discardLineAfterReshape = false;
    if state.acq.slowDimDiscardFlybackLine && lastStripe  %Final line of acquired data should be discarded %VI073010A
        stopLineLoopDiscard = stopLine - 1; %VI073010B
        discardLineAfterReshape = ~mod(state.acq.linesPerFrame,2); %For even # of lines - discard line after reshape
        if ~discardLineAfterReshape %For odd # of lines - discard line now, before reshape
            stopLine = stopLine - 1;
            linesPerStripe = linesPerStripe - 1;
            frameFinalData(end-state.internal.samplesPerLine+1:end,:) = [];
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %Determine value of 'averaging' flag
    averaging = state.acq.averaging && state.acq.numberOfFrames > 1;

    %Determine frame index (can be frame counter, slice counter, or both, depending on case)
    if state.internal.keepAllSlicesInMemory && ~state.acq.saveDuringAcquisition
        if ~averaging %store each individual frame and slice
            position =(state.internal.frameCounter + state.internal.zSliceCounter*state.acq.numberOfFrames);
        else
            position = state.internal.zSliceCounter + 1;
        end
    elseif averaging || state.acq.saveDuringAcquisition
        position = 1;
    else
        position = state.internal.frameCounter;
    end

    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    end

    %Preallocate/initialize
    inputChannelCounter = 0;

%tic;   
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if state.acq.acquiringChannel(channelCounter) % if statemetnt only gets executed when there is a channel to acquire.
            inputChannelCounter = inputChannelCounter + 1;
            if state.acq.(['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
                offset=eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ...
                    '-5*state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]); % get PMT offset for channel
            else
                offset=0;
            end
         
            if state.acq.bidirectionalScan
                temp = reshape(frameFinalData(:,inputChannelCounter),2*state.internal.samplesPerLineF,linesPerStripe/2);
                temp_top = temp((startColumnForFrameData):(endColumnForFrameData),:);
                temp_bottom = flipud(temp((startColumnForFrameData+state.internal.samplesPerLineF):(endColumnForFrameData+state.internal.samplesPerLineF),:));
                %currenttempImage = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)'; %VI062609A

                %Bin data...
                if averaging || discardLineAfterReshape %VI073010B
                    %currenttempImage = add2d(currenttempImage,state.acq.binFactor)-offset; %VI062609A
                    currenttempImage = reshape(sum(reshape([temp_top; temp_bottom],state.acq.binFactor,[]),1), state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A %VI090609A                   
                else
                    %state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) = add2d(currenttempImage,state.acq.binFactor)-offset; %VI062609A
                    state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) = reshape(sum(reshape([temp_top; temp_bottom],state.acq.binFactor,[]),1), state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A   %VI090609A
                end
            else
                currenttempImage = reshape(frameFinalData(:,inputChannelCounter), state.internal.samplesPerLine, linesPerStripe); %VI062609A, VI071509A	% Converts data into proper shape for frame

                %Bin/strip data...
                if averaging || discardLineAfterReshape %VI073010B
                    %currenttempImage = add2d(currenttempImage(:, startColumnForFrameData:endColumnForFrameData), state.acq.binFactor) - offset; %VI062609A
                    currenttempImage = reshape(sum(reshape(currenttempImage(startColumnForFrameData:endColumnForFrameData,:),state.acq.binFactor,[]),1), state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A %VI071509A %VI090609A
                else
%                     state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) = ...
%                         add2d(currenttempImage(:, startColumnForFrameData:endColumnForFrameData), state.acq.binFactor) - offset;
                    state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) = ...
                        reshape(sum(reshape(currenttempImage(startColumnForFrameData:endColumnForFrameData,:),state.acq.binFactor,[]),1), state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A %VI071509A %VI090609A
                end
            end


            %%%VI073010B%%%%%%%
            if discardLineAfterReshape
                currenttempImage(end,:) = [];
                
                if ~averaging
                    state.acq.acquiredData{channelCounter}(startLine:stopLineLoopDiscard,:,position) = currenttempImage;
                end
            end               
            %%%%%%%%%%%%%%%%%%%
            
            %For averaging case, store rolling sum into double array
            if averaging
                if state.internal.frameCounter == 1
                    state.internal.tempImage{channelCounter}(startLine:stopLineLoopDiscard,:) = double(currenttempImage); %VI073010B
                elseif state.internal.frameCounter > 1 % & state.internal.frameCounter <= state.acq.numberOfFrames
                    state.internal.tempImage{channelCounter}(startLine:stopLineLoopDiscard,:) = ...
                        ((state.internal.frameCounter - 1)*state.internal.tempImage{channelCounter}(startLine:stopLineLoopDiscard,:) ... %VI073010B
                        + double(currenttempImage))/(state.internal.frameCounter);
                end
            end        

        end
    end
%computeTime = toc();      

    %%%VI091009A%%%%%%%%%%%%%%%%
    %%%VI102209A%%%%%%%%%%
    if discardLineAfterReshape
        stopLine = stopLine - 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%
%tic; 

    for channelCounter = 1:state.init.maximumNumberOfInputChannels
       if state.acq.imagingChannel(channelCounter)
           if averaging
               set(state.internal.imagehandle(channelCounter), 'CData', ...
                   state.internal.tempImage{channelCounter}(startLine:stopLine,:), 'YData', [startLine stopLine]);
           else
               set(state.internal.imagehandle(channelCounter), 'CData', ...
                   state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position), 'YData', [startLine stopLine]);
           end           
       end        
    end
%drawTime = toc;    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
%tic;
    if state.acq.channelMerge && ~state.acq.mergeFocusOnly
        if averaging
            makeMergeStripe(state.internal.tempImage,[startLine stopLine],1);
        else
            makeMergeStripe(state.acq.acquiredData,[startLine stopLine],position);
        end
    end
%mergeTime = toc;

    %Update figures/GUI status  
%tic;    
    %drawnow; %VI091309A %This can take up significant time. Worse with 'drawnow expose' (inexplicably). Time is reduced by reducing size of figures.
%displayTime = toc;    

    setStatusString('Acquiring...');
    
    %Increment stripeCounter 
    state.internal.stripeCounter = state.internal.stripeCounter + 1;      

    %Handle end of frame (and acquisition), if reached
    if lastStripe %VI073010A %finished a frame!
        state.internal.stripeCounter = 0;

%tic;
        if ~averaging && state.acq.saveDuringAcquisition && state.acq.framesPerFile && ~state.internal.snapping %VI030409A
            writeData;
        end
%writeTime = toc;

        if state.internal.frameCounter == state.acq.numberOfFrames %finished the set of frames to average

            if averaging
                for channelCounter = 1:state.init.maximumNumberOfInputChannels
                    state.acq.acquiredData{channelCounter}(:,:,position) = uint16(state.internal.tempImage{channelCounter});
                end
            end
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %Shouldn't be needed actually
            endAcquisition;% ResumeLoop, parkLaser, Close Shutter, appendData, reset counters,...
        else
            state.internal.frameCounter = state.internal.frameCounter + 1;	% Increments the frameCounter to ensure proper image storage and display
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %Update frameCounter display (reflects frame count, rather than # frames/done; use 'set' rather than updateGUIByGlobal() to speed performance
            drawnow; %VI110409A
        end
    end
    
%Use for profiling    
%   totalTime = toc(t1);
%   fprintf(1,'GetTime=%05.2f \t WrapTime=%05.2f \t ComputeTime=%05.2f \t DrawTime=%05.2f \t MergeTime=%05.2f \t WriteTime=%05.2f \t TotalTime=%05.2f\n',1000*getTime,1000*wrapTime,1000*computeTime, 1000*drawTime,1000*mergeTime,1000*writeTime, 1000*totalTime);
%end

catch
    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    else
        setStatusString('Error in frame by stripes');
        disp('makeFrameByStripes: Error in action function');
        disp(getLastErrorStack);
    end
end
    
%Paints a stripe of color-merged data based on the imageData at
function makeMergeStripe(imageData,yData,posn)

global state

yMask = yData(1):yData(2);

if state.internal.stripeCounter == 0 && state.internal.frameCounter == 1
    state.internal.mergeStripe = uint8(zeros([length(yMask) size(imageData{find(state.acq.acquiringChannel,1)},2) 3])); 
else 
    state.internal.mergeStripe(:) = 0; 
end

for i=1:state.init.maximumNumberOfInputChannels
    if state.acq.acquiringChannel(i)
        if state.acq.mergeColor(i) <= 4
            chanImage = uint8(((double(imageData{i}(yMask,:,posn))-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255));
            if state.acq.mergeColor(i) <= 3
                state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) =  state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) + chanImage;
            elseif state.acq.mergeColor(i) == 4
                state.internal.mergeStripe(:,:,1) = state.internal.mergeStripe(:,:,1) + chanImage;
                state.internal.mergeStripe(:,:,2) = state.internal.mergeStripe(:,:,2) + chanImage;
                state.internal.mergeStripe(:,:,3) = state.internal.mergeStripe(:,:,3) + chanImage;
            end
        end
    end
end

set(state.internal.mergeimage,'CData',state.internal.mergeStripe,'YData',yData); %VI021109A




	
