classdef TimeAxis < BaseAxis
    %  The time axis represents the time points for each data element as an array,
    %  which allows for both regularly and irregularly sampled time series. It may
    %  also hold the nominal sampling rate if the data is regularly sampled.
    
    properties
        times % An array of time points for each element, in seconds
        nominalRate = [];
    end;
    methods
        function obj =  TimeAxis(varargin)
            obj.type = 'ess:BaseAxis/TimeAxis';
            obj = obj.setId;
            
            obj.typeLabel = 'time';
            obj. perElementProperties = [obj. perElementProperties {'times'}];
            
            inputOptions = arg_define(varargin, ...
                arg('nominalRate', [],[],'The nominal sampling rate of the data. Only if regularly sampled, in Hz.'), ...
                arg('initTime', 0, [],'The initial time point. From which times will be deduced. (default: `0.0`)'),...
                arg('times', [], [],'An array of time points for each sample. In seconds', 'type', 'denserealdouble'),...
                arg('noWarnings', false, [],'Disable warnings during construction. About non-monotonic time-stamps)', 'type', 'logical'),...
                arg('numberOfTimes', [],[],'The number of time points. From which times will be deduced if `times` is ``None``') ...
                );
            obj.nominalRate = inputOptions.nominalRate;
            if isempty(inputOptions.times)
                if isempty(inputOptions.numberOfTimes) || isempty(inputOptions.nominalRate)
                    error('If "times" is not provided, both "nominalRate" and "numberOfTimes" mut be provided.');
                else
                    obj.times = inputOptions.initTime + linspace(0, inputOptions.numberOfTimes / inputOptions.nominalRate, inputOptions.numberOfTimes);
                    obj.times = obj.times(:);
                end;
            else
                obj.times = inputOptions.times(:);
                if ~inputOptions.noWarnings 
                    check_monotonic(obj.times, 'times');
                end;
            end
        end
        
        function l = length(obj)
            l = length(obj.times);
        end;
    end;
end