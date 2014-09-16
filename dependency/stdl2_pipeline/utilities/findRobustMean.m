function robustMean = findRobustMean(EEG, referenceChannels, iterations)
% Calculate the Huber robust mean from an EEGLAB EEG structure
%
% robustMean = findRobustMean(EEG)
% robustMean = findRobustMean(EEG, referenceChannels)
% robustMean = findRobustMean(EEG, referenceChannels, iterations)
%
% Input:
%   EEG          EEGLAB EEG structure  (assumes only a 2D data field)
%   referenceChannels:  vector of data row numbers for which to remove mean
%              (default is to use all the rows)
%   iterations: Number of iterations to use in the huber mean calculation
%              (default is 100 iterations)
%
% Output:
%   robustMean   the robust mean of each frame.
%
% This function calculates a robust channel mean based on the row (channel)
% numbers in referenceChannels. 
%
% Adapted from code by Christian Kothe
%
%% PRocess the arguments
if nargin < 1 || ~isstruct(EEG)
    error('findRobustMean:NotEnoughArguments', ...
          'first argument must be a structure');
elseif ~exist('referenceChannels', 'var') || isempty(referenceChannels)
    referenceChannels = 1:size(EEG.data, 1); 
end

if ~exist('iterations', 'var') || isempty(iterations)
    iterations = 100; 
end

%% find the robust mean
data = EEG.data(referenceChannels, :);
huberCut = median(median(abs(bsxfun(@minus, data, median(data, 2))),2))*1.4826;
robustMean = calculateHuberMean(data/huberCut, 1, iterations)*huberCut;


