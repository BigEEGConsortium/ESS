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
    %
    % Axes can be accessed using the syntactic sugar obj.axisTypelabel
    % where axisTypelabel is the type label associated with an obj.axes.
    % only the first axis with the label is returned. For example,
    % obj.time returns the TimeAxis and obj.channel returns ChannelAxis (if
    % exists).
    
    properties
        tensor % a numerical array with any number of dimensions
        axes % a cell array containing axis information for the tensor.
        % the number of of elements should be the same as the number of
        % dimensions of "tensor" field.
    end;
    methods
        function obj = Block(varargin)
            obj = obj@Entity;
            obj = obj.defineAsSubType(mfilename('class'));
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
        
        function [axesTypeLabels, axesCustomLabels, axesIds] = getAxesInfo(obj)
            axesTypeLabels = {};
            axesCustomLabels = {};
            axesIds = {};
            for i=1:length(obj.axes)
                axesTypeLabels{i} = obj.axes{i}.typeLabel;
                axesCustomLabels{i} = obj.axes{i}.customLabel;
                axesIds{i} = obj.axes{i}.id;
            end;
        end;
        
        function axesId = typeLabelToAxesId(obj, allLabels, index)
            % axesId = typeLabelToAxesId(obj, allLabels, index)
            % maps a typeLabel string to the axis item in
            % axes property with the matching typeLabel
            %
            % the second time 'frequency' is used it referes to the second axis with the
            % label 'frequency'.
            
            % extract only axis type labels from extended index syntax,
            % for example {'time', {..}} maps to 'time'
            allLabels = cellfun(@Block.extendedIndexToLabel, allLabels, 'UniformOutput', false);
            
            label = allLabels{index};
            orderOfOccurance = sum(strcmpi(label, allLabels(1:index)));
            
            if nargin < 3
                orderOfOccurance = 1;
            end;
            
            [axesTypeLabels, axesCustomLabels, axesIds] = getAxesInfo(obj);
            
            axesId = find(strcmpi(label, axesTypeLabels) | (strcmpi(label, axesCustomLabels) & ~isempty(axesCustomLabels)) | strcmpi(label, axesIds));
            
            if isempty(axesId)
                error('No axis with type label %s can be found.', label);
            elseif length(axesId) < orderOfOccurance
                error('There is more than one axis with type label %s.', label);
            else
                axesId = axesId(orderOfOccurance);
            end;
        end;
        
        function [axis, id]= getAxis(obj, axisType)
            % [axis, id]= getAxis(obj, axisType)
            axesTypes = obj.axesTypeLabels;
            [wasMember, id]= ismember(axisType, axesTypes);
            if wasMember
                axis = obj.axes{id(1)};
            else
                axis = [];
            end;
        end;
        
        function out=end(A,k,n)
            error('"end" cannot be used with Block object indexing.');
        end
        
        function [sref, varargout]= subsref(obj, s)
            switch s(1).type
                case '.'
                    if length(s) < 2 
                        axesTypes = builtin('subsref',obj,substruct('.', 'getAxesInfo'));
                        [wasMember id]= ismember(s.subs, axesTypes);
                        if wasMember
                            sref = obj.axes{id(1)};
                        else
                            [sref, varargout{1:(nargout-1)}] = builtin('subsref',obj,s);
                        end;
                    else
                        [sref, varargout{1:(nargout-1)}] = builtin('subsref', obj,s);
                    end;
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
        
        function newObj = select(obj, varargin)
            % Produce a new Block object with input axes
            % and the tensor array sliced to provided axis indices.
            % axis names and their ranges should be provided as
            % 'axis typelabel 1', indices_1, ...
            % for example:
            %
            % 'time', 1:5, 'channel', 5:15
            %
            % or the inices should be given as the extended range syntax, for example:
            % 'time', {'range', [-1 1]}, 'channel', 5:15
            
            if mod(length(varargin), 2) ~= 0 % if an odd number of arguments presented
                error('An even number of arguments, with ''key'', value, ''key'', value.. structure should be provided');
            end;
            
            extendedIndices = {};
            providedAxesLabel = {};
            axisSliceMap = containers.Map;
            for i=1:(length(varargin)/2)
                j = 1+ (i-1) *2;
                providedAxesLabel{i} = varargin{j};
                if iscell(varargin{j+1})
                    extendedIndices{i} = [varargin(j), varargin{j+1}];
                else
                    extendedIndices{i} = {varargin{j}, varargin{j+1}};
                end;
                axisSliceMap(varargin{j}) = varargin{j+1};
            end;
            
            % some axis are specified in input, others are assumed to have
            % full  indices, i.e. :
            typeLabels = obj.getAxesInfo;
            remainingAxes = setdiff(typeLabels, providedAxesLabel);
            for i=1:length(remainingAxes)
                extendedIndices{end+1} = {remainingAxes{i}, ':'};
                axisSliceMap(remainingAxes{i}) = ':';
            end;
            
            newObj = obj;
            s = substruct('()',extendedIndices);
            permutedTensor = subsref(newObj,s);
            [axisPermutation newSubs]= resolveSubref(obj, s);
            newObj.tensor = permutedTensor;
            newObj.tensor = ipermute(permutedTensor, axisPermutation); % prevent a change in axis order
            
            % slice axes
            for i=1:length(axisPermutation)
                if i<= length(newSubs)
                    newObj.axes{axisPermutation(i)} = newObj.axes{axisPermutation(i)}(newSubs{i});
                else
                    newObj.axes{axisPermutation(i)} = newObj.axes{axisPermutation(i)}; % for axis where we have implicitly assumed :
                end;
            end;
            
            newObj = setAsNewlyCreated(newObj);
            
        end;
        
        function out = index(obj, varargin)
            out = subsref(obj, substruct('()', varargin));
        end;
        
        function valid = isValid(obj)
            valid = true;
            
            if isempty(obj)
                return ;
            end;
            
            s = size(obj.tensor);
                        
            valid = length(s) == length(obj.axes);
            if ~valid
                fprintf('Number of axis is different than dimensions of tensor\n');
            end;
            
            for i=1:length(s)
                if s(i) ~= obj.axes{i}.length
                    fprintf('Dimension %d of tensor is incompatible with the length of the associated axis of type "%s".\n', i, obj.axes{i}.typeLabel);
                    valid = false;
                end;
            end;
            
            for i=1:length(obj.axes)
                axisIsValid = obj.axes{i}.isValid;
                if ~axisIsValid
                    fprintf('Axis %d (type "%s") is invalid\n', i, obj.axes{i}.typeLabel);
                end;
                valid = valid && axisIsValid;
            end;
        end;
        
        function newObj = horzcat(obj, obj2)
            % concatenates objects via the first axis of type Instance (or subclasses)
            if isempty(obj)
                newObj = obj2;
                return;
            elseif isempty(obj2)
                newObj = obj;
                return;
            end;
            
            if ~obj.isValid || ~obj2.isValid
                error('One or more of the Block-type objects is invalid.');
            end;
            
            if length(obj.axes) ~= length(obj2.axes)
                error('Objects have different number of axes hecnce they cannot be concatenated.');
            end;                        
            
            ObjInstanceAxis = [];
            Obj2InstanceAxis = [];
            objAxisMatchId = nan(length(obj.axes), 1);
            objAxisSubset = {};
            obj2AxisSubset = {};
            intersectAxisObjects = {};
            
            for i=1:length(obj.axes)   
                axisIdsLeft = setdiff(1:length(obj2.axes), objAxisMatchId(~isnan(objAxisMatchId)));
                
                % place the i at first so it has the highst priority for matching.
                iid = find(axisIdsLeft == i);
                if find(iid)
                    t = axisIdsLeft(1);
                    axisIdsLeft(1) = i;
                    axisIdsLeft(iid) = t;
                end;
                
                for j=axisIdsLeft                                      
                    if strcmp(obj.axes{i}.type, obj2.axes{j}.type)                        
                        if  isempty(ObjInstanceAxis) && strfind(obj.axes{i}.type, 'ess:Entity/BaseAxis/InstanceAxis') == 1 % both are of instance axis types
                            objAxisMatchId(i) = j;
                            ObjInstanceAxis = i;
                            Obj2InstanceAxis = j;
                        elseif i ~= ObjInstanceAxis && j ~= Obj2InstanceAxis % do not intersect these with any other axes since they are the ones to be concatenated
                            axis = obj.axes{i};
                            [intersectObj, idObj, idObj2]= axis.intersect(obj2.axes{j});
                            if ~isempty(intersectObj) & isnan(objAxisMatchId(i)) % if that axis has not yeer been matched
                                objAxisMatchId(i) = j;
                                objAxisSubset{i} = idObj;
                                obj2AxisSubset{i} = idObj2;
                                intersectAxisObjects{i} = intersectObj;
                            end;
                        end;
                    end;
                end;
            end;
            
            if any(isnan(objAxisMatchId))
                error('Axis %d of the object %s cannot be matched to any axis of the concatenated object.', find(isnan(objAxisMatchId)), obj.id);
            end;
            
            if isempty(ObjInstanceAxis) || isempty(Obj2InstanceAxis)
                error('No axis of (sub)type ''instance'' found to concatenate objects across.');
            end;
            
            % prepare subindexing cell array for both objects.
            objIndexCell = {};
            obj2IndexCell = {};
            for i=1:length(obj.axes)
                if i~=ObjInstanceAxis
                    objIndexCell{end+1} = obj.axes{i}.id;
                    objIndexCell(end+1) = objAxisSubset(i);
                    
                    obj2IndexCell{end+1} = obj2.axes{i}.id;
                    obj2IndexCell(end+1) = obj2AxisSubset(i);
                end
            end;
            
            newObj = obj.select(objIndexCell{:});
            
            nonInstanceIds = setdiff(1:length(newObj.axes), ObjInstanceAxis);
            newObj.axes(nonInstanceIds) = intersectAxisObjects(nonInstanceIds);
            
            newObj = setAsNewlyCreated(newObj);
            newObj = newObj.setId;
            if ~isequal(obj.description, newObj.description)
                newObj.description = '';
            end
            if ~isequal(obj.custom, newObj.custom)
                newObj.custom = '';
            end;
            
            slicedObj2 = obj2.select(obj2IndexCell{:});
            newObj.tensor = cat(ObjInstanceAxis, newObj.tensor, permute(slicedObj2.tensor, objAxisMatchId));
            newObj.axes{ObjInstanceAxis} = [newObj.axes{ObjInstanceAxis} slicedObj2.axes{Obj2InstanceAxis}];
            
            assert(newObj.isValid, 'The final, concatenated, object is invalid.');
        end;
        
        function itIs = isempty(obj)
            itIs = isempty(obj.tensor);
        end;
    end
    methods (Access = 'protected')
        function [axisPermutation, newSubs] = resolveSubref(obj, s)
            % [axisPermutation newSubs] = resolveSubref(obj, s)
            % s is the structure provided by MATLAb subref function.
            
            [axesTypeLabels, axesCustomLabels, axesIds] = getAxesInfo(obj);
            axisValue = {};
            newSubs = s.subs;
            for i=1:length(s.subs)
                [subrefString, parameters] = Block.extendedIndexToLabel(s.subs{i});
                
                % first match to type labels
                equalVector = cellfun(@(x) isequal(subrefString, x), axesTypeLabels);
                
                % then match custom labels
                equalVector = equalVector | cellfun(@(x) ~isempty(x) && isequal(subrefString, x), axesCustomLabels);

                % then match axis ids
                equalVector =  equalVector | cellfun(@(x) ~isempty(x) && isequal(subrefString, x), axesIds);
                
                if any(equalVector)
                    axisValue{i} = obj.typeLabelToAxesId(s.subs, i);
                    if isempty(parameters) || strcmpi(parameters{1}, ':')
                        newSubs{i} = ':';
                    else
                        if isnumeric(parameters{1})
                            newSubs{i} = parameters{1};
                        elseif ischar(parameters{1})
                            if length(parameters) == 1 % e.g. {'time', '1:10'}
                                newSubs{i} = str2num(parameters{1});
                            else % e.g. {'time', 'range', [-1 1]}
                                newSubs{i} = obj.axes{axisValue{i}}.parseRange(parameters);
                            end
                        else
                            error('Extended parameter is not a string nor numeric');
                        end;
                    end;
                else
                    if iscell(s.subs{i})
                        t = s.subs{i};
                        if ischar(t{1})
                            error('Axis label ''%s'' not recognized', t{1});
                        else
                            error('Axis cell %d index not recognized', i);
                        end;
                    end;
                    axisValue{i} = [];
                    newSubs{i} = s.subs{i};
                end;
            end;
            
            unspecifiedAxisId = cellfun(@isempty, axisValue);
            numberOfSpecifiedAxes = sum(~cellfun(@isempty, axisValue));
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
            
            
            vectorize = length(s.subs) < ndims(obj.tensor) && length(find(unspecifiedAxisId)) > 0;
            % this is to trigger  vectorization, returning a lower number
            % of dimensions than obj.tensor by folding several of them into
            % one. For example  obj('trial', :)
            % where there are less axis specified than tensor dimensions
            % but at least there is one range without explicit label specified (: at the end).
            % obj('trial', :) permutes the trial dimension to be the
            % first and then performs permutedTensor(:,:).
            % Otherwise,for example for obj('trial') or obj({'trial' 2:3})
            % only permutation (and slicing, if requested) is
            % performed but no vectorization, so the number of output
            % dimensions is the same number as obj.tensor.
            
            if length(axisPermutation) < ndims(obj.tensor)
                additionalAxisIDs = setdiff(1:ndims(obj.tensor), axisPermutation);
                axisPermutation = [axisPermutation additionalAxisIDs];
                
                % if numberOfSpecifiedAxes > 1
                if ~vectorize %length(s.subs) > 1
                    
                    for i=1:length(additionalAxisIDs)
                        newSubs{end+1} = ':';
                    end;
                end;
            end;
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
