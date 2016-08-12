classdef FeatureAxis < BaseAxis
    %  The feature axis describes individual features of some data (e.g. their
    %   names and/or statistics) 

    properties
        names % Optionally a cell array of names for each feature (e.g. 'amplitude', 'phase', 'distance' or 'log-power')              
        units % Optionally a cell array of unit strings for each feature
              % (e.g. 'microvolts', 'radians' or 'meters')
        flags % Optionally a cell array, with each cell containing string-type property flags for each feature. (e.g. 
              % {'nonnegative'}, {'angle'} or {'squared', 'log'}) 
        errorDistributions % Optionally a cell array of  strings encoding 
                          % the distribution type for which the "error bars" for each
                          % feature are encoded. (e.g. 'normal', 'beta')
        samplingDistributions % Optionally a cell array of  strings encoding 
                          % the type of distribution that each feature is drawn from
                          % (e.g. 'laplace', 'bernoulli')       
    end;
    methods
        function obj =  FeatureAxis(varargin)
            obj = obj@BaseAxis;    
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
            
            obj.typeLabel = 'feature';
            obj.perElementProperties = [obj. perElementProperties {'names' 'units' 'flags' 'errorDistributions' 'samplingDistributions'}];

            inputOptions = arg_define(varargin, ...              
                arg('length', [], [],'The number of elements of the feature axis, If no other arguments are given.'),... 
                arg('names', {}, {},'Cells with unit strings for each feature. E.g. ''amplitude'', ''phase'', ''distance'' or ''log-power''.'),...  
                arg('units', {}, {},'Cells with string-type property flags. E.g. ''microvolts'', ''radians'' or ''meters''', 'type', 'cellstr'),...
                arg('errorDistributions', {}, {},'Cells with string-type "error bars" distributions. E.g. ''normal'', ''beta'''),...  
                arg('samplingDistributions', {}, {},'Cells with feature distribution strings. E.g. ''laplace'', ''bernoulli'''),...  
                arg('customLabel', [], [],'A custom label (string) for the axis. This label can be used in extended indexing, e.g. obj(''customlabel_1'',:).'),...
                arg('flags', {}, {},'Cells with property flags for each feature. E.g. {''nonnegative''}, {''angle''} or {''squared'', ''log''}', 'type', 'cellstr')...
                );
            
            providedPerElementProperties = {};
            skippedPerElementProperties = {};
            for i=1:length(obj.perElementProperties)
                if isempty(inputOptions.(obj.perElementProperties{i}))
                    skippedPerElementProperties{end+1} = obj.perElementProperties{i};
                else
                    providedPerElementProperties{end+1} = obj.perElementProperties{i};
                end;
            end;
            
            if isempty(providedPerElementProperties)
                if isempty(inputOptions.length)
                    inferredLength = 0;
                else % length is provided
                    inferredLength = inputOptions.length;                    
                end
            else % some per-item properties are provided
                inferredLength = length(inputOptions.(providedPerElementProperties{1}));
            end;
            
            for i=1:length(skippedPerElementProperties)
                obj.(skippedPerElementProperties{i}) = cell(inferredLength, 1);
            end;
            
            for i=1:length(providedPerElementProperties)
                obj.(providedPerElementProperties{i}) = vec(inputOptions.(providedPerElementProperties{i}));
            end;   
            
            obj.customLabel = inputOptions.customLabel;
        end            
        
        function idMask = parseRange(obj, rangeCell)
            switch  rangeCell{1}
                case'name' % to be used for example as {'name', 'mean'}
                    idMask = cellfun(@(x) isequal(rangeCell{2}, x), obj.names);
                otherwise
                    error('Range string not recognized');
            end
        end;
    end;
end