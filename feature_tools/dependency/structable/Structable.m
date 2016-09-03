classdef Structable < handle
    % STRUCTABLE Convert an object to a struct.
    %
    %   The STRUCTABLE class can be used to convert instantiated MATLAB
    %   classes to structs.  In practice, this means converting the
    %   object's properties into identically-named fields of a struct with
    %   "flattened" values.  For example, if a property contains a function
    %   handle, it will be converted to a string.  If a property contains
    %   an object and that object inherits STRUCTABLE, it will be converted
    %   to struct and saved; otherwise, it will be passed over with a
    %   warning message.  This class provides services through inheritance,
    %   not instantiation -- an object of class STRUCTABLE will not be very
    %   useful for anything.
    %
    %   The primary reason to perform this conversion is to save a "safe"
    %   representation of an object into a MAT file.  Whereas a struct is a
    %   basic MATLAB variable type and struct variables can be loaded
    %   without dependency into any MATLAB environment, loading objects in
    %   MATLAB requires the defining class to be available on the path.
    %   Furthermore, if the class is not identical to the saved object's
    %   class definition, MATLAB will generate warnings, or worse.
    %
    %   The MATLAB builtin STRUCT method can be used to convert simple
    %   objects to structs, but it will not process object properties or
    %   any kind of class hierarchy.
    %
    %   STRUCTABLE will not perform miracles.  It won't dig through cell
    %   arrays or recognize recursive conversions (when two objects refer
    %   to each other in their properties).  It also may not handle some
    %   new MATLAB data types well.  But, it defines a process for handling
    %   issues like these and perhaps others in a structured (haha) way.
    %
    %   In the simplest scenario, there are no recursive handle references,
    %   and no "non-structable" objects hidden in the class properties.  To
    %   use STRUCTABLE, simply inherit it and call the TOSTRUCT method:
    %
    %     classdef MyClass < Structable
    %       properties
    %         ...
    %       end
    %       methods
    %         ...
    %       end
    %     end
    %
    %     >> obj = MyClass;
    %     >> st = obj.toStruct;
    %
    %   In more complicated scenarios, there may be properties which need
    %   to be processed manually.  The following example illustrates how to
    %   do this by overloading the TOSTRUCT method:
    %
    %     classdef MyClass < Structable
    %       properties
    %         prop1 % should be skipped
    %         prop2 % should be skipped
    %         ...   % all ok
    %         propn % ok
    %       end
    %       methods
    %         ...
    %         function st = toStruct(this)
    %           list = {'prop1','prop2'};
    %           st = toStruct@Structable(this,list{:});
    %           st.prop1 = 'val1';
    %           st.prop2 = 'val2';
    %         end
    %       end
    %     end
    %
    %     >> obj = MyClass;
    %     >> st = obj.toStruct;
    %
    %   A few small changes will be required to put STRUCTABLE inside a
    %   package.  Search throughout this file for the comment text "MODIFY
    %   FOR PACKAGE", and update those lines with the package namespace.
    %
    %   Note the dependency of this class on the function CATSTRUCT,
    %   developed by Jos van der Geest (jos@jasen.nl), available on the
    %   Mathworks File Exchange, and modified slightly to allow empty
    %   inputs.
    %
    %   See also STRUCTABLE/TOSTRUCT, STRUCTABLEHIERARCHY, and CATSTRUCT.
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
        function st = toStruct(this,varargin)
            % TOSTRUCT Convert an object to a struct.
            %
            %   ST = TOSTRUCT(THIS)
            %   Converts the object THIS to a struct ST.  THIS should be an
            %   instantiation of a class that inherits STRUCTABLE. If THIS
            %   inherits STRUCTABLEHIERARCHY, TOSTRUCT will call
            %   STRUCTABLESKIPFIELDS to get a list of properties to ignore,
            %   convert the object to a struct, then combine that struct
            %   with the customized struct returned by
            %   STRUCTABLEMANUALFIELDS.  If THIS does not inherit
            %   STRUCTABLEHIERARCHY, TOSTRUCT will process THIS directly.
            %
            %   ST = TOSTRUCT(THIS,'PROP1','PROP2',...,'PROPN')
            %   This formulation is only relevant when THIS does not
            %   inherit STRUCTABLEHIERARCHY.  TOSTRUCT will ignore PROP1,
            %   PROP2, ..., PROPN when converting THIS to a struct.
            %
            %   See also STRUCTABLE.
            
            % check for class hierarchy or not
            if isa(this,'StructableHierarchy') % MODIFY FOR PACKAGE
                
                % get a list of properties to ignore
                skip = structableSkipFields(this);
                
                % combine above with input argument list of ignored properties
                skip = [skip varargin];
                
                % convert the object to struct minus the ignored properties
                st = toStruct__(this,skip{:});
                
                % get the set of customized fields
                st1 = structableManualFields(this);
                
                % combine the structs
                st = catstruct(st,st1); % MODIFY FOR PACKAGE
            else
                
                % convert the object to struct
                st = toStruct__(this,varargin{:});
            end
        end % END function toStruct
        
    end % END methods
    
    methods(Access=private)
        function st = toStruct__(this,varargin)
            % TOSTRUCT__ perform the object-to-struct conversion
            %
            %   This method is not meant to be called by anything except
            %   STRUCTABLE/TOSTRUCT.  It is an internal method which
            %   performs the actual conversion from object to struct.
            %
            %   See also STRUCTABLE/TOSTRUCT.
            
            % If input is an array of objects, process each
            if builtin('length', this) > 1 % length(this)>1 % changed by nima since the length() function has been overloaded for ESS Baryon classes, e.g. Block and BaseAxis.
                
                % process first and last to preallocate
                st(1) = toStruct__(this(1),varargin{:});
                st(length(this)) = toStruct__(this(end),varargin{:});
                
                % loop through remaining
                for ss = 2:length(this)-1
                    st(ss) = toStruct__(this(ss),varargin{:});
                end
            else
                
                % retrieve class name of this object
                className = class(this);
                
                % user-provided list of properties to pass over
                skip={};
                if nargin>1, skip = varargin; end
                
                % gather property names of this object
                propNames = properties(this);
                
                % remove properties to be skipped
                for kk=1:length(skip)
                    propNames(strcmpi(propNames,skip{kk}))=[];
                end
                
                % process the remaining
                for kk=1:length(propNames)
                    
                    % handle cell arrays differently than other properties
                    if iscell(this.(propNames{kk}))
                        
                        % process elements of the cell array
                        if isempty(this.(propNames{kk}))
                            st.(propNames{kk}) = {};
                        else
                            st.(propNames{kk}) = cellfun(@(x)convertSingleProperty(this,x),this.(propNames{kk}),'UniformOutput',false);
                        end
                        
                    else
                        
                        % simply process the property
                        st.(propNames{kk}) = convertSingleProperty(this,this.(propNames{kk}),propNames{kk},className);
                    end
                end
            end
        end % END function toStruct__
        
        function val = convertSingleProperty(this,prop,varargin)
            % CONVERTSINGLEPROPERTY process a single property
            %
            %   This method is not meant to be called by anything except
            %   STRUCTABLE/TOSTRUCT__.  It is an internal method which
            %   handles processing of individual object properties.
            %
            %   See also STRUCTABLE/TOSTRUCT__.
            
            % default empty string
            val = '';
            
            % test if it's an object
            if isobject(prop)
                
                % gather information about the object
                info = eval(['?' class(prop)]);
                if isempty(info), return; end
                
                % run the first (ignoring subsequent)
                val = subprop(this,prop(1),info,varargin{:});
            else
                
                % conversion to standard values
                if isa(prop,'function_handle')
                    
                    % function handle - convert to string
                    val = func2str(prop);
                else
                    
                    % all others just assign the value back
                    val = prop;
                end
            end
        end % END function convertSingleProperty
        
        function val = subprop(this,prop,info,varargin)
            % SUBPROP process a single property
            %
            %   This method is not meant to be called by anything except
            %   STRUCTABLE/TOSTRUCT__.  It is an internal method which
            %   handles processing of individual object properties.
            %
            %   See also STRUCTABLE/TOSTRUCT__.
            
            % define metadata
            name = 'NotProvided';
            className = 'NotProvided';
            if nargin>=4, name = varargin{1}; end
            if nargin>=5, className = varargin{2}; end
            methodList = {info.MethodList.Name};
            
            % process the property depending on its characteristics
            if ~isempty(info.EnumerationMemberList)
                
                % enumeration - get string representation
                val = char(prop);
            elseif any(strcmpi(methodList,'toStruct'))
                
                % object with toStruct method
                val = toStruct(prop);
            else
                
                % punt
                warning('Structable cannot process ''%s'' (an instance of ''%s'') for class ''%s''\n',name,class(prop),className);
                val = className;
            end
        end
    end % END methods(Access=private)
    
end % END classdef Structable