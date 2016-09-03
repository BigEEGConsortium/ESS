classdef SuperClass1 < StructableHierarchy
    % SUPERCLASS1 example class to illustrate STRUCTABLEHIERARCHY
    %
    %   This example shows how to define struct conversion for an inherited
    %   superclass.  The information is defined locally in the functions
    %   STRUCTABLESKIPFIELDS and STRUCTABLEMANUALFIELDS.  It will be used
    %   when the TOSTRUCT method is called on the instantiated object.
    
    properties
        sc1prop1 = 'sc1val1'; % will be customized
        sc1prop2 = 'sc1val2'; % will be processed normally
        sc1prop3 = 'sc1val3'; % will be processed normally
    end % END properties
    
    methods
        function this = SuperClass1
        end % END function SuperClass1
        
        function list = structableSkipFields(this)
            % STRUCTABLESKIPFIELDS overloaded from StructableHierarchy
            %
            %   Retrieve list of fields to skip from each of the inherited
            %   superclasses, and concatenate with the list of local
            %   properties to skip.
            
            list = {'sc1prop1'};
        end % END function structableSkipFields
        
        function st = structableManualFields(this)
            % STRUCTABLEMANUALFIELDS overloaded from StructableHierarchy
            %
            %   Retrieve structs with manually defined fields from each of
            %   the inherited superclasses, and merge with manually defined
            %   fields of local class.
            
            st.sc1prop1 = sprintf('%s_customized',this.sc1prop1);
        end % END function structableManualFields
    end % END methods
    
end % END classdef SuperClass1