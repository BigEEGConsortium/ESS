classdef EpochedFeature < Block
    properties
        % eventTimes % latencis of events from which epochs have been extracted,
        % relative to the start of their respective data recordings.
    end;
    methods
        function obj = EpochedFeature
            obj = obj@Block;
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
        end
        
        function [obj, epochIsClean, trialNoiseEstimate] = removeNoisyEpochs(obj, varargin)
            % [obj, cleanEpochIds, trialNoiseEstimate] = removeNoisyEpochs(obj, varargin)
            % Removes outlier trials, i.e. trials with  
            
            inputOptions = arg_define(varargin, ...
                arg('useAvaregZ', true, [false true],'Average Z values over feature. There are two methods for outlier detection implemented in this function: (1) average Z values over all trial features [this option] (2) Threshold the values to find individual outlier feature elements and calculate the ratio of outliers in each trial.', 'type', 'logical'),...
                arg('zthreshold', 3, [],'Max z-transformed feature value considered normal. Values with higher absolute Z are considered outliers.', 'type', 'denserealdouble'),...
                arg('maxOutlierRatio', 0.15, [],'Max ratio of outliers values for normal trials. Only applicable if useAvaregZ is set to False. Trials with higher ratio of outliers to normal values are considered outliers and removed.', 'type', 'denserealdouble'),...
                arg('uniformOverTime', true, [false true],'Combine time and trial axis before calculating Z statistics. Robust Z Statistics can be either calculated over Trials, or over a joint Time x Trials axis.  The combined method, when applicable, is recommended since it does not affect significance calculations.', 'type', 'logical')...                
            );
            
            
            if inputOptions.uniformOverTime && ismember('time', obj.axesTypeLabels)                
                nonTimeOrTrialAxisLabels = setdiff(obj.axesTypeLabels, {'time', 'trial'});
                indexArguments = [nonTimeOrTrialAxisLabels {':'}];
                
                dims = 1:(ndims(obj.tensor)-1); % -1 since we have combined trial and time
                timeAndTrialByfeatures = permute(obj.index(indexArguments{:}), [dims(end), dims(1:(end-1))]);
                medianTimeFeatures = median(timeAndTrialByfeatures);
                centeredTimeFeatures = bsxfun(@minus, timeAndTrialByfeatures, medianTimeFeatures);
                clear timeAndTrialByfeatures;
                robustStdTimeFeatures = 1.4826 * median(abs(centeredTimeFeatures));
                clear centeredTimeFeatures;
                
                medianTimeFeatures = permute(medianTimeFeatures, [dims(2:end) dims(1)]);
                robustStdTimeFeatures = permute(robustStdTimeFeatures, [dims(2:end) dims(1)]);
                
                % make sure of singeltn expanson on ending dimensions to save memory
                robustZFeatures =  bsxfun(@times, bsxfun(@minus, permute(obj.index('trial', 'time', :), [3, 1, 2]), medianTimeFeatures), 1./robustStdTimeFeatures);
                robustZFeatures = permute(robustZFeatures, [2 3 1]);
                robustZFeatures = robustZFeatures(:,:);                     
            else
                trialByFeature = obj.index ('trial', ':');
                medianFeatures = median(trialByFeature);
                centeredFeatures = bsxfun(@minus, trialByFeature, medianFeatures);
                clear medianFeatures trialByFeature;
                robustStdFeatures = 1.4826 * median(abs(centeredFeatures)); % median absolute deviation multiplied by a factor gives robust standard deviation
                robustZFeatures =  bsxfun(@times, centeredFeatures, 1./robustStdFeatures);
                clear robustStdFeatures;
            end;
            
            if inputOptions.useAvaregZ
                outlierFeature = mean(abs(robustZFeatures), 2);
                epochIsClean = outlierFeature < inputOptions.zthreshold;
                trialNoiseEstimate = outlierFeature;
            else
                outlierFeature = abs(robustZFeatures) > inputOptions.zthreshold; % both too negative and too positive
                averageOutlierRatio = nanmean(outlierFeature, 2);
                epochIsClean = averageOutlierRatio < inputOptions.maxOutlierRatio;
                trialNoiseEstimate = averageOutlierRatio;
                clear robustZFeatures outlierFeature;
            end;
            
            obj = obj.select('trial', find(epochIsClean));
            assert(obj.isValid, 'Result is not valid');
            fprintf('%d percent of trials (%d) were removed.\n', round(100*mean(~epochIsClean)), sum(~epochIsClean));
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
                arg('numberOfRandomTrials', 0,[0 Inf],'How many random trials to create. Random trials are not time-locked to any event and can be used for statistical null comparison. These trials have an empty event type and the HED string ''Event/Category/Miscellaneous/Random, Event/Label/Random, Event/Description/Randomly created event'''),...
                arg('maxSameTypeProximity', 0.5,[0 Inf],'How much to allow same-type event overlap. When two events have the same type or HED string are closer than this value (in seconds), only one of them will be included.'),...
                arg('maxSameTypeCount', Inf,[1 Inf],'How many same-time events are allowed. Events with highest overlap with the same type are deleted first.')...
                );
            
            EEG = inputOptions.EEG;
            trialFrames = vec([EEG.event(:).latency]);
            trialTimes = vec((trialFrames-1)/ EEG.srate);
            trialHEDStrings = vec({EEG.event(:).usertags});
            trialEventTypes = vec({EEG.event(:).type});
            
            
            if ~isempty(inputOptions.eventTypes)
                id = ismember(trialEventTypes, inputOptions.eventTypes);
                
                trialFrames = trialFrames(id);
                trialTimes = trialTimes(id);
                trialHEDStrings = trialHEDStrings(id);
                trialEventTypes = trialEventTypes(id);
            end;                                             
            
            % remove events of the same type that have too much overlap with their own kind
            if inputOptions.maxSameTypeProximity < max(trialTimes) - min(trialTimes)
                allEventIdsToRemove = [];
                [uniqueEventTypes, dummy, id]= unique(trialEventTypes);
                clear dummy;
                for i=1:length(uniqueEventTypes)
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
                        fprintf('- Removed %d of the original %d (%d percent) events of \n   type "%s" due to excessive overlap (%d event left).\n', length(eventIdToRemove), n, round(100 * length(eventIdToRemove) / n), uniqueEventTypes{i}, n-length(eventIdToRemove));
                    end;
                    
                    allEventIdsToRemove = cat(1, allEventIdsToRemove(:), eventSubset(eventIdToRemove));
                    clear afterRemovalTemporalOverlap totalOverlap temporalOverlap;
                end;
                
                trialFrames(allEventIdsToRemove) = [];
                trialTimes(allEventIdsToRemove) = [];
                trialHEDStrings(allEventIdsToRemove) = [];
                trialEventTypes(allEventIdsToRemove) = [];
                
            end;
            
            % add random events
            randomLatency = [];
            maxLatency = max((size(EEG.data, 2)-1)/EEG.srate, EEG.xmax);
            for i=1:inputOptions.numberOfRandomTrials
                counter = 0;
                found = false;
                while ~isempty(found) && (~found && counter < 100000)
                    newRandomLatency = rand * maxLatency;
                    found = min(abs(randomLatency - newRandomLatency)) > inputOptions.maxSameTypeProximity;
                    counter = counter + 1;
                end;
                if counter < 100000
                    randomLatency = cat(1, randomLatency, newRandomLatency);
                end;
            end;    
            
            trialFrames = [trialFrames; 1+(randomLatency*EEG.srate)];
            trialTimes = [trialTimes; randomLatency];
            trialHEDStrings((end+1):(end+length(randomLatency))) = {'Event/Category/Miscellaneous/Random, Event/Label/Random, Event/Description/Randomly created event'};
            
            randomEventCandidateNames = {'random' 'random_event' 'random event' ''};
            for i=1:length(randomEventCandidateNames)
                if ~any(strcmp(trialEventTypes, randomEventCandidateNames{i}))
                    trialEventTypes((end+1):(end+length(randomLatency))) = randomEventCandidateNames(i);
                    fprintf('%d random events added and assignd the type ''%s''.\n', length(randomLatency), randomEventCandidateNames{i});
                    break;
                end;
            end;
                        
        end;
        
        function [epochedTensor, acceptedEpochs]= epochTensor(tensor, indices, numberOfIndicesBefore, numberOfIndicesAfter)
            % [epochedTensor acceptedEpochs]= epochTensor(tensor, times, numberOfFramesBefore, numberOfFramesAfter)
            %
            % Extracts epochs from the *first dimension* of input tensor at given indices
            % with provided "number of indices before" (numberOfIndicesBefore)
            % and "number of indices aftr" (numberOfIndicesAfter).
            %
            % The output tensor will have size of the number of epochs as its first,
            % dimension and the indices associated with the epoch dimension
            % (number of epochs before + 1 + number of epochs after) as its second dimension.
            % all other dimensions will have the same order and size as the
            % remaining dimensions (after the first) of the input tensor.
            % any epoch that violates the boundaries is automatically removed so the number of
            % output epochs may be less than length(times).
            %
            % acceptedEpochs contains the ids of epochs that were not 'out of bound' 
            % , i.e. so close to the start or the end of the signal that epoching was impossible.
            %
            % Input example:
            %   tensor = zeros(200, 30, 40)
            %   indices = [5:10:100];
            %   numberOfIndicesBefore = 2;
            %   numberOfIndicesAfter = 3;
            % Output:
            % size(epochedTensor) = [10 6 30 40]
            
            s = size(tensor);
            indices = round(indices);
            epochLength = numberOfIndicesBefore + 1 + numberOfIndicesAfter;
            numberOfEpochs = length(indices);
            
            epochDimensionIndices  = repmat(indices(:), [1 epochLength]) + repmat(-numberOfIndicesBefore:numberOfIndicesAfter, [numberOfEpochs 1]);
            outOfBoundEpochs = any(epochDimensionIndices < 1, 2) | any(epochDimensionIndices > size(tensor, 1), 2);
            epochDimensionIndices(outOfBoundEpochs,:) = [];
            acceptedEpochs = setdiff(1:numberOfEpochs, find(outOfBoundEpochs));
            
            numberOfEpochs = size(epochDimensionIndices, 1); % update to reflect removed epochs.
            epochedTensorSize = [numberOfEpochs, epochLength, s(2:end)];
            epochedTensor = zeros(epochedTensorSize);
            
            for i=1:numberOfEpochs
                epochedTensor(i,1:epochLength,:) = tensor(epochDimensionIndices(i,:),:);
            end;
            
        end
        
        function obj = epochESSContainer(obj, containerObj, filePart, varargin)
            % obj = epochESSContainer(obj, containerObj, filePart, epochingParams)
            % containerObj can be a string (container folder) or object (currently only level 2)
            % if 'filePart' is provided, intermediate results are saved in
            % file starting with 'filePart' and numbered consequatively, e.g. filePart1.mat,
            % filePart2.mat..
            % epochingParams: a cell array with parameters to be passed on to 'epochChannels'
            % functions.
            
            if ischar(containerObj)
                containerObj = level2Study(containerObj);
            end;
            
            [filename, dataRecordingUuid, taskLabel, sessionNumber, level2DataRecordingNumber] = containerObj.getFilename;
            obj = EpochedTemporalFeature;
            for i=1:length(filename)
                if strcmpi(containerObj.studyLevel2Files.studyLevel2File(level2DataRecordingNumber(i)).dataQuality, 'Good') % only use good quality data
                    [path, name, ext] = fileparts(filename{i});
                    EEG = pop_loadset([name, ext], path);
                    newObj = EpochedTemporalFeature;
                    if i == 1
                        newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, varargin{:});
                    else % use the same channel (by label)
                        channelAxis = obj.channel;
                        newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, 'channelLabels', channelAxis.labels, varargin{:} );
                    end
                    clear EEG ALLEEG;
                    newObj = newObj.removeNoisyEpochs;
                    if ~isempty(filePart)
                        save([filePart num2str(i) '.mat'], 'newObj');
                    end;
                    obj = [obj newObj];
                end;
            end;
        end;
        
    end
end
