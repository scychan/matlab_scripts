function setImagesToWhole
%% function setImagesToWhole
%   Function that redraws acquisition windows based on acquired data. Used during resize,etc.
%
%% MODIFICATIONS
%   VI022308A Vijay Iyer 2/23/08 - Handle merge channel figure
%   VI111708A Vijay Iyer 11/17/08 - Handle case where blue merges as gray
%   VI111708B Vijay Iyer 11/17/08 - Remove unnecessary warning message
%   VI011109A Vijay Iyer 1/11/09 - Handle 4-color merge 
%   VI021109A Vijay Iyer 2/11/09 - Don't set merge figure EraseMode; this is deferred to selectNumberOfStripes()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
global state

if isstruct(state) && isfield(state,'init') && isfield(state,'acq') 
    updateMerge=false;
    if isfield(state.acq,'channelMerge') && state.acq.channelMerge %VI022308A (copying above convention of checking for field existence--probably stupid?)
        if ~isempty(state.acq.acquiredData) && iscell(state.acq.acquiredData)
            for i=1:state.init.maximumNumberOfInputChannels %VI011109A
                if ~isempty(state.acq.acquiredData{i})        
                    acqSize = size(state.acq.acquiredData{i});
                    mergeData = uint8(zeros([acqSize(1) acqSize(2) 3]));
                    updateMerge=true;
                    break;
                end
            end
        end
    end

    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if isfield(state.acq,'acquiringChannel')
            if state.acq.acquiringChannel(channelCounter)                  
                if ~isempty(state.acq.acquiredData) && iscell(state.acq.acquiredData) && ~isempty(state.acq.acquiredData{channelCounter})
                    set(state.internal.imagehandle(channelCounter),'CData', state.acq.acquiredData{channelCounter}(:,:,1),...
                        'YData',[1 size(state.acq.acquiredData{channelCounter},1)]);
                    if updateMerge %VI022308A, VI011109A
                        %%%VI011109A%%%%%%%%%%%
                        if state.acq.mergeColor(channelCounter) <= 3
                            mergeData(:,:,state.acq.mergeColor(channelCounter)) = uint8(((double(state.acq.acquiredData{channelCounter}(:,:,1))-state.internal.lowPixelValue(channelCounter))/(state.internal.highPixelValue(channelCounter)-state.internal.lowPixelValue(channelCounter)) * 255));                            
                        elseif state.acq.mergeColor(channelCounter) == 4
                            chanImage = uint8(((double(state.acq.acquiredData{channelCounter}(:,:,1))-state.internal.lowPixelValue(channelCounter))/(state.internal.highPixelValue(channelCounter)-state.internal.lowPixelValue(channelCounter)) * 255));
                            mergeData = mergeData + repmat(chanImage,[1 1 3]);
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end                   
            end
        end
    end
    
   
    if updateMerge %VI022308A
        %%%VI011109A: Removed %%%%%%%%%%
        %         %%%VI111708A%%%%%%%
        %         if state.acq.acquiringChannel(3) && state.acq.mergeBlueAsGray
        %             mergeData(:,:,1) = mergeData(:,:,1) + mergeData(:,:,3);
        %             mergeData(:,:,2) = mergeData(:,:,2) + mergeData(:,:,3);
        %         end
        %         %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        set(state.internal.mergeimage,'CData',mergeData,'YData',[1 size(mergeData,1)]); %VI021109A
    end
end

