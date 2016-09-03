classdef InstanceAxis < BaseAxis
    %  The instance axis describes multiple instances (e.g. trials,
    %  observations, subjects, studies) of some data and can hold attached per-instance "payload".
    
    properties        
        payloads % A cell array with information for each "instance" element.
    end;
    methods
        function obj =  InstanceAxis(varargin)
            obj = obj@BaseAxis;
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
            
            obj.typeLabel = 'instance';
            obj. perElementProperties = [obj. perElementProperties {'payloads'}];
            obj.intersectionPerItemProperties = {'payloads'};

            
            if nargin > 0
                inputOptions = arg_define(varargin, ...
                    arg('payloads', [], [],'A cell array with information for each "instance" element.'),...
                    arg('customLabel', [], [],'A string indicating a custom label for the axis. This label can be used in extended indexing, e.g. obj(''customlabel_1'',:).')...
                    );
                obj.customLabel = inputOptions.customLabel;
                obj.payloads = inputOptions.payloads(:);
            end;
        end
        
        function newObj = horzcat(obj, obj2)
             if ~obj.isValid || ~obj2.isValid
                error('One or more of the Instance Axis type objects is invalid.');
            end;
            
            newObj = obj;
            newObj = setAsNewlyCreated(newObj);
            newObj = newObj.setId;
            newObj.description = '';
            for i=1:length(obj.perElementProperties)
                newObj.(obj.perElementProperties{i}) = cat(1, obj.(obj.perElementProperties{i}), obj2.(obj.perElementProperties{i}));
            end;
            
            assert(newObj.isValid, 'The final, concatenated, instance axis is invalid.');
        end
    end;
end