classdef InstanceAxis < BaseAxis
    %  The instance axis describes multiple instances (e.g. trials,
    %  observations, subjects, studies) of some data and can hold attached per-instance "payload".
    
    properties        
        cells % A cell array with information for each "instance" element.
    end;
    methods
        function obj =  InstanceAxis(varargin)
            obj = obj@BaseAxis;
            obj = obj.defineAsSubType('InstanceAxis');
            obj = obj.setId;
            
            obj.typeLabel = 'instance';
            obj. perElementProperties = [obj. perElementProperties {'cells'}];

            
            if nargin > 0
                inputOptions = arg_define(varargin, ...
                    arg('cells', [], [],'A cell array with information for each "instance" element.')...
                    );
                
                obj.cells = inputOptions.cells;
            end;
        end
        
    end;
end