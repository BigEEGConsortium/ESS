classdef EpochedTimeFrequencyFeature < EpochedFeature
    properties
       % baselineAmplitude % a Block object with mean, median, std, medium abs. deviation, etc of
                           % baseline values
    end;
    
    methods
        function obj = EpochedTimeFrequencyFeature
            obj = obj@EpochedFeature;
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
        end
        
        function obj = epochChannels(obj, EEG, varargin)
            inputOptions = arg_define(varargin, ...
                arg('channelIndices',[],[],'EEG channel indices to use. If empty and no "channellabels" is provided then all channels will be selected. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
                arg('channellabels',[],[],'EEG channel labels to use. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
                arg('timeRange',[-2 2],[],'Time range [before after] to include in the epoch. This is in seconds.'), ...               
                arg('frequencyRange', [2 30],[0 Inf],'Frequency range.'), ...
                arg('numberOfFrequencies', 25,[0 Inf],'Number of frequency bins.'), ...
                arg('temporalSampling', 30,[0 Inf], 'Number of samples kept per second. Time-frequency data is subsampled (time-locked to each event) based on this value.'), ...
                arg('robustBaseline', false, [],'Use a robust baseline. Use Median instead of mean and estimate standard deviation using Median Absolute Deviation.', 'type', 'logical'), ...
                arg('normalizeByVariance', false, [],'Divide values for each frequency by their standard deviation. This effectively performs a type of z transform since the mean (or median is robust option selected) is always removed.', 'type', 'logical'), ...
                arg('maxChannels', Inf,[1 Inf],'Maximum number of channels to use. A uniform subset of channels will be used if this value is less than the number of channels in EEG.'), ...
                arg_sub('select',{},@EpochedFeature.getTrialTimesFromEEGstructure, 'A struct argument. Arguments are as in myotherfunction(), can be assigned as a cell array of name-value pairs or structs.'));
            
            assert(inputOptions.timeRange(2) > inputOptions.timeRange(1), 'The "timeRange" is invalid');                    
            
            inputOptions.select.EEG = EEG;
            [trialFrames, trialTimes, trialHEDStrings, trialEventTypes] =  EpochedFeature.getTrialTimesFromEEGstructure(inputOptions.select);
            
            if isempty(inputOptions.channelIndices)
                chanlocIds = 1:length(EEG.chanlocs);
            else
                chanlocIds = inputOptions.channelIndices;
            end;
            
            for i=1:length(chanlocIds)
                if strcmpi(EEG.chanlocs(chanlocIds(i)).type, 'EEG') && (isempty(inputOptions.channellabels) || ismember(EEG.chanlocs(chanlocIds(i)).labels, inputOptions.channellabels))
                    inputOptions.channelIndices = [inputOptions.channelIndices chanlocIds(i)];
                end;
            end;
            
            EEG = pop_select(EEG, 'channel', inputOptions.channelIndices);
                            
            if size(EEG.data, 1) > inputOptions.maxChannels
                subset = loc_subsets(EEG.chanlocs, inputOptions.maxChannels);
                EEG = pop_select(EEG, 'channel', subset{1});
            end;                      
            
            
            if inputOptions.timeRange(1) < 0
                numberOfIndicesBefore = -inputOptions.timeRange(1) * EEG.srate;
                numberOfIndicesAfter =  inputOptions.timeRange(2) * EEG.srate;
                epochTimes = trialFrames;
            else % the start of the range is afer the event, need to swicth epoch time to suite the way epochTensor() works.
                epochTimes = epochTimes + (inputOptions.timeRange(1) * EEG.srate);
                numberOfIndicesBefore = 0;
                numberOfIndicesAfter = (inputOptions.timeRange(2) - inputOptions.timeRange(1)) * EEG.srate;
            end;
            
            % calculate subsample ids anchored to 0 or minimum range
            frameTimes = (-numberOfIndicesBefore:numberOfIndicesAfter) / EEG.srate;
            anchorTime = max(0, inputOptions.timeRange(1)); % time that will always be included and the sampling is started from it
            sampleStep = 1/inputOptions.temporalSampling;
            sampleTimes = unique([min(frameTimes):sampleStep:anchorTime anchorTime:sampleStep:max(frameTimes)], 'sorted');
            sampleIds = zeros(length(sampleTimes), 1);
            for i=1:length(sampleTimes)
                [dummy sampleIds(i)] = min(abs(frameTimes - sampleTimes(i)));
            end;
            
            wname = 'cmor1-1.5';
            T = 1/EEG.srate;
            [scales, freqs] = freq2scales(inputOptions.frequencyRange(1), inputOptions.frequencyRange(2), inputOptions.numberOfFrequencies, wname, T);
            
            % frequencies coming out are from highest to lowest, need to sort them
            [dummy freqSortIds] = sort(freqs, 'ascend');
            for i=1:size(EEG.data, 1)
                tfdecomposition = cwt(EEG.data(i,:)',scales, wname);
                tfdecomposition = log(abs(tfdecomposition));
                
                if inputOptions.robustBaseline
                    baselineMean = median(tfdecomposition, 2);
                    tfdecomposition = bsxfun(@minus, tfdecomposition, baselineMean);
                    baselineStd = median(abs(tfdecomposition), 2) * 1.4826;
                else
                    baselineMean = mean(tfdecomposition, 2);
                    baselineStd = std(tfdecomposition, 0, 2);
                    tfdecomposition = bsxfun(@minus, tfdecomposition, baselineMean);
                end;                                
                
                if inputOptions.normalizeByVariance
                    tfdecomposition = bsxfun(@times, tfdecomposition, 1./baselineStd);
                end;
                
                tfdecomposition = EpochedFeature.epochTensor(tfdecomposition', epochTimes, numberOfIndicesBefore, numberOfIndicesAfter);
                
                if i == 1
                    obj.tensor = zeros([size(EEG.data,1) size(tfdecomposition, 1) length(sampleIds) size(tfdecomposition,3)]);
                end;
                
                obj.tensor(i,:,:,:) = tfdecomposition(:,sampleIds, freqSortIds); % channels, trials, times x frequencies
                clear tfdecomposition
            end;

            obj.axes{1} = ChannelAxis('chanlocs', EEG.chanlocs);
            obj.axes{2} = TrialAxis('times', trialTimes, 'hedStrings', trialHEDStrings, 'codes', trialEventTypes);
            obj.axes{3} = TimeAxis('times', frameTimes(sampleIds), 'nominalRate', inputOptions.temporalSampling);
            obj.axes{4} = FrequencyAxis('frequencies', freqs(freqSortIds));

            
            assert(obj.isValid, 'Result is not valid');
        end
    end
end