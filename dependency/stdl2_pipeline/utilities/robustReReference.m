function [signal, reference] = robustReReference(signal, reference, verbose)

% if nargin < 1
%     error('cleanLineNoise:NotEnoughArguments', 'requires at least 1 argument');
% elseif isstruct(signal) && ~isfield(signal, 'data')
%     error('cleanLineNoise:NoDataField', 'requires a structure data field');
% elseif size(signal.data, 3) ~= 1
%     error('cleanLineNoise:DataNotContinuous', 'signal data must be a 2D array');
% elseif size(signal.data, 2) < 2
%     error('cleanLineNoise:NoData', 'signal data must have multiple points');
% elseif ~exist('lineNoise', 'var') || isempty(lineNoise)
%     lineNoise = struct();
% elseif isempty(lineNoise) || ~isstruct(lineNoise)
%     error('cleanLineNoise:NoData', 'second argument must be a structure')
% end
% if ~exist('verbose', 'var')
%     verbose = true;
% end
reference.averageReferenceWithNoisyChannels = ...
                mean(signal.data(reference.referenceChannels, :), 1);

%% Now remove the huber mean and find the channels that are still noisy
[signalTmp, reference.robustMean, reference.robustChannels] = ...
                  removeRobustMean(signal, reference.referenceChannels);
reference = findNoisyChannels(signalTmp, reference); 

%% Construct new EEG with interpolated channels to find better average reference
fprintf('Interpolating channels\n');
signalTmp.data = signalTmp.data(reference.referenceChannels, :);
signalTmp.chanlocs = signalTmp.chanlocs(reference.referenceChannels);
signalTmp.nbchan = length(reference.referenceChannels);
noisyChannels = reference.noisyChannels;
if ~isempty(noisyChannels)
    channelMask = false(1, size(signal.data, 1));
    channelMask(noisyChannels) = true;
    channelMask = channelMask(reference.referenceChannels);
    noisyChannelsReindexed = find(channelMask);
    signalTmp = interpolateChannels(signalTmp, noisyChannelsReindexed);
end
reference.averageReference = mean(double(signalTmp.data), 1);
clear signalTmp;

%% Now remove reference from filtered signal
signal = removeReference(signal, reference.averageReference, ...
                      reference.reReferencedChannels);

%% Now find the final bad channel list
noisyParametersTemp = findNoisyChannels(signal, reference); 
reference.channelsStillBadAfterInterpolation = noisyParametersTemp.noisyChannels;

