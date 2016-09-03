classdef SuperClass2 < StructableHierarchy
    % SUPERCLASS2 example class to illustrate STRUCTABLEHIERARCHY
    %
    %   This example illustrates an inherited class that requires no
    %   customization.
    
    properties
        sc2prop1 = 'sc2val1'; % will be processed normally
        sc2prop2 = 'sc2val2'; % will be processed normally
        sc2prop3 = 'sc2val3'; % will be processed normally
    end % END properties
    
    methods
        function this = SuperClass2
        end % END function SuperClass2
    end % END methods
    
end % END classdef SuperClass2