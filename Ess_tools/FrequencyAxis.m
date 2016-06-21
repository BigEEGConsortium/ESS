classdef FrequencyAxis < BaseAxis
    %  The frequency axis characterizes the frequencies of one or more data elements.
    
    properties (Constant)
        typeLabel = 'frequency';
    end
    properties
        frequencies % An array of frequencies points for each element, in Hz
    end;
    methods
        function obj =  FrequencyAxis(varargin)
            obj.type = 'ess:BaseAxis/FrequencyAxis';
            obj = obj.setId;
            inputOptions = arg_define(varargin, ...              
                arg('frequencies', [], [],'An array of frequencies points for each element. In Hz', 'type', 'denserealdouble')...               
                );
            obj.frequencies = inputOptions.frequencies(:);
            
            check_monotonic(obj.frequencies, 'frequencies');           
        end
        
        function l = length(obj)
            l = length(obj.frequencies);
        end;
    end;
end