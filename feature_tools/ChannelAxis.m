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
                arg('chanlocs', [],[],'EEGLAB EEG.chanlocs structure. If provided, extract information from it.') ...                 
                );
            
            if isempty(inputOptions.chanlocs)
            
            obj.labels = inputOptions.labels(:);
            obj.namingSystem = inputOptions.namingSystem;
            obj.positions = inputOptions.positions;
            obj.coordinateSystem = inputOptions.coordinateSystem;
            
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