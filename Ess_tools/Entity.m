classdef Entity %< dynamicprops
    properties 
        type = 'ess:Entity'; % each object has to have a type. Types have an explict MIME-like hierarchy, separated by /, i.e. parent/child     
        id; % each object must have a unique ID. These are gerenally created by appeding a UUID to 'ess:[object type]/'
        dateCreated 
     %   dateModified 
        custom % a structure with all additional, i.e. custom, properties of the Entity.
        description % human-readable description text containing information about the object.
    end;
    methods
        function obj = Entity
            add_ess_path_if_needed;
            obj = setAsNewlyCreated(obj);
        end;
        
        function obj = setId(obj)
            parts = strsplit(obj.type, '/');
            obj.id = [lower(parts{end}) '_' getUuid];
        end;
        
        function obj = setAsNewlyCreated(obj)
            obj.dateCreated = datestr8601(now,'*ymdHMS');
           % obj.dateModified = obj.dateCreated;
           obj = setId(obj);
        end;
                
        function obj = defineAsSubType(obj, subtype)
            % uses / to append childen (subtypes).
            % for Example ess:Entity/Block
            obj.type = [obj.type '/' subtype];
        end;
    end;
end
      