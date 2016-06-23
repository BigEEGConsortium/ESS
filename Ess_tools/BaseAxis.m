classdef BaseAxis < Entity
    properties
        typeLabel
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
     end
end