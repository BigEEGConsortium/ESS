classdef MyClassHierarchy < SuperClass1 & SuperClass2 & Structable & StructableHierarchy
    % MYCLASSHIERARCHY example class to illustrate STRUCTABLEHIERARCHY
    %
    %   This class shows how to define struct conversion for a two-level 
    %   class hierarchy and multiple inheritance.  The local functions
    %   STRUCTABLESKIPFIELDS and STRUCTABLEMANUALFIELDS overload the
    %   STRUCTABLEHIERARCHY definitions, and each calls that same method
    %   for each of the superclasses.  SuperClass1 also overloads those
    %   methods; SuperClass2 does not use any customization.
    
    properties
        prop1 = 'val1'; % will be processed normally
        prop2 = 'val2'; % will be customized
        prop3 = 'val3'; % will be customized
    end % END properties
    
    methods
        function this = MyClassHierarchy
        end % END function MyClassHierarchy
        
        function list = structableSkipFields(this)
            % STRUCTABLESKIPFIELDS overloaded from StructableHierarchy
            %
            %   Retrieve list of fields to skip from each of the inherited
            %   superclasses, and concatenate with the list of local
            %   properties to skip.
            
            list1 = structableSkipFields@SuperClass1(this);
            list2 = structableSkipFields@SuperClass2(this);
            list = [{'prop2','prop3'} list1 list2];
        end % END function structableSkipFields
        
        function st = structableManualFields(this)
            % STRUCTABLEMANUALFIELDS overloaded from StructableHierarchy
            %
            %   Retrieve structs with manually defined fields from each of
            %   the inherited superclasses, and merge with manually defined
            %   fields of local class.
            
            st1 = structableManualFields@SuperClass1(this);
            st2 = structableManualFields@SuperClass2(this);
            st = catstruct(st1,st2);
            st.prop2 = sprintf('%s_customized',this.prop2);
            st.prop3 = sprintf('%s_customized',this.prop3);
        end % END function structableManualFields
    end % END methods
    
end % END classdef MyClassHierarchy