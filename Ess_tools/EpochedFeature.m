classdef EpochedFeature < Entity
    properties
        tensor % a numerical array with any number of dimensions
        axis % a cell array containing axis information for the tensor
    end;
    methods
        function obj = EpochedFeature
            obj = obj@Entity;
            obj.type = 'ess:EpochedFeature'; % use / to append childen types here.
            obj = obj.setId;
        end
    end
    methods (Static)
        function [trialFrames, trialTimes, trialHEDStrings, trialEventTypes]= getTrialTimesFromEEGstructure(EEG, varargin)
            % [trialFrames, trialTimes, trialHEDStrings, trialEventTypes]= getTrialTimesFromEEGstructure(EEG, varargin)
            % trialTimes is
            
            inputOptions = arg_define(varargin, ...
                arg('hedStringsCell', [],[],'HED string to epoch on. Only events with HED strings that match to at least one of the items in this cell array of HED strings will be included in the returned trial times.', 'type', 'cellstr'), ...
                arg('eventTypes', [],[],'Event types to epoch on. Empty means all events ', 'type', 'cellstr'), ...
                arg('excludedEventTypes', {},[],'Events types to exclude', 'type', 'cellstr'), ...
                arg('maxSameTypeProximity', 0.5,[0 Inf],'How much to allow same-type event overlap. When two events have the same type or HED string are closer than this value (in seconds), only one of them will be included.')...
                );
            
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
                    % start removing events with highest overlap until no event has an ovrlap
                    eventIdToRemove = [];
                    while full(any(totalOverlap))
                        [dummy maxId] = max(totalOverlap);
                        %totalOverlap = totalOverlap - temporalOverlap(maxId,:);
                        afterRemovalTemporalOverlap(maxId,:) = 0;
                        afterRemovalTemporalOverlap(:,maxId) = 0;
                        totalOverlap = sum(afterRemovalTemporalOverlap);
                        eventIdToRemove = [eventIdToRemove maxId];
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
    end;
end
