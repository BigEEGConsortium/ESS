classdef FrequencyAxis < BaseAxis
    %  The frequency axis characterizes the frequencies of one or more data elements.
    
    properties
        frequencies % An array of frequencies points for each element, in Hz
    end;
    methods
        function obj =  FrequencyAxis(varargin)
            obj = obj@BaseAxis;
            obj = obj.defineAsSubType(mfilename('class'));
            obj = obj.setId;
            
            obj.typeLabel = 'frequency';
            obj. perElementProperties = [obj. perElementProperties {'frequencies'}];
            
            inputOptions = arg_define(varargin, ...              
                arg('frequencies', [], [],'An array of frequencies points for each element. In Hz', 'type', 'denserealdouble')...               
                );
            obj.frequencies = inputOptions.frequencies(:);
            
            check_monotonic(obj.frequencies, 'frequencies');           
        end
        
        function idMask = parseRange(obj, rangeCell)
            switch  rangeCell{1}
                case'range' % the value for range should be in the form of [min max]
                    idMask = obj.frequencies >= rangeCell{2}(1) & obj.frequencies <= rangeCell{2}(2);
                otherwise
                    error('Range string not recognized');
            end
        end
    end;
end