classdef MyClass1 < Structable
    % MYCLASS1 example class to illustrate STRUCTABLE
    %
    %   This class illustrates the simplest case with no customizations.
    
    properties
        prop1 = 'val1'; % will be processed normally
        prop2 = 'val2'; % will be processed normally
        prop3 = 'val3'; % will be processed normally
    end % END properties
    
    methods
        function this = MyClass1
        end % END function MyClass1
    end % END methods
    
end % END classdef MyClass1