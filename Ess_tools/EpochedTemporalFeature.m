classdef EpochedTemporalFeature < EpochedFeature
    properties
    end;
    
    methods
        function obj = EpochedTemporalFeature
            obj = obj@EpochedFeature;
            obj.type = 'ess:EpochedFeature/EpochedTemporalFeature'; % use / to append childen types here.
            obj = obj.setId;
        end
        
        function obj = epochChannels(obj, EEG, varargin)
            inputOptions = arg_define(varargin, ...
                arg('channelIndices',[],[],'EEG channel indices to use.'), ...
                arg('channellabels',[],[],'EEG channel labels to use.'), ...
                arg('timeRange',[-2 2],[],'Time range [before after] to include in the epoch. This is in seconds.'), ...
                arg_sub('select',{},@EpochedFeature.getTrialTimesFromEEGstructure, 'A struct argument. Arguments are as in myotherfunction(), can be assigned as a cell array of name-value pairs or structs.'));
            
            inputOptions.select.EEG = EEG;
            [trialFrames, trialTimes, trialHEDStrings, trialEventTypes] =  EpochedFeature.getTrialTimesFromEEGstructure(inputOptions.select);
            
            assert(inputOptions.timeRange(2) > inputOptions.timeRange(1), 'The "timeRange" is invalid');
   
            if inputOptions.timeRange(1) < 0
                numberOfIndicesBefore = -inputOptions.timeRange(1) * EEG.srate;
                numberOfIndicesAfter =  inputOptions.timeRange(2) * EEG.srate;
                epochTimes = trialFrames;
            else % the start of the range is afer the event, need to swicth epoch time to suite the way epochTensor() works.
                epochTimes = epochTimes + (inputOptions.timeRange(1) * EEG.srate);
                numberOfIndicesBefore = 0;
                numberOfIndicesAfter = (inputOptions.timeRange(2) - inputOptions.timeRange(1)) * EEG.srate;
            end;
                        
            
            obj.tensor = EpochedFeature.epochTensor(EEG.data', epochTimes, numberOfIndicesBefore, numberOfIndicesAfter);

            obj.axes{1} = TrialAxis('times', trialTimes, 'hedStrings', trialHEDStrings, 'codes', trialEventTypes);
            obj.axes{2} = TimeAxis('initTime', inputOptions.timeRange(1), 'nominalRate', EEG.srate, 'numberOfTimes', size(obj.tensor, 2));
            obj.axes{3} = ChannelAxis('chanlocs', EEG.chanlocs(inputOptions.channelIndices));! continue here, must infer channelIndices above by default...
        end
    end
end