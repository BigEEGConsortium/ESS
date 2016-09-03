% Copyright © Qusp 2016. All Rights Reserved.
classdef ChannelAxis < SpaceAxis
    %  The channel axis characterizes EEG/EMG/ECG (EXG) channels (sensors) and their locations.
    
    properties        
    end;
    
    methods
        function obj =  ChannelAxis(varargin)
            obj = obj@SpaceAxis;
            obj.type = 'ess:BaseAxis/SpaceAxis/ChannelAxis';
            obj = obj.setId;
            
            obj.typeLabel = 'channel';            
            
            inputOptions = arg_define(varargin, ...
                arg('labels', {},{},'List of labels of each location. E.g. channel labels or anatomical labels; if this is already a NumPy array of type object no copy is made', 'type', 'cellstr'), ...
                arg('namingSystem', '', [],'The naming system used for the names. Ee.g."10-20", "Talairach",  ....', 'type', 'char'),...
                arg('positions', [], [],'Coordinates for each location.', 'type', 'denserealdouble'),...
                arg('coordinateSystem', '', [],'The coordinate system of the positions. E.g. "MNI", "Zebris", ...', 'type', 'char'),...
                arg('length', [],[],'Optionally the number of elements of the space axis. If no names/positions are given'), ...
                arg('customLabel', [], [],'A custom label (string) for the axis. This label can be used in extended indexing, e.g. obj(''customlabel_1'',:).'),...
                arg('chanlocs', [],[],'EEGLAB EEG.chanlocs structure. If provided, extract information from it.') ...                 
                );
            
            obj.namingSystem = inputOptions.namingSystem;
            obj.coordinateSystem = inputOptions.coordinateSystem;
            obj.customLabel = inputOptions.customLabel;

            if isempty(inputOptions.chanlocs)            
            obj.labels = inputOptions.labels(:);            
            obj.positions = inputOptions.positions;
            
            if isempty(obj.labels)
                if isempty(inputOptions.length)
                    error('Either "names" or "length" must be provoded');
                else
                    for i=1:inputOptions.length
                        obj.labels{i} = '';
                    end;
                end;
            end;
            else % read data from EEGLAB's EEG.chanlocs structure
                
                % check if locations are provided for every channel
                emptyLocationIds = [];
                for i=1:length(inputOptions.chanlocs)
                    if strcmpi(inputOptions.chanlocs(i).type, 'EEG')
                        if isempty(inputOptions.chanlocs(i).X) || isempty(inputOptions.chanlocs(i).Y) || isempty(inputOptions.chanlocs(i).Z);
                            emptyLocationIds = [emptyLocationIds i];
                        end;
                    end;
                end;
                
                if ~isempty(emptyLocationIds)
                    if strcmp(inputOptions.namingSystem, '10-20')
                        warning('Some EEG channel locations are missing.');
                        readLocs = readlocs('standard_1005.elc');
                        for i=1:length(inputOptions.chanlocs)
                            if strcmpi(inputOptions.chanlocs(i).type, 'EEG')
                                try
                                    chanLocsRecord = readLocs(strcmpi({readLocs.labels}, inputOptions.chanlocs(i).labels));
                                    fields = intersect(fieldnames(inputOptions.chanlocs(i)), fieldnames(chanLocsRecord));
                                    for j=1:length(fields)
                                        inputOptions.chanlocs(i).(fields{j}) = upper(chanLocsRecord.(fields{j}));
                                    end;
                                    inputOptions.chanlocs(i).type = 'EEG';
                                catch
                                    error('could not read channel %s location for the list of standard 10-20 locations', inputOptions.chanlocs(i).labels);
                                end;
                            end;
                        end
                        warning('All EEG channel locations were read from the list of standard 10-20 locations in standard_1005.elc.');
                    else
                        error('Some EEG channel locations are missing.');
                    end;
                end;
                
                
                for i=1:length(inputOptions.chanlocs)
                    if strcmpi(inputOptions.chanlocs(i).type, 'EEG')
                        obj.labels{end+1} = inputOptions.chanlocs(i).labels;
                        obj.positions(end+1,:) = [inputOptions.chanlocs(i).X inputOptions.chanlocs(i).Y inputOptions.chanlocs(i).Z];
                    end;
                end;
            end;
            
            obj.labels = obj.labels(:);
        end
        
    end;
end