classdef Block < Entity
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
        
        function sref = subsref(obj, s)
            switch s(1).type
                case '.'
                    sref = builtin('subsref',obj,s);
                case '()'
                    if length(s) < 2
                                                
                        [axisPermutation newSubs] = resolveSubref(obj, s);                        
                        
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
        
    end
    methods (Access = 'protected')
        function [axisPermutation newSubs] = resolveSubref(obj, s)
            typeLabels = axesTypeLabels(obj);
            axisValue = {};
            newSubs = s.subs;
            for i=1:length(s.subs)
                equalVector = cellfun(@(x) isequal(s.subs{i}, x), typeLabels);
                if any(equalVector)
                    axisValue{i} = obj.typeLabelToAxesId(s.subs, i);
                    newSubs{i} = ':';
                else
                    axisValue{i} = [];
                    newSubs{i} = s.subs{i};
                end;
            end;
            
            unspecifiedAxisId = cellfun(@isempty, axisValue);
            if sum(unspecifiedAxisId) > 1
                error('only one axis can be unnamed, e.g. ("time", :) is allowed but ("time", :,:) is not.');
            end;
            
            if any(unspecifiedAxisId)
                inferredUnspecifiedAxis = setdiff(1:length(s.subs), cell2mat(axisValue));
                axisValue{find(unspecifiedAxisId)} = inferredUnspecifiedAxis;
            end;
            axisPermutation = cell2mat(axisValue);
        end;
    end;
end
