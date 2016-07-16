classdef SpaceAxis < BaseAxis
    %  The space axis characterizes the spatial locations (labels and/or coordinates) of one or more data elements.
    
    properties
        labels
        namingSystem
        positions
        coordinateSystem
    end;
    
    methods
        function obj =  SpaceAxis(varargin)
            obj.type = 'ess:BaseAxis/SpaceAxis';
            obj = obj.setId;
            obj.typeLabel = 'space';
            obj. perElementProperties = [obj. perElementProperties {'labels' 'positions'}];
            
            if nargin > 0
                inputOptions = arg_define(varargin, ...
                    arg('labels', {},{},'List of labels of each location. E.g. channel labels or anatomical labels; if this is already a NumPy array of type object no copy is made', 'type', 'cellstr'), ...
                    arg('namingSystem', '', [],'The naming system used for the names. Ee.g."10-20", "Talairach",  ....', 'type', 'char'),...
                    arg('positions', [], [],'Coordinates for each location. should be an N x M matrix for N space elements.', 'type', 'denserealdouble'),...
                    arg('coordinateSystem', '', [],'The coordinate system of the positions. E.g. "MNI", "Zebris", ...', 'type', 'char'),...
                    arg('length', [],[],'Optionally the number of elements of the space axis. If no names/positions are given') ...
                    );
                
                obj.labels = inputOptions.labels(:);
                obj.namingSystem = inputOptions.namingSystem;
                obj.positions = inputOptions.positions;
                obj.coordinateSystem = inputOptions.coordinateSystem;
                
                if isempty(obj.labels)
                    if isempty(inputOptions.length)
                        error('Either "names" or "length" must be provoded');
                    else
                        obj.labels = cell(inputOptions.length, 1);
                        for i=1:inputOptions.length
                            obj.labels{i} = '';                            
                        end;
                        obj.positions = zeros(inputOptions.length,0);
                    end;
                end;
            end;
        end
        
    end;
end