classdef TrialAverage < Block
    properties
        featureType
    end;
    
    methods
        function obj = TrialAverage(varargin)
            obj = obj@Block;
            obj = obj.defineAsSubType('TrialAverage');
            obj = obj.setId;
            
            if nargin > 0
                if isa(varargin{1}, 'Block')
                    trialBlock = varargin{1};
                    
                    obj.axes{1} = TrialGroupAxis('groups', {trialBlock.trial});
                    obj.axes{2} = FeatureAxis('names', {'mean', 'standard deviation', 'standard deviation of mean', 'median', 'median absolute deviation'});

                    nonTrialAxisLabels = {};
                    axesLengths = [length(obj.axes{1}) length(obj.axes{2})];
                    for i=1:length(trialBlock.axes)
                        if strcmp(trialBlock.axes{i}.typeLabel, 'trial')
                            numberOfTrials = length(trialBlock.axes{i});
                        else
                            nonTrialAxisLabels{end+1} = trialBlock.axes{i}.typeLabel;
                            obj.axes{end+1} = trialBlock.axes{i};
                            axesLengths(end+1) = length(trialBlock.axes{i});
                        end;
                    end
                    
                    obj.tensor = zeros(axesLengths);
                    
                    obj.tensor(1, 1,:) = vec(mean(trialBlock.index('trial', nonTrialAxisLabels{:})));
                    obj.tensor(1, 2,:) = vec(std(trialBlock.index('trial', nonTrialAxisLabels{:})));
                    obj.tensor(1, 3,:) = obj.tensor(1, 2,:) / sqrt(length(trialBlock.trial));
                    m = median(trialBlock.index('trial', nonTrialAxisLabels{:}));
                    obj.tensor(1, 4,:) = vec(m);
                    obj.tensor(1, 5,:) = vec(median(abs(bsxfun(@minus, trialBlock.index('trial', nonTrialAxisLabels{:}), m))));
                    obj.featureType = trialBlock.type;
                end;
            end;
        end
        
        function obj = plot(obj, varargin)
            %             inputOptions = arg_define(varargin, ...
            %                 arg('channelIndices',[],[],'EEG channel indices to use. If empty and no "channellabels" is provided then all channels will be selected. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
            %                 arg('channellabels',[],[],'EEG channel labels to use. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
            %                 arg('timeRange',[-2 2],[],'Time range [before after] to include in the epoch. This is in seconds.'), ...
            %                 arg('lowpass', 0.5,[0 Inf],'Low-pass EEG at this frequency. Use empty to skip'), ...
            %                 arg('highpass', 20,[0 Inf],'High-pass EEG at this frequency. Leave empty to skip.'), ...
            %                 arg('maxChannels', Inf,[1 Inf],'Maximum number of channels to use. A uniform subset of channels will be used if this value is less than the number of channels in EEG.'), ...
            %                 arg_sub('select',{},@EpochedFeature.getTrialTimesFromEEGstructure, 'A struct argument. Arguments are as in myotherfunction(), can be assigned as a cell array of name-value pairs or structs.'));
            %
            
            numberOfChannels = length(obj.getAxis('channel'));
            
             numberOfplots = min(numberOfChannels, 3);
                
                switch numberOfplots
                    case 1
                        rowsColumns = [1 1];
                    case 2
                        rowsColumns = [2 1];
                    case 3
                        rowsColumns = [3 1];
                    case 4
                        rowsColumns = [2 2];
                    case 5
                        rowsColumns = [2 3];
                    case 6
                        rowsColumns = [2 3];
                    otherwise
                        rowsColumns = [3 3];
                end;
                            
            if strfind(obj.featureType, 'ess:Entity/Block/EpochedFeature/EpochedTemporalFeature')
                
                relativeSignificance = mean(abs(obj.index({'feature' 'name' 'mean'}, 'channel', 'time')) ./ obj.index({'feature' 'name' 'standard deviation'}, 'channel', 'time'), 3);
                
                [dummy sortedChannelId] = sort(relativeSignificance, 'descend');                
               
                figure;
                for i=1:numberOfplots
                    subtightplot(rowsColumns(1), rowsColumns(2), i);                    

                    time = obj.getAxis('time');
                    line([min(time.times * 1000) max(time.times * 1000)],[0 0], 'LineStyle','-', 'Color', [0.5 0.5 0.5]);
                    channelId = sortedChannelId(i);
                    confplot_t(time.times * 1000, vec(obj.index({'feature' 'name' 'mean'}, {'channel', channelId}, 'time')), vec(obj.index({'feature' 'name' 'standard deviation'}, {'channel', channelId}, 'time')), obj.getAxis('trialGroup').getGroupNumberOfTrials(1), 0.05:0.01:0.499,@gray, true);
                    xlabel('Time (ms)');
                    legend(['Channel ' num2str(channelId)]);
                    line([0 0], get(gca, 'ylim'), 'LineStyle','--', 'Color', [0.5 0.5 0.5]);
                end;
            elseif  strfind(obj.featureType, 'ess:Entity/Block/EpochedFeature/EpochedTimeFrequencyFeature')
                relativeSignificance = mean(abs(obj.index({'feature' 'name' 'mean'}, 'channel', ':')) ./ obj.index({'feature' 'name' 'standard deviation'}, 'channel', ':'), 3);
                
                [dummy, sortedChannelId] = sort(relativeSignificance, 'descend');
                
                figure;
                f = obj.getAxis('frequency');
                t = obj.getAxis('time');
                for i=1:numberOfplots
                    subtightplot(rowsColumns(1), rowsColumns(2), i, 0.1);
                    imagesclogy(t.times, f.frequencies, squeeze(obj.index({'feature' 'name' 'mean'}, {'channel', 1}, 'frequency', 'time')));
                end;
            end;
        end;
    end
end