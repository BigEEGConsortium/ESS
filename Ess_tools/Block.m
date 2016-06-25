classdef Block < Entity
    % Block is the base data structure for holding numerical data.
    % Its main fields are a tensor with arbitrary dimension and
    % a number of axis, each with a different type label, e.g. time,
    % frequency, trial, etc.
    % Block data can be accessed using an extended indexing syntax,
    % for example
    %
    % >> b = Block('tensor', [1 2 3; 4 5 6], 'axes', ...
    %       {TimeAxis('times', [0 0.1]), FrequencyAxis('frequencies', [1 2 3])});
    %
    % >> b('frequency',:)
    % and
    % >> b('frequency','time')
    %
    % these will arrange dimensions according to provided type label.
    % assignments work the same way:
    % >> b('frequency',end) = [4 5 6];
    
    properties
        tensor % a numerical array with any number of dimensions
        axes % a cell array containing axis information for the tensor.
        % the number of of elements should be the same as the number of
        % dimensions of "tensor" field.
    end;
    methods
        function obj = Block(varargin)
            obj = obj@Entity;
            obj.type = 'ess:Block'; % use / to append childen types here.
            obj = obj.setId;
            
            if nargin > 0
                inputOptions = arg_define(varargin, ...
                    arg('tensor', [], [],'A numerical array with any number of dimensions.'),...
                    arg('axes', {}, {},'A cell array with information for each "instance" element.')...
                    );
                % if only one axis is provided and the input tensor is 1 x N, transpose it so it is
                % N x 1
                if size(inputOptions.tensor, 1) == 1 && length(size(inputOptions.tensor)) == 2 && length(inputOptions.axes) == 1
                    inputOptions.tensor = inputOptions.tensor';
                end;
                
                if length(inputOptions.axes) == 1 && ~iscell(inputOptions.axes)
                    inputOptions.axes = {inputOptions.axes};
                end
                
                s = size(inputOptions.tensor);
                s(s==1) = [];
                if length(inputOptions.axes) < length(s)
                    error('Number of "axes" should be at least equal to the number of non-singleton dimentions of "tensor"');
                end;
                
                s = size(inputOptions.tensor);
                for i=1:length(s)
                    if ~(s(i) == 1 && i > length(inputOptions.axes))
                        if i > length(inputOptions.axes)
                            error('Not enoght Axes are provided');
                        end;
                        if s(i) ~= inputOptions.axes{i}.length
                            error('Number of elements in "axes %d" should the same as the number of elements in dimension %d of "tensor"', i, i);
                        end;
                    end;
                end;
                
                obj.axes = inputOptions.axes;
                obj.tensor = inputOptions.tensor;
            end;
        end
        
        function typeLabels = axesTypeLabels(obj)
            typeLabels = {};
            for i=1:length(obj.axes)
                typeLabels{i} = obj.axes{i}.typeLabel;
            end;
        end;
        
        function axesId = typeLabelToAxesId(obj, allLabels, index)
            % axesId = typeLabelToAxesId(obj, allLabels, index)
            % maps a typeLabel string to the axis item in
            % axes property with the matching typeLabel
            %
            % the second time 'frequency' is usd it referes to the second axis with the
            % label 'frequency'.
            
            % extrct only axis type labels from extended index syntax,
            % for example {'time', {..}} maps to 'time'
            allLabels = cellfun(@Block.extendedIndexToLabel, allLabels, 'UniformOutput', false);
            
            label = allLabels{index};
            orderOfOccurance = sum(strcmpi(label, allLabels(1:index)));
            
            if nargin < 3
                orderOfOccurance = 1;
            end;
            
            typeLabels = axesTypeLabels(obj);
            
            axesId = find(strcmpi(label, typeLabels));
            
            if isempty(axesId)
                error('No axis with type label %s can be found.', label);
            elseif length(axesId) < orderOfOccurance
                error('There is more than one axis with type label %s.', label);
            else
                axesId = axesId(orderOfOccurance);
            end;
        end;
        
        function out=end(A,k,n)
            error('"end" cannot be used with Block object indexing.');
        end
        
        function sref = subsref(obj, s)
            switch s(1).type
                case '.'
                    sref = builtin('subsref',obj,s);
                case '()'
                    if length(s) < 2
                        
                        [axisPermutation newSubs] = resolveSubref(obj, s);
                        
                        if length(axisPermutation) < ndims(obj.tensor)
                            axisPermutation = [axisPermutation setdiff(1:ndims(obj.tensor), axisPermutation)];
                        end;
                        
                        permutedTensor = permute(obj.tensor, axisPermutation);
                        
                        newSubs = permute(newSubs, axisPermutation);
                        newS = s;
                        newS.subs = newSubs;
                        sref = builtin('subsref',permutedTensor, newS);
                        return
                    else
                        sref = builtin('subsref',obj,s);
                    end
                case '{}'
                    error('MYDataClass:subsref',...
                        'Not a supported subscripted reference')
            end
        end;
        
        function output = subsasgn(obj, s, input)
            switch s(1).type
                case '.'
                    output = builtin('subsasgn',obj,s, input);
                case '()'
                    if length(s) < 2
                        
                        [axisPermutation newSubs] = resolveSubref(obj, s);
                        
                        permutedTensor = permute(obj.tensor, axisPermutation);
                        
                        newSubs = permute(newSubs, axisPermutation);
                        newS = s;
                        newS.subs = newSubs;
                        permutedTensor = builtin('subsasgn', permutedTensor, newS, input);
                        
                        obj.tensor = ipermute(permutedTensor, axisPermutation);
                        output = obj;
                        return
                    else
                        sref = builtin('subsasgn',obj,s, input);
                    end
                case '{}'
                    error('MYDataClass:subsref',...
                        'Not a supported subscripted reference')
            end
        end;
        
        function newObj = sliceAxes(obj, varargin)
            % Produce a new Block object with input axes
            % and the tensor array sliced to provided axis indices.
            % axis names and their ranges should be provided as
            % 'axis typelabel 1', indices_1, ...
            % for example:
            % 'time', 1:5, 'channel', 5:15s
                        
            if mod(length(varargin), 2) ~= 0 % if an odd number of arguments presented
                error('An even number of arguments, with ''key'', value, ''key'', value.. structure should be provided');
            end;
            
            extendedIndices = {};
            for i=1:(length(varargin)/2)
                j = 1+ (i-1) *2;
                extendedIndices{i} = {varargin{j}, varargin{j+1}};
            end;
            
            %newObj = obj(extendedIndices{:});
            newObj = obj('time', :);
            newObj.setId;
                        
        end;
        
    end
    methods (Access = 'protected')
        function [axisPermutation newSubs] = resolveSubref(obj, s)
            % [axisPermutation newSubs] = resolveSubref(obj, s)
            % s is the structure provided by MATLAb subref function.
            
            typeLabels = axesTypeLabels(obj);
            axisValue = {};
            newSubs = s.subs;
            for i=1:length(s.subs)
                [subrefString, parameters] = Block.extendedIndexToLabel(s.subs{i});
                
                equalVector = cellfun(@(x) isequal(subrefString, x), typeLabels);
                if any(equalVector)
                    axisValue{i} = obj.typeLabelToAxesId(s.subs, i);
                    if isempty(parameters) || strcmpi(parameters{1}, ':')
                        newSubs{i} = ':';
                    else                    
                        if isnumeric(parameters{1})
                            newSubs{i} = parameters{1};
                        elseif ischar(parameters{1})
                            newSubs{i} = str2num(parameters{1});
                        else
                            error('Extended parameter is not a string nor numeric');
                        end;
                    end;
                else
                    axisValue{i} = [];
                    newSubs{i} = s.subs{i};
                end;
            end;
            
            unspecifiedAxisId = cellfun(@isempty, axisValue);
            if sum(unspecifiedAxisId) > 1 &&  sum(unspecifiedAxisId) < length(unspecifiedAxisId)
                error('Either one axis or all axes can be unnamed, e.g. ("time", :) is allowed but ("time", :,:) is not.');
            end;
            
            if any(unspecifiedAxisId)
                inferredUnspecifiedAxis = setdiff(1:length(s.subs), cell2mat(axisValue));
                ids = find(unspecifiedAxisId);
                for i=1:length(ids)
                    axisValue{ids(i)} = inferredUnspecifiedAxis(i);
                end;
            end;
            axisPermutation = cell2mat(axisValue);
        end;
        
    end
    methods (Access = 'protected', Static)
        function [label, parameters] = extendedIndexToLabel(indexVar)
            % converts {'time', 'min', 1, 'max', 5..} to
            % label = 'time' and parameters = {'min', 1, 'max', 5..}
            parameters = {};
            if ischar(indexVar)
                label = indexVar;
            elseif iscell(indexVar)
                label = indexVar{1};
                if length(indexVar) > 1
                    parameters = indexVar(2:end);
                end
                assert(ischar(label), 'The first element in the extended indexing cell array must be a string.');
            else
                label = indexVar;
            end;
        end;
    end;
end
