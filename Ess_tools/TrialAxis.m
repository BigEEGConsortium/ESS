classdef TrialAxis < InstanceAxis
    %  Trials from one or more data recordings (from one or more sessions or studies).    

    properties
        times % A numerical array with time (in seconds) for each trial relative to the start of its data recording.
        codes % maps to EEGLAB event code: EEG.event(x).type
        hedStrings % maps to EEG.event(x).usertags combined with EG.event(x).hedtags
        % eventContext
       % dataRecordingIds % a cell array with ids of the data recordings for each trials, one id for each trial. 
    end;
    methods
        function obj =  TrialAxis(varargin)
            obj = obj@InstanceAxis;
            obj = obj.defineAsSubType('TrialAxis');
            obj = obj.setId;
            
            obj.typeLabel = 'trial';
            obj. perElementProperties = [obj. perElementProperties {'times' 'codes' 'hedStrings'}];


            inputOptions = arg_define(varargin, ...              
                arg('times', [], [],'A numerical array with time. In seconds for each trial relative to the start of its data recording.'),... 
                arg('instances', {}, {},'A cell array with information for each "instance" element.'),...  
                arg('codes', {}, {},'A cell array with trial event codes.', 'type', 'cellstr'),...
                arg('hedStrings', {}, {},'A cell array with trial event HED strings. Each HED string is associatd with one trial', 'type', 'cellstr')...
                );
            
            
            if ~isempty(inputOptions.times) && ~isempty(inputOptions.instances) && length(inputOptions.instances) ~= inputOptions.times
                error('If both "times" and "instances" are provided, they need to have the same length.');
            end;
            
            % place empty elements for instances, code and hed strings. 
            if isempty(inputOptions.instances)
                inputOptions.instances = cell(length(inputOptions.times), 1);
            end;
            
            if isempty(inputOptions.codes)
                for i=1:length(inputOptions.times)
                    inputOptions.codes{i} = '';
                end;
            end;
            
            if isempty(inputOptions.hedStrings)
                for i=1:length(inputOptions.times)
                    inputOptions.hedStrings{i} = '';
                end;
            end;
            
            % try to extract times from 'time' field of instances
            if isempty(inputOptions.times) 
                obj.times = zeros(length(inputOptions.instances), 1);
                for i=1:length(inputOptions.instances)
                    if isfield(inputOptions.instances{i}, 'time') && ~isempty(inputOptions.instances{i}.time)
                        obj.times(i) = inputOptions.instances{i}.time;
                    else
                        error('Failed to extract "times" from "time" field of "instances"');
                    end;
                end;
            end;
            
            obj.cells = inputOptions.instances(:);
            obj.times = inputOptions.times(:);
            obj.codes = inputOptions.codes(:);
            obj.hedStrings = inputOptions.hedStrings(:);
            check_monotonic(obj.times, 'times');
        end            
        
        function matchVector = getHEDMatch(obj, queryHEDString)
            % matchVector = getHEDMatch(obj, queryHEDString)
            events = struct('usertags', '');
            
            for i=1:length( obj.hedStrings)
                events(i).usertags = obj.hedStrings{i};
            end;
            
            matchVector = findTagMatchEvents(events, queryHEDString);            
        end;
    end;
end