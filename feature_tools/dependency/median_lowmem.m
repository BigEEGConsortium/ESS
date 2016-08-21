function y = median_lowmem(varargin)
% y = median_lowmem(varargin)
% same arguments as median but subsamples the first dimension if memoery error
% currenrly only works with dim ==1
try
    y = median(varargin{:});
catch e
    try
        if nargin > 1 && varargin{2} ~= 1
            error('Using this function with dim ~= 1 is not yet supported');
        end;
        y = median(varargin{1}(1:2:end,:), varargin{2:end});
    catch
        y = median(varargin{1}(1:5:end,:), varargin{2:end});
    end
end;