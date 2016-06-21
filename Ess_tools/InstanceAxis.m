classdef InstanceAxis < BaseAxis
    %  The instance axis describes multiple instances (e.g. trials,
    %  observations, subjects, studies) of some data and can hold attached per-instance "payload".

    properties
        typeLabel = 'instance';
        instance % A cell array with information for each "instance" element.
    end;
    methods
        function obj =  InstanceAxis(varargin)
            obj.type = 'ess:BaseAxis/InstanceAxis';
            obj = obj.setId;
            inputOptions = arg_define(varargin, ...              
                arg('instances', [], [],'A cell array with information for each "instance" element.')...               
                );
            
            obj.instances = inputOptions.instances;                  
        end
        
        function l = length(obj)
            l = length(obj.frequencies);
        end;
    end;
end