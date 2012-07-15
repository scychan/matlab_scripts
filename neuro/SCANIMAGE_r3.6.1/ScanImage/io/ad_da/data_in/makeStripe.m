function makeStripe(aiF, SamplesAcquired)
%% function makeStripe(aiF, SamplesAcquired)
% This is the 'SamplesAcqiredFcn' for FOCUS mode operation
% Takes data from data acquisition engine and formats it into a proper intensity image.
%
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see makeStripe.mold -- Vijay Iyer 2/14/09
%
%% CHANGES
%   VI032409A: Add warning dialog for case where acq delay is too large -- Vijay Iyer 3/24/09
%   VI050509A: Increase getdata() speed by using uddobject -- Vijay Iyer 5/5/09
%   VI052109A: Combine get and convert steps into one line, as this was found to reduce the execution time (particularly convert time) -- Vijay Iyer 5/21/09
%   VI062609A: Do pixel binning operation in one line, significantly improving performance (>2X) -- Vijay Iyer 6/26/09
%   VI071509A: Remove premature transpose causing mis-display in sawtooth scan mode -- Vijay Iyer 7/15/09
%   VI090609A: Bin correctly (as in not at all) when state.acq.binFactor=1 -- Vijay Iyer 9/6/09
%   VI091009A: Separate out 'plot' operation from 'compute' operation, so that turning Imaging off for Channels actually reduces processing time. -- Vijay Iyer 9/10/09
%   VI091309A: Remove drawnow() call. It's not necessary for figure update..only adds unnecessary time. -- Vijay Iyer 9/13/09
%   VI091509A: Do circular shift with colon notation -- this is much faster than circshift() itself. -- Vijay Iyer 9/15/09
%   VI102209A: Move start/end line determination outside of channel loop -- Vijay Iyer 10/22/09
%   VI102209B: Handle slow dimension flyback options, handling case of both odd and even # of lines -- Vijay Iyer 10/22/09
%   VI102409A: Remove warning dialog when acq delay is too high; simply make acq delay control red -- Vijay Iyer 10/24/09
%
%% CREDITS
%  Created 2/14/09, by Vijay Iyer
%  Based heavily on earlier version by Tom Pologruto
%% ********************************************************

global gh state

%t1=tic();
%[getTime, wrapTime, computeTime, drawTime, mergeTime] = deal(0);

if state.internal.abortActionFunctions 
    return
end

if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end

try    
    wrapWarning = false; 
    
    if state.internal.looping==1 && state.internal.stripeCounter==0;
        state.internal.secondsCounter=floor(state.internal.lastTimeDelay-etime(clock,state.internal.triggerTime));
        updateGUIByGlobal('state.internal.secondsCounter');
    end
    
    %Compute start/end columns
    [startColumnForStripeData endColumnForStripeData] = determineAcqColumns();
    
    %%%VI102209A: Determine lines to get%%%%
    linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
    ydata=[(1 + (linesPerStripe*state.internal.stripeCounter)) (linesPerStripe*(1 + state.internal.stripeCounter))];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
%tic;
    stripeFinalData = uint16(getdata(state.init.aiFUDD, state.internal.samplesPerStripe)); %VI052109A %VI050509A % Gets enough data for one stripe from the DAQ engine for all channels present 
    %stripeFinalData = uint16(stripeFinalData); %VI052109A
%getTime = toc;

%tic;
    if endColumnForStripeData > state.internal.samplesPerLineF
        if state.internal.numberOfStripes == 1  %Acquiring in frame-sized chunks       
            sampleShift = endColumnForStripeData - state.internal.samplesPerLineF;
            startColumnForStripeData = startColumnForStripeData - sampleShift;
            endColumnForStripeData = state.internal.samplesPerLineF;
            
            stripeFinalData(1:sampleShift,:) = 0;
            stripeFinalData = [stripeFinalData(sampleShift+1:end,:);  stripeFinalData(1:sampleShift,:)]; %VI091509A
            %stripeFinalData = circshift(stripeFinalData,-sampleShift); %VI091509A: Removed %final line of frame will contain extra 0s
        else
            wrapWarning = true;
            setStatusString('Acq Delay Too High!');
            set(gh.configurationGUI.etAcqDelay,'BackgroundColor',[1 0 0]); %VI102409A
            %%%VI102409A: Removed %%%%%%%%%
            %             if isempty(state.internal.acqDelayWarnFig)
            %                 state.internal.acqDelayWarnFig = warndlg('Acquisition delay is too high. Either reduce acquisition delay or disable image striping.','Acq Delay Too High');
            %                 set(state.internal.acqDelayWarnFig,'DeleteFcn',@acqDelayWarnFigDeleteFcn);
            %             end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else %VI102409A
        setStatusString('Focusing...'); %VI102409A: Moved from below
        set(gh.configurationGUI.etAcqDelay,'BackgroundColor',[1 1 1]); %VI102409A
    end
%wrapTime = toc;
            
    if length(stripeFinalData) < state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes
        	fprintf(2, 'WARNING: Data acquisition underrun. Expected to acquire %s samples, only found %s samples in the buffer.', ...
            num2str(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes), ...
            num2str(length(stripeFinalData)));
        if state.internal.compensateForBufferUnderruns
            stripeFinalData(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes) = 0;
            fprintf(2, 'Padding stripe data from %s to %s with NULL values. Image should be considered corrupted.\n         To disable this behavior, set state.internal.compensateForBufferUnderruns equal to 0.\n', ...
            num2str(length(stripeFinalData) + 1), num2str(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes));
        end
    end   
    
    %%%VI102209A: Discard last line if indicated %%%%%%
    discardLineAfterReshape = false;
    if state.acq.slowDimDiscardFlybackLine && (state.internal.stripeCounter + 1) == state.internal.numberOfStripes
        ydata(2) = ydata(2)-1;
        discardLineAfterReshape = ~mod(state.acq.linesPerFrame,2); %For even # of lines - discard line after reshape
        if ~discardLineAfterReshape %For odd # of lines - discard line now, before reshape
            linesPerStripe = linesPerStripe - 1;
            stripeFinalData(end-state.internal.samplesPerLineF+1:end,:) = [];
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tic;  
    inputChannelCounter = 0;
    tempStripe = cell(state.init.maximumNumberOfInputChannels,1);
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if state.internal.abortActionFunctions
            abortFocus;	
            return;
        end

        if state.acq.acquiringChannel(channelCounter)  % if statement only gets executed when there is a channel to focus.
            if state.acq.(['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
                offset=eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ...
                        '-5*state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]); % get PMT offset for channel
            else
                offset=0;
            end
            %%%VI102209A: Relocated %%%%%%%%
            %             linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
            %             ydata=[(1 + (linesPerStripe*state.internal.stripeCounter)) (linesPerStripe*(1 + state.internal.stripeCounter))];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            inputChannelCounter = inputChannelCounter + 1;
            
            if wrapWarning
                tempStripe{channelCounter} = uint16(zeros(linesPerStripe,state.acq.pixelsPerLine));
            elseif state.acq.bidirectionalScan
                temp = reshape(stripeFinalData(:,inputChannelCounter),2*state.internal.samplesPerLineF,linesPerStripe/2); %VI102209C

                temp_top = temp((startColumnForStripeData):(endColumnForStripeData),:);
                temp_bottom = flipud(temp((startColumnForStripeData+state.internal.samplesPerLineF):(endColumnForStripeData+state.internal.samplesPerLineF),:));
                %tempStripe{channelCounter} = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)'; %VI062609A

                %tempStripe{channelCounter} = add2d(tempStripe{channelCounter},state.acq.binFactor)-offset; %VI062609A
          
                tempStripe{channelCounter} = reshape(sum(reshape([temp_top; temp_bottom],state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A %VI090609A
            else
                tempStripe{channelCounter} = reshape(stripeFinalData(:, inputChannelCounter), ...
                    state.internal.samplesPerLineF,linesPerStripe); %Extracts only Channel 1 Data %VI071509A: Don't transpose yet

                %Bin samples into pixels...      
                %tempStripe{channelCounter} = add2d(tempStripe{channelCounter}(:, startColumnForStripeData:endColumnForStripeData), state.acq.binFactor)-offset; %VI062609A %add2d converts tempStripe to double format 
                tempStripe{channelCounter} = reshape(sum(reshape(tempStripe{channelCounter}(startColumnForStripeData:endColumnForStripeData,:),state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)' - offset; %VI062609A, VI071509A, VI090609A
            end           

            
            %%%VI09109A: Relocated below %%%%%%%%
            %             % Displays the current images on the screen as they are acquired.
            %             set(state.internal.imagehandle(channelCounter), 'CData', tempStripe{channelCounter}, ...
            %                 'YData',ydata);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%VI102209B: Discard last line if indicated %%%%%%
            if discardLineAfterReshape
                tempStripe{channelCounter}(end,:) = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            state.acq.acquiredData{channelCounter}(ydata(1):ydata(2),:,1)=tempStripe{channelCounter};
        end
    end
%computeTime = toc();

    
    %%%VI091009A%%%%%%%%%%%%%%%%%%
%tic;    
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if state.acq.imagingChannel(channelCounter)
            set(state.internal.imagehandle(channelCounter), 'CData', tempStripe{channelCounter}, ...
                'YData',ydata);
        end       
    end
%drawTime = toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Merge window update 
    if state.acq.channelMerge
%tic;
        if state.internal.focusFrameCounter == 1 && state.internal.stripeCounter == 0 %VI011109B
            state.internal.mergeStripe = uint8(zeros([size(tempStripe{find(state.acq.acquiringChannel,1)}) 3])); %VI111108A
        else
            state.internal.mergeStripe(:) = 0; 
        end
        
        for i=1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(i)
                if state.acq.mergeColor(i) <=4
                    chanImage = uint8((tempStripe{i}-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255);
                    if state.acq.mergeColor(i) <= 3
                        state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) = state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) + chanImage;
                    elseif state.acq.mergeColor(i) == 4

                        state.internal.mergeStripe(:,:,1) = state.internal.mergeStripe(:,:,1) + chanImage;
                        state.internal.mergeStripe(:,:,2) = state.internal.mergeStripe(:,:,2) + chanImage;
                        state.internal.mergeStripe(:,:,3) = state.internal.mergeStripe(:,:,3) + chanImage;
                    end
                end
            end
        end
        
        set(state.internal.mergeimage,'CData',state.internal.mergeStripe,'YData',ydata); 
%mergeTime = toc;
    end
   
%tic;    
    %drawnow; %VI091309A %This can take up significant time. Worse with 'drawnow expose' (inexplicably). Time is reduced by reducing size of figures.
%displayTime = toc;    
    
   
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;	
        return;
    else
        state.internal.stripeCounter = state.internal.stripeCounter + 1; % increments the stripecounter to ensure proper image displays    
    end

    if  state.internal.stripeCounter == state.internal.numberOfStripes	
        state.internal.stripeCounter = 0;
        state.internal.focusFrameCounter = state.internal.focusFrameCounter + 1;
    end
    
    if state.internal.focusFrameCounter + 1 == state.internal.numberOfFocusFrames && ~state.acq.infiniteFocus 
        state.internal.stripeCounter=0;
        endFocus; 
    end
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;	
        return;
    end

%Use for profiling    
%totalTime=toc(t1);
%fprintf(1,'GetTime=%05.2f \t WrapTime=%05.2f \t ComputeTime=%05.2f \t DrawTime=%05.2f \t MergeTime=%05.2f \t TotalTime=%05.2f \n',1000*getTime,1000*wrapTime,1000*computeTime,1000*drawTime,1000*mergeTime,1000*totalTime);    
    
catch
    if state.internal.abortActionFunctions
        return
    end
    disp(['Error in ' mfilename()]);
    warning(lasterr);
end


%VI032409A: Add as subfunction, rather than nested function, to avoid any performance issues
function acqDelayWarnFigDeleteFcn(hObject,eventdata)
global state;
state.internal.acqDelayWarnFig = [];
return;
