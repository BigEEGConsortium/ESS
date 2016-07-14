classdef BaseAxis < Entity
    properties
        typeLabel % quantity represented by the axis, e.g. 'time', 'channel', 'trial'. 
                  % these are automatically set by child objects and should not be changed by
                  % extrenal scripts.
        % customLabel % for distinguishing axes with the same type, e.g. two 'channel' axis, 
                      % instead can use e.g. 'toChannel', 'fromChannel'
    end;
    properties %(Access = protected)
        perElementProperties = {};% a cell array of strings with the names of properties in
        % the axis that are vectors with each element of
        % the vector associatd with one axis element.
        % For example, "times" is a vector of size N
        % with each element associated with an axis of
        % lenght N elements (N time points).
        % In contrast, an axis can properties, e.g.
        % "typeLabel that are associated with the whole
        % axis and not its individual elements.
    end;
   % methods (Static)
        % length % Returns the number of elements in the axis
        %    parseRange % Parses a given domain-specific rangeexpression into a slice or index sequence
        %     selectRange % Returns a sub-range of the axes for some slice or index sequence; slices produce a view.
        %     assign_range % Assigns contents of some axis to an indexed sub-range of the axis in-place
        %     concat % Returns a new axis object that is the concatenation of all axes in the argument list
   % end
    methods
        function obj = BaseAxis
            obj = obj@Entity;
            obj = obj.defineAsSubType(mfilename('class'));
        end;
        
        function l = length(obj)
            if isempty(obj.perElementProperties)
                l = 0;
            else
                l = size(obj.(obj.perElementProperties{1}), 1);
            end;
        end
        
        function sref = subsref(obj, s)
            switch s(1).type
                case '.'
                    sref = builtin('subsref',obj,s);
                case '()'
                    for j=1:length(s) % to handle t(1:5).times case, t  = Time
                        if j == 1
                            sref = obj;
                            
                            for i=1:length(obj.perElementProperties) % subsleect all per-element axis properties.
                                % for per-item properties with more than
                                % one singleton dimension, e.g. 3D
                                % position, slicing should only apply 
                                % on the first dimension.
                                subStruct = s(1);
                                for k=2:ndims(obj.(obj.perElementProperties{i}))
                                    subStruct.subs{k} = ':';
                                end;
                                    
                                sref.(obj.perElementProperties{i}) = builtin('subsref', obj.(obj.perElementProperties{i}), subStruct);
                            end;
                            
                            sref = sref.setAsNewlyCreated;
                        else
                            sref = builtin('subsref',sref,s(j));
                        end;
                    end;
                    return
                case '{}'
                    error('MYDataClass:subsref',...
                        'Not a supported subscripted reference')
            end
        end;
        
        function valid = isValid(obj)
            valid = true;
            if isempty(obj.perElementProperties)
                fprintf('Axis of type "%s" does not have any per-item properties. Each axis should at least have one.\n', obj.typeLabel);
                valid = false;
            end;           
            
            firstDimensionLength = [];
            for i=1:length(obj.perElementProperties) % make sure all per-tem properties have the same length in the first dimension 
                firstDimensionLength = size(obj.(obj.perElementProperties{i}), 1);
                if firstDimensionLength ~= obj.length
                    valid = false;
                    fprintf('Per-item property "%s" of axis of type "%s" has a different first dimension that axis length.\n', obj.perElementProperties{i}, obj.typeLabel);
                end;
            end;
        end;
        
        function ids = parseRange(obj, rangeCell)
            % this function is overriden in child classes. 
        end;
    end
end