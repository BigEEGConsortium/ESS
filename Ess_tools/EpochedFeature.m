classdef EpochedFeature < Block
    properties
       % eventTimes % latencis of events from which epochs have been extracted, 
                   % relative to the start of their respective data recordings.
    end;
    methods
        function obj = EpochedFeature
            obj = obj@Block;
            obj.type = 'ess:EpochedFeature'; % use / to append childen types here.
            obj = obj.setId;
        end
        function [obj noisyEpochIds averageOutlierRatio] = removeNoisyEpochs(obj, varargin)
             trialByFeature = obj.index ('trial', ':');
             medianFeatures = median(trialByFeature);
             centeredFeatures = bsxfun(@minus, trialByFeature, medianFeatures);
             clear medianFeatures trialByFeature;
             robustStdFeatures = 1.4826 * median(abs(centeredFeatures)); % median absolute deviation multiplied by a factor gives robust standard deviation
             robustZFeatures =  bsxfun(@times, centeredFeatures, 1./robustStdFeatures);
             clear robustStdFeatures;
             
             outlierFeature = abs(robustZFeatures) > 3; % both too negative and too positive
             averageOutlierRatio = nanmean(outlierFeature, 2);
             cleanEpochIds = averageOutlierRatio < 0.13;
             clear robustZFeatures outlierFeature;      
             
             obj = obj.sliceAxes('trial', find(cleanEpochIds));
             assert(obj.isValid, 'Result is not valid');
        end;
    end
    methods (Static)
        function [trialFrames, trialTimes, trialHEDStrings, trialEventTypes] = getTrialTimesFromEEGstructure(varargin)
            % [trialFrames, trialTimes, trialHEDStrings, trialEventTypes]= getTrialTimesFromEEGstructure(varargin)
            % trialTimes is                                    
            
            inputOptions = arg_define(varargin, ...
                arg('EEG', [],[],'EEGLAB EEG structure. Can be the first argument without the keyword EEG'),...
                arg('hedStringsCell', [],[],'HED string to epoch on. Only events with HED strings that match to at least one of the items in this cell array of HED strings will be included in the returned trial times.', 'type', 'cellstr'), ...
                arg('eventTypes', [],[],'Event types to epoch on. Empty means all events ', 'type', 'cellstr'), ...
                arg('excludedEventTypes', {},[],'Events types to exclude', 'type', 'cellstr'), ...
                arg('maxSameTypeProximity', 0.5,[0 Inf],'How much to allow same-type event overlap. When two events have the same type or HED string are closer than this value (in seconds), only one of them will be included.'),...
                arg('maxSameTypeCount', Inf,[1 Inf],'How many same-time events are allowed. Events with highest overlap with the same type are deleted first.')...
            );
            
            EEG = inputOptions.EEG;
            trialFrames = [EEG.event(:).latency];
            trialTimes = trialFrames/ EEG.srate;
            trialHEDStrings = {EEG.event(:).usertags};
            trialEventTypes = {EEG.event(:).type};
            
            % remove events of the same type that have too much overlap with their own kind
            if inputOptions.maxSameTypeProximity < max(trialTimes) - min(trialTimes)
                allEventIdsToRemove = [];
                [uniqueHEDStrings, dummy, id]= unique(trialHEDStrings);
                clear dummy;
                for i=1:length(uniqueHEDStrings)
                    eventSubset = find(id == i);
                    n = length(eventSubset);
                    temporalOverlap  = sparse(n,n);
                    eventSubsetTimes = trialTimes(eventSubset);
                    for j=1:n
                        eventJTime = eventSubsetTimes(j);
                        % start from event j and go either back or forward, early stop in each case
                        % onthe first non-overlap.
                        
                        % go back from j
                        for k=j:-1:1
                            if k~=j
                                temporalOverlap(j,k) = max(0, inputOptions.maxSameTypeProximity - abs(eventSubsetTimes(k) - eventJTime));
                                if temporalOverlap(j,k) == 0
                                    break;
                                end;
                            end;
                        end;
                        
                        % go forward from j
                        for k=j:n
                            if k~=j
                                temporalOverlap(j,k) = max(0, inputOptions.maxSameTypeProximity - abs(eventSubsetTimes(k) - eventJTime));
                                if temporalOverlap(j,k) == 0
                                    break;
                                end;
                            end;
                        end;
                    end;
                    
                    totalOverlap = sum(temporalOverlap);
                    afterRemovalTemporalOverlap = temporalOverlap;
                    eventIdToRemove = [];

                    if length(totalOverlap) > inputOptions.maxSameTypeCount
                        % remove highest overlapping events first, until
                        % maximum of maxSameTypeCount event remain.
                        
                        % do a random permute on events with zero overlap 
                        % so events with total overlap of zero are randomly 
                        % removed (otherwise they will be deleted from the
                        % start of the recording, which is not desirable).
                        [sortedOverlap sortId] = sort(totalOverlap, 'descend');
                        zeroId = find(sortedOverlap == 0, 1);
                        
                        % randomly shuffle IDs with zero overlap
                        idsWithZeroOverlap = sortId(zeroId:end);
                        idsWithZeroOverlap = idsWithZeroOverlap(randperm(length(idsWithZeroOverlap)));
                        sortId(zeroId:end) = idsWithZeroOverlap;
                        
                        eventIdToRemove = sortId(1:(length(totalOverlap) - inputOptions.maxSameTypeCount));
                        afterRemovalTemporalOverlap(eventIdToRemove,:) = 0;
                        afterRemovalTemporalOverlap(:,eventIdToRemove) = 0;
                        totalOverlap = sum(afterRemovalTemporalOverlap);
                    end;
                    
                    
                    % start removing events with highest overlap until no event has an overlap
                    while full(any(totalOverlap))
                        [dummy maxId] = max(totalOverlap);
                        %totalOverlap = totalOverlap - temporalOverlap(maxId,:);
                        afterRemovalTemporalOverlap(maxId,:) = 0;
                        afterRemovalTemporalOverlap(:,maxId) = 0;
                        totalOverlap = sum(afterRemovalTemporalOverlap);
                        eventIdToRemove = [eventIdToRemove maxId];
                    end;
                    
                    if ~isempty(eventIdToRemove)
                        fprintf('- Removed %d of the original %d (%d percent) events of \n   type "%s" due to excessive overlap.\n', length(eventIdToRemove), n, round(100 * length(eventIdToRemove) / n), uniqueHEDStrings{i});
                    end;
                    
                    allEventIdsToRemove = cat(1, allEventIdsToRemove(:), eventSubset(eventIdToRemove));                    
                    clear afterRemovalTemporalOverlap totalOverlap temporalOverlap;
                end;
                
                trialFrames(allEventIdsToRemove) = [];
                trialTimes(allEventIdsToRemove) = [];
                trialHEDStrings(allEventIdsToRemove) = [];
                trialEventTypes(allEventIdsToRemove) = [];
                
            end;
        end;
        
        function epochedTensor = epochTensor(tensor, indices, numberOfIndicesBefore, numberOfIndicesAfter)
            % epochedTensor = epochTensor(tensor, times, numberOfFramesBefore, numberOfFramesAfter)
            %
            % Extracts epochs from the *first dimension* of input tensor at given indices
            % with provided "number of indices before" (numberOfIndicesBefore)
            % and "number of indices aftr" (numberOfIndicesAfter).
            % The output tensor will have size of the number of epochs as its first,
            % dimension and the indices associated with the epoch dimension
            % (number of epochs before + 1 + number of epochs after) as its second dimension.
            % all other dimensions will have the same order and size as the
            % remaining dimensions (after the first) of the input tensor.
            % any epoch that violates the boundaries is automatically removed so the number of 
            % output epochs may be less than length(times)
            %
            % Input example:
            %   tensor = zeros(200, 30, 40)
            %   indices = [5:10:100];
            %   numberOfIndicesBefore = 2;
            %   numberOfIndicesAfter = 3;
            % Output:
            % size(epochedTensor) = [10 6 30 40]
            
            s = size(tensor);
            epochLength = numberOfIndicesBefore + 1 + numberOfIndicesAfter;
            numberOfEpochs = length(indices);

            epochDimensionIndices  = repmat(indices(:), [1 epochLength]) + repmat(-numberOfIndicesBefore:numberOfIndicesAfter, [numberOfEpochs 1]);
            outOfBoundEpochs = any(epochDimensionIndices < 1, 2) | any(epochDimensionIndices > size(tensor, 1), 2);
            epochDimensionIndices(outOfBoundEpochs,:) = [];
            
            numberOfEpochs = size(epochDimensionIndices, 1); % update to reflect removed epochs.
            epochedTensorSize = [numberOfEpochs, epochLength, s(2:end)];
            epochedTensor = zeros(epochedTensorSize);
            
            for i=1:numberOfEpochs
                epochedTensor(i,1:epochLength,:) = tensor(epochDimensionIndices(i,:),:);
            end;
            
        end       
    end
end
