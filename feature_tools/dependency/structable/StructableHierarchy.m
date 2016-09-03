classdef StructableHierarchy < handle
    % STRUCTABLEHIERARCHY Supporting struct conversion of class hierarchies
    %
    %   In complicated class hierarchies, class-specific information 
    %   required to perform struct conversion should be localized to each 
    %   class so that class definitions can change modularly.  
    %   STRUCTABLEHIERARCHY uses method overloading, specifically the 
    %   feature that overloaded methods can call methods of the same name 
    %   and signature on their superclasses, to retrieve class-specific 
    %   information required for the struct conversion process.  In this
    %   way, a single call to TOSTRUCT on the instantiated object will 
    %   ripple through the entire hierarchy to produce a single converted 
    %   struct.  Two additional methods are required for this process: 
    %   STRUCTABLESKIPFIELDS and STRUCTABLEMANUALFIELDS.
    %
    %   STRUCTABLESKIPFIELDS provides a method for skipping properties that
    %   will either be ignored entirely or processed manually.
    %
    %   STRUCTABLEMANUALFIELDS provides a way to add customized fields to 
    %   the output struct.  Fields of the struct returned by this method
    %   will be added to the automatically-generated struct.  
    %
    %   STRUCTABLEHIERARCHY is an add-on, not a replacement, for
    %   STRUCTABLE.  The entry point to the struct conversion process is
    %   still STRUCTABLE/TOSTRUCT, which will use STRUCTABLESKIPFIELDS and
    %   STRUCTABLEMANUALFIELDS if the object inherits STRUCTABLEHIERARCHY.
    %
    %   All classes in the hierarchy must inherit STRUCTABLEHIERARCHY, and
    %   each class requiring any kind of customized processing should 
    %   overload STRUCTABLESKIPFIELDS and STRUCTABLEMANUALFIELDS.  Both of
    %   these methods will return empty outputs if not overloaded. At least
    %   one class in the hierarchy (typically the base class) must inherit
    %   STRUCTABLE.
    %
    %   The base class must overload the methods STRUCTABLESKIPFIELDS and 
    %   STRUCTABLEMANUALFIELDS (otherwise, there would be a naming conflict
    %   error, since MATLAB could not know which of all the superclasses' 
    %   versions of these methods to call at runtime).  The overloaded 
    %   methods call the superclass methods of the same name in order to 
    %   get unique information from each superclass.
    %
    %   Below is an example class which overloads both STRUCTABLESKIPFIELDS
    %   and STRUCTABLEMANUALFIELDS to define the list of properties to
    %   skip, and then to manually define fields of the output struct:
    %
    %     classdef MyClass < sc1 & sc2 & Structable & StructableHierarchy
    %       properties
    %         prop1 % ok
    %         prop2 % needs manual processing
    %         prop3 % needs manual processing
    %       end
    %       methods
    %         ...
    %         function list = structableSkipFields(this)
    %           list1 = structableSkipFields@sc1(this);
    %           list2 = structableSkipFields@sc2(this);
    %           list = [{'prop2','prop3'} list1 list2];
    %         end
    %         function st = structableManualFields(this)
    %           st1 = structableManualFields@sc1(this);
    %           st2 = structableManualFields@sc2(this);
    %           st = catstruct(st1,st2);
    %           st.prop2 = val2;
    %           st.prop3 = val3;
    %         end
    %       end
    %     end
    %
    %     >> obj = MyClass;
    %     >> st = obj.toStruct;
    %
    %   No changes are required in this class definition to put 
    %   STRUCTABLEHIERARCHY inside a package.
    %
    %   Note in the above example the use of the function CATSTRUCT,
    %   developed by Jos van der Geest (jos@jasen.nl), available on the
    %   Mathworks File Exchange, and modified slightly to allow empty
    %   inputs.
    %
    %   See also STRUCTABLE, STRUCTABLE/TOSTRUCT,
    %   STRUCTABLEHIERARCHY/STRUCTABLESKIPFIELDS, 
    %   STRUCTABLEHIERARCHY/STRUCTABLEMANUALFIELDS, and CATSTRUCT.
    %
    %   Tested in MATLAB R2013a and up, but may work in earlier versions.
    %   Version 1.0 (Jan 2015)
    %   (c) Spencer Kellis
    %   email: spencer.kellis@caltech.edu
    %
    %   History
    %   Created in 2015
    %   Revisions
    %     1.0 (Jan 2015) initial revision
    
    methods
        function list = structableSkipFields(this)
            % STRUCTABLESKIPFIELDS Provide a list of properties to ignore.
            %
            %   LIST = STRUCTABLESKIPFIELDS(THIS)
            %   Provide a cell array LIST of property names to ignore when
            %   converting THIS to a struct.  Overload this method in the 
            %   inheriting class to customize the list of properties to
            %   ignore.
            %
            %   See also STRUCTABLE,
            %   STRUCTABLE/TOSTRUCT, and
            %   STRUCTABLEHIERARCHY/STRUCTABLEMANUALFIELDS.
            
            list = {};
        end % END function structableSkipFields
        
        function st = structableManualFields(this)
            % STRUCTABLEMANUALFIELDS Provide customized struct fields.
            %
            %   ST = STRUCTABLESKIPFIELDS(THIS)
            %   Returns a struct ST with custom fields to be added to the
            %   output of TOSTRUCT.
            %
            %   See also STRUCTABLE,
            %   STRUCTABLE/TOSTRUCT, and
            %   STRUCTABLEHIERARCHY/STRUCTABLEMANUALFIELDS.
            
            st = [];
        end % END function structableManualFields
    end % END methods(Abstract)
end % END classdef Structable