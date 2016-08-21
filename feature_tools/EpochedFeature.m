% Copyright © Qusp 2016. All Rights Reserved.
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
            
            
            if inputOptions.uniformOverTime && ismember('time', obj.getAxesInfo)
                nonTimeOrTrialAxisLabels = setdiff(obj.getAxesInfo, {'time', 'trial'});
                indexArguments = [nonTimeOrTrialAxisLabels {':'}];
                
                dims = 1:(ndims(obj.tensor)-1); % -1 since we have combined trial and time
                timeAndTrialByfeatures = permute(obj.index(indexArguments{:}), [dims(end), dims(1:(end-1))]);
                medianTimeFeatures = median_lowmem(timeAndTrialByfeatures);
                centeredTimeFeatures = bsxfun(@minus, timeAndTrialByfeatures, medianTimeFeatures);
                clear timeAndTrialByfeatures;                
                robustStdTimeFeatures = 1.4826 * median_lowmem(abs(centeredTimeFeatures));               
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
        
        function obj = epochESSContainer(obj, studyContainer, filePart, combineEpochs, skipComputed, varargin)
            % obj = epochESSContainer(obj, containerObj, filePart, combineEpochs, epochingParams)
            %
            % studyContainer    can be a string (ESS study container folder) or object (currently only level 2)
            % filePart         if provided, intermediate results are saved in
            %                   file starting with 'filePart' and numbered consequatively, e.g. filePart1.mat,
            %                   filePart2.mat..
            % combineEpochs    by default is True and combines epochs across data recordings into
            %                  the object. If False then epochs for data recorings are saved as
            %                  file but not combined. This is useful when wanting to e.g. keep all
            %                  channels sinc eotherwise only the channels overlaping with the
            %                  first recording are selected for subsequent recordings.
            % epochingParams   a cell array with parameters to be passed on to 'epochChannels'
            %                  functions.
            % skipComputed     skip the computation if file with the same output name already exists (useful for resuming after an error) 
            
            if ischar(studyContainer)
                studyContainer = levelStudy(studyContainer);

               
%                 try
%                     studyContainer = level2Study(studyContainer);
%                 catch
%                     studyContainer = levelDerivedStudy(studyContainer);
%                 end;
            end;
            
            if nargin < 4
                combineEpochs = true;
            end
            
            if nargin < 5
                skipComputed = true;
            end;
            
            [filename, dataRecordingUuid, taskLabel, sessionNumber, level2DataRecordingNumber, subjectInfo, level1DataRecording] = studyContainer.getFilename;
            
            for i=1:length(filename)
                if isprop(studyContainer, 'studyLevelDerivedFiles') ||  strcmpi(studyContainer.studyLevel2Files.studyLevel2File(level2DataRecordingNumber(i)).dataQuality, 'Good') % only use good quality data
                    outputFile = [filePart num2str(i) '.mat'];
                    if isempty(filePart) || ~(exist(outputFile, 'file') && skipComputed)
                        
                        [path, name, ext] = fileparts(filename{i});
                        EEG = pop_loadset([name, ext], path);
                        
                        % only for NCTU
%                         if isempty(EEG.chanlocs(1).type) && isempty(EEG.chanlocs(10).type)
%                             for k=1:length(EEG.chanlocs)
%                                 if isempty(EEG.chanlocs(k).type)
%                                     EEG.chanlocs(k).type= 'EEG';
%                                 end;
%                             end;
%                             pop_saveset(EEG, 'filepath', EEG.filepath, 'filename', EEG.filename);
%                         end;
                        
                        
                        % find the label naming system for the data recording
                        channelNamingSystem  = nan;
                                                                     
                        if isprop(studyContainer, 'level1StudyObj')
                            level1StudyObj = studyContainer.level1StudyObj;
                        else
                            level1StudyObj = getLevel1(studyContainer);
                        end
                        
                        for j=1:length(level1StudyObj.recordingParameterSet)
                            if strcmp(level1StudyObj.recordingParameterSet(j).recordingParameterSetLabel, level1DataRecording(i).recordingParameterSetLabel)
                                for k=1:length(level1StudyObj.recordingParameterSet(j).modality)
                                    if strcmpi(level1StudyObj.recordingParameterSet(j).modality(k).type, 'EEG')
                                        channelNamingSystem = level1StudyObj.recordingParameterSet(j).modality(k).channelLocationType;
                                    end;
                                end;
                            end;
                        end
                        
                        if isnan(channelNamingSystem)
                            error('Channel naming system could not be found in ESS container');
                        end;
                        
                        newObj = obj.setAsNewlyCreated;
                        if i == 1 || ~combineEpochs
                            newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, 'channelNamingSystem', channelNamingSystem, varargin{:});
                        else % use the same channel set (by labels)
                            channelAxis = obj.channel;
                            newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, 'channelLabels', channelAxis.labels, 'channelNamingSystem', channelNamingSystem,varargin{:} );
                        end
                        clear EEG ALLEEG;
                        newObj = newObj.removeNoisyEpochs;
                        
                        if ~isempty(filePart)
                            save(outputFile, 'newObj', '-v7.3');
                        end;
                    else
                        fprintf('Skipping %s since it was already computed.\n',  filename{i});
                        if combineEpochs
                            load(filePart);
                        end;
                    end;
                    
                    if combineEpochs
                        obj = [obj newObj];
                    end;
                end;
            end;
        end;
        
        function obj = epochFileList(obj, varargin)
            % obj = epochFileList(obj, ['key', value pairs])
            %
            % Keys:
            % filenames           a cell array of strings with the 
            % filePart            if provided, intermediate results are saved in
            %                      file starting with 'filePart' and numbered consequatively, e.g. filePart1.mat,  filePart2.mat..
            % combineEpochs      by default is True and combines epochs across data recordings into
            %                    the object. If False then epochs for data recorings are saved as
            %                    file but not combined. This is useful when wanting to e.g. keep all
            %                    channels sinc eotherwise only the channels overlaping with the
            %                    first recording are selected for subsequent recordings.
            % epochingParams     a cell array with parameters to be passed on to 'epochChannels'
            %                    functions.
            % skipComputed       skip the computation if file with the same output name already exists (useful for resuming after an error) 
            % channelNamingSystem   EEG channel location naming system. This is a cell string array and MUST be provided. If only a single string is provided it will be assumed for all files.
            
            
            % places these directly into workspace
            arg_define(varargin, ...
                arg('filenames', {},[],'a cell array of filename strings. if both ''filenames'' and ''folder'' are provided the concatenation will be processed.', 'type', 'cellstr'), ...
                arg('dataRecordingUuid', {},[],'a cell array of data recording uuids. Should be the same length as ''filenames''.', 'type', 'cellstr'), ...               
                arg('folder', '', [],'Top directory of files to be epoched. All .set file immediately under this directory will be processed.', 'type', 'char'),...
                arg('filePart', '', [],'For data recording epoch files. If provided, intermediate results are saved in file starting with ''filePart'' and numbered consequatively, e.g. filePart1.mat, filePart2.mat..'),...
                arg('combineEpochs', true, [false true],'Acceptable data quality values. A cell array containing a combination of acceptable data quality values (Good, Suspect or Unusbale)', 'type', 'logical'), ...
                arg('skipComputed', true,[],'Skip alread-computed recordings. Skip the computation if file with the same output name already exists (useful for resuming after an error).', 'type', 'logical'), ...
                arg('channelNamingSystem', '', '','EEG channel location naming system. This is a cell string array and MUST be provided. If only a single string is provided it will be assumed for all files.', 'type', 'cellstr'), ...
                arg('epoching', {}, {},'Epoching parameters. This is a cell containing key, value pairs for the epoching function.') ...
            );                                   
            
            if isempty(filenames) && isempty(folder)
                error('Either ''filenames'' or ''folder'' should be provided');
            end;                     
           
            if isempty(channelNamingSystem)
                error('Channel naming system must be provided');
            elseif ischar(channelNamingSystem)
                channelNamingSystem = {channelNamingSystem};
            end
            
            if ~isempty(folder)
                d = dir(folder);
                for i=1:length(d)
                    if ~d(i).isdir && length(d(i).name) > 4 && strcmpi(d(i).name(end-3:end), '.set')
                        filenames{end+1} = [folder filesep d(i).name];
                    end;
                end
            end;
            
            if length(channelNamingSystem) == 1
                for i=2:length(filenames)
                    channelNamingSystem{i} = channelNamingSystem{1};
                end
            end;
            
            for i=1:length(filenames)
                    outputFile = [filePart num2str(i) '.mat'];
                    if isempty(filePart) || ~(exist(outputFile, 'file') && skipComputed)
                        
                        [path, name, ext] = fileparts(filenames{i});
                        EEG = pop_loadset([name, ext], path);
                        
                        % create data recording uuids from EEG data if not provided.
                        if length(dataRecordingUuid) < i 
                            dataRecordingUuid{i} = ['md5_from_EEG_variable_' hlp_cryptohash(EEG)];
                        end
                        
                        % only for NCTU
%                         if isempty(EEG.chanlocs(1).type) && isempty(EEG.chanlocs(10).type)
%                             for k=1:length(EEG.chanlocs)
%                                 if isempty(EEG.chanlocs(k).type)
%                                     EEG.chanlocs(k).type= 'EEG';
%                                 end;
%                             end;
%                             pop_saveset(EEG, 'filepath', EEG.filepath, 'filename', EEG.filename);
%                         end;
                        
                        
                        newObj = obj.setAsNewlyCreated;
                        if i == 1 || ~combineEpochs
                            newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, 'channelNamingSystem', channelNamingSystem{i}, epoching{:});
                        else % use the same channel set (by labels)
                            channelAxis = obj.channel;
                            newObj = newObj.epochChannels(EEG, 'dataRecordingId', dataRecordingUuid{i}, 'channelLabels', channelAxis.labels, 'channelNamingSystem', channelNamingSystem{i}, epoching{:} );
                        end
                        clear EEG ALLEEG;
                        newObj = newObj.removeNoisyEpochs;
                        
                        if ~isempty(filePart)
                            save(outputFile, 'newObj', '-v7.3');
                        end;
                    else
                        fprintf('Skipping %s since it was already computed.\n',  filenames{i});
                        if combineEpochs
                            load(filePart);
                        end;
                    end;
                    
                    if combineEpochs
                        obj = [obj newObj];
                    end;
            end;
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
                arg('numberOfRandomTrials', 500,[0 Inf],'How many random trials to create. Random trials are not time-locked to any event and can be used for statistical null comparison. These trials have an empty event type and the HED string ''Event/Category/Miscellaneous/Random, Event/Label/Random, Event/Description/Randomly created event'''),...
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
    end
end
