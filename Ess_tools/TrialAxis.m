classdef TrialAxis < InstanceAxis
    %  Trials from one or more data recordings (from one or more sessions or studies).    

    properties
        times % A numerical array with time (in seconds) for each trial relative to the start of its data recording.
        codes % maps to EEGLAB event code: EEG.event(x).type
        hedStrings % maps to EEG.event(x).usertags combined with EG.event(x).hedtags        
        dataRecordingIds % a cell array with ids of the data recordings for trials, one id for each trial. 
        % eventContext
    end;
    methods
        function obj =  TrialAxis(varargin)
            obj = obj@InstanceAxis;
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
            
            obj.typeLabel = 'trial';
            obj.perElementProperties = [obj.perElementProperties {'times' 'codes' 'hedStrings' 'dataRecordingIds'}];


            inputOptions = arg_define(varargin, ...
                arg('length', [], [0 Inf],'Number of trials. Optional as it will otherwise deduced from other inputs.'),...
                arg('times', [], [],'A numerical array with time. In seconds for each trial relative to the start of its data recording.'),...
                arg('cells', {}, {},'A cell array with information for each "instance" element.'),...
                arg('codes', {}, {},'A cell array with trial event codes.', 'type', 'cellstr'),...
                arg('hedStrings', {}, {},'A cell array with trial event HED strings. Each HED string is associatd with one trial', 'type', 'cellstr')...
                );
            
            
            if ~isempty(inputOptions.times) && ~isempty(inputOptions.cells) && length(inputOptions.cells) ~= inputOptions.times
                error('If both "times" and "cells" are provided, they need to have the same length.');
            end;
            
            % place empty elements for instances, code and hed strings. 
            if isempty(inputOptions.cells)
                inputOptions.cells = cell(length(inputOptions.times), 1);
            end;                        
            
            if isempty(inputOptions.codes)
                for i=1:length(inputOptions.times)
                    inputOptions.codes{i} = '';
                end;
            end;
            
            if isempty(inputOptions.dataRecordingIds)
                for i=1:length(inputOptions.times)
                    inputOptions.dataRecordingIds{i} = '';
                end;
            end;            
            
            if isempty(inputOptions.hedStrings)
                for i=1:length(inputOptions.times)
                    inputOptions.hedStrings{i} = '';
                end;
            end;
            
            % try to extract times from 'time' field of instances
            if isempty(inputOptions.times) 
                obj.times = zeros(length(inputOptions.cells), 1);
                for i=1:length(inputOptions.cells)
                    if isfield(inputOptions.cells{i}, 'time') && ~isempty(inputOptions.cells{i}.time)
                        obj.times(i) = inputOptions.cells{i}.time;
                    else
                        error('Failed to extract "times" from "time" field of "instances"');
                    end;
                end;
            end;
            
            obj.cells = inputOptions.cells(:);
            obj.times = inputOptions.times(:);
            obj.codes = inputOptions.codes(:);
            obj.hedStrings = inputOptions.hedStrings(:);
            check_monotonic(obj.times, 'times');
        end            
        
        function matchVector = getHEDMatch(obj, queryHEDString)
            % matchVector = getHEDMatch(obj, queryHEDString)

            [uniqueHedStrings, dummy, ids]= unique(obj.hedStrings);
            matchVector = false(length(obj.hedStrings), 1);
            for i=1:length(uniqueHedStrings)
                events.usertags = uniqueHedStrings{i};
                matchVector(ids == i) = findTagMatchEvents(events, queryHEDString);
            end;

        end;
        
        function idMask = parseRange(obj, rangeCell)
            switch  rangeCell{1}
                case'range' % the value for range should be in the form of [min max]
                    idMask = obj.times >= rangeCell{2}(1) & obj.times <= rangeCell{2}(2);
                case 'match' % to be used as {'trial' 'match' '[HED string]'}
                    idMask = getHEDMatch(obj, rangeCell{2});
                otherwise
                    error('Range string not recognized');
            end
        end;
    end;
end