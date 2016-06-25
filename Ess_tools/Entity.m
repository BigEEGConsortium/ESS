classdef Entity %< dynamicprops
    properties 
        type = 'ess:Thing';      
        id;
        dateCreated 
     %   dateModified 
    end;
    methods
        function obj = Entity
            add_ess_path_if_needed;
            obj = setAsNewlyCreated(obj);
        end;
        
        function obj = setId(obj)
            obj.id = [obj.type '/' char(java.util.UUID.randomUUID)];
        end;
        
        function obj = setAsNewlyCreated(obj)
            obj.dateCreated = datestr8601(now,'*ymdHMS');
           % obj.dateModified = obj.dateCreated;
           obj = setId(obj);
        end;
    end;
end
      