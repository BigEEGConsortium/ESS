classdef BaseAxis < Entity
    properties
        typeLabel
    end;
    properties (Access = protected)
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
    methods (Abstract)
    length % Returns the number of elements in the axis
%    parseRange % Parses a given domain-specific rangeexpression into a slice or index sequence
%     selectRange % Returns a sub-range of the axes for some slice or index sequence; slices produce a view.
%     assign_range % Assigns contents of some axis to an indexed sub-range of the axis in-place
%     concat % Returns a new axis object that is the concatenation of all axes in the argument list
    end
     methods
         function obj = BaseAxis
             obj = obj@Entity;
         end;
         
           function sref = subsref(obj, s)
            switch s(1).type
                case '.'
                    sref = builtin('subsref',obj,s);
                case '()'
                    if length(s) < 2
                        
                        newObj = obj;
                        
                        %for i=1:length(newObj ! subsleect all per-element axis properties here.
                        
                        sref = builtin('subsref',permutedTensor, newS);
                        return
                    else
                        sref = builtin('subsref',obj,s);
                    end
                case '{}'
                    error('MYDataClass:subsref',...
                        'Not a supported subscripted reference')
            end
        end;
     end
end