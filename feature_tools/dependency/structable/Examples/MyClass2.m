classdef MyClass2 < Structable
    % MYCLASS2 example class to illustrate STRUCTABLE
    %
    %   This class illustrates how to customize the struct conversion
    %   process by overloading the toStruct method.
    
    properties
        prop1 = 'val1'; % will be processed normally
        prop2 = 'val2'; % will be customized
        prop3 = 'val3'; % will be customized
    end % END properties
    
    methods
        function this = MyClass2
        end % END function MyClass2
        
        function st = toStruct(this)
            list = {'prop2','prop3'};
            st = toStruct@Structable(this,list{:});
            st.prop2 = sprintf('%s_customized',this.prop2);
            st.prop3 = sprintf('%s_customized',this.prop3);
        end % END function toStruct
    end % END methods
    
end % END classdef MyClass2