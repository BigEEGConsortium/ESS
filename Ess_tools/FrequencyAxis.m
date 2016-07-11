classdef FrequencyAxis < BaseAxis
    %  The frequency axis characterizes the frequencies of one or more data elements.
    
    properties
        frequencies % An array of frequencies points for each element, in Hz
    end;
    methods
        function obj =  FrequencyAxis(varargin)
            obj = obj@BaseAxis;
            obj = obj.defineAsSubType('FrequencyAxis');
            obj = obj.setId;
            
            obj.typeLabel = 'frequency';
            obj. perElementProperties = [obj. perElementProperties {'frequencies'}];
            
            inputOptions = arg_define(varargin, ...              
                arg('frequencies', [], [],'An array of frequencies points for each element. In Hz', 'type', 'denserealdouble')...               
                );
            obj.frequencies = inputOptions.frequencies(:);
            
            check_monotonic(obj.frequencies, 'frequencies');           
        end
        
    end;
end