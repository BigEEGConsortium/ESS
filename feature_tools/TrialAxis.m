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
                arg('payloads', {}, {},'A cell array with information for each "instance" element.'),...
                arg('codes', {}, {},'A cell array with trial event codes.', 'type', 'cellstr'),...
                arg('dataRecordingIds', {}, {},'A cell array with data recording ids associated wiith trial.', 'type', 'cellstr'),...
                arg('customLabel', [], [],'A string indicating a custom label for the axis. This label can be used in extended indexing, e.g. obj(''customlabel_1'',:).'),...                
                arg('hedStrings', {}, {},'A cell array with trial event HED strings. Each HED string is associatd with one trial', 'type', 'cellstr')...
                );
            
            
            if ~isempty(inputOptions.times) && ~isempty(inputOptions.payloads) && length(inputOptions.payloads) ~= inputOptions.times
                error('If both "times" and "payloads" are provided, they need to have the same length.');
            end;
            
            % place empty elements for instances, code and hed strings. 
            if isempty(inputOptions.payloads)
                inputOptions.payloads = cell(length(inputOptions.times), 1);
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
                obj.times = zeros(length(inputOptions.payloads), 1);
                for i=1:length(inputOptions.payloads)
                    if isfield(inputOptions.payloads{i}, 'time') && ~isempty(inputOptions.payloads{i}.time)
                        obj.times(i) = inputOptions.payloads{i}.time;
                    else
                        error('Failed to extract "times" from "time" field of "instances"');
                    end;
                end;
            end;
            
            % fix legacy Action/Type tag     
            if any(cell2mat(strfind(inputOptions.hedStrings, 'Action/Type')))
                inputOptions.hedStrings = strrep(inputOptions.hedStrings, 'Action/Type/', 'Action/');
                fprintf('Legacy ''Action/Type'' tag detected and fixed.\n');
            end;
            
            
            obj.payloads = inputOptions.payloads(:);
            obj.times = inputOptions.times(:);
            obj.codes = inputOptions.codes(:);
            obj.hedStrings = inputOptions.hedStrings(:);
            obj.dataRecordingIds = inputOptions.dataRecordingIds(:);  
            obj.customLabel = inputOptions.customLabel;
            check_monotonic(obj.times, 'times');
        end            
        
        function matchVector = getHEDMatch(obj, queryHEDString)
            % matchVector = getHEDMatch(obj, queryHEDString)

            [uniqueHedStrings, dummy, ids]= unique(obj.hedStrings);
            matchVector = false(length(obj.hedStrings), 1);
            for i=1:length(uniqueHedStrings)
                EEG.event.usertags = uniqueHedStrings{i};
                matchVector(ids == i) = ~isempty(findTagMatchEvents(EEG, 'tags', queryHEDString));
            end;

        end;
        
        function idMask = parseRange(obj, rangeCell)
            switch  rangeCell{1}
                case'range' % the value for range should be in the form of [min max]
                    idMask = obj.times >= rangeCell{2}(1) & obj.times <= rangeCell{2}(2);
                case 'match' % to be used as {'trial' 'match' '[HED string]'}
                    idMask = getHEDMatch(obj, rangeCell{2});
                case 'codes' % to be used as {'trial' 'codes' {'eventcode1', 'eventcode2'}}
                    idMask = ismember(obj.codes, rangeCell{2});
                otherwise
                    error('Range string not recognized');
            end
        end;
        
        function obj = removeRandomTrials(obj)
            randomMatchVector = obj.getHEDMatch('Event/Category/Miscellaneous/Random');
            obj = obj.index(~randomMatchVector);
        end
    end;
end