function  [reference] = findNoisyChannels(signal, reference)
% Identify bad channels in EEG using a two-stage approach
%
% noisyParameters = findNoisyChannels(signal)
% noisyParameters = findNoisyChannels(signal, noisyParameters)
%
% First remove bad channels by amplitude, noise level, and correlation
% Apply ransac after these channels have been removed.
%
% Input parameters:
%     signal - structure with srate, chanlocs, chaninfo, and data fields
%     noisyParameters - structure with input parameters and results
%
%  Notes: the signal is assumed to be high-passed. Removing line noise
%  is a good idea too.
%
%  noisyParameters: (fields to be filled on input are indicated)
%     name - name of the input file
%     srate - sample rate in HZ
%     samples - number of samples in the data
%     referenceChannels - a vector of channels to use
%     chaninfo - standard EEGLAB chaninfo (nose direction is relevant)
%     chanlocs - standard EEGLAB chanlocs structure
%     robustDeviationThreshold - z score cutoff of robust channel deviation
%     highFrequencyNoiseThreshold -  z score cutoff of SNR (signal above 50 Hz)
%     correlationWindowSize - correlation window size in seconds (default = 1 sec)
%     correlationThreshold - correlation below which window is bad (default = 0.4)
%     badTimeThreshold - cutoff fraction of bad corr windows (default = 0.01)
%     ransacSampleSize - samples for computing ransac (default = 50)
%     ransacChannelFraction - fraction of channels for robust reconstruction (default = 0.25)
%     ransacThreshold - cutoff correlation for abnormal wrt neighbors(default = 0.75)
%     ransacUnbrokenTime - cutoff fraction of time channel can be bad (default = 0.4)
%     ransacWindowSize - correlation window for ransac (default = 5 sec)
%     doRansacAfterBadRemoval - if true, bad channels from methods 1-3 removed
%                     before ransac (default = true)
%
% Output paramters (c channels, w windows):
%    noisyChannels - list of identified bad channel numbers
%    badChannelsFromCorrelation  - list of bad channels identified by correlation
%    badChannelsFromDeviation   - list of bad channels identified by amplitude
%    badChannelsFromHFNoise - list of bad channels identified by SNR
%    badChannelsFromRansac - list of channels identified by ransac
%    fractionBadCorrelationWindows - c x 1 vector with fraction of bad correlation windows
%    robustChannelDeviation - c x 1 vector with robust measure of average channel deviation
%    zscoreHFNoise - c x 1 vector with measure of channel noise level
%    maximumCorrelations - w x c array with max window correlation
%    ransacCorrelations = c x wr array with ransac correlations
%
% This function uses 4 methods for detecting bad channels:
%
% Method 1: too low an SNR. If the z score of estimate of signal above
%           50 Hz to that below 50 Hz above highFrequencyNoiseThreshold, the channel
%           is considered to be bad.
%
% Method 2: low correlation with other channels. Here correlationWindowSize is the window
%           size over which the correlation is computed. If the maximum
%           correlation of the channel to the other channels falls below
%           correlationThreshold, the channel is considered bad in that window.
%           If the fraction of bad correlation windows for a channel
%           exceeds badTimeThreshold, the channel is marked as bad.
%
% Method 3: too low or high amplitude. If the z score of robust
%           channel deviation falls below robustDeviationThreshold, the channel is
%           considered to be bad.
%
% After the channels from methods 2 and 3 are removed, method 4 is
% computed on the remaining signals
%
% Method 4: each channel is predicted using ransac interpolation based
%           on a ransac fraction of the channels. If the correlation of
%           the prediction to the actual behavior is too low for too
%           long, the channel is marked as bad.
%
% Assumptions:
%  - The signal is a structure of continuous data with data, srate, chanlocs,
%    and chaninfo fields.
%  - The signal.data has been high pass filtered.
%  - No segments of the EEG data have been removed

% Methods 1 and 4 are adapted from code by Christian Kothe and Methods 2
% and 3 are adapted from code by Nima Bigdely-Shamlo
%
%% Check the incoming parameters
if nargin < 1
    error('findNoisyChannels:NotEnoughArguments', 'requires at least 1 argument');
elseif isstruct(signal) && ~isfield(signal, 'data')
    error('findNoisyChannels:NoDataField', 'requires a structure data field');
elseif size(signal.data, 3) ~= 1
    error('findNoisyChannels:DataNotContinuous', 'data must be a 2D array');
elseif nargin < 2
    reference = struct();
end

%% Set the defaults as needed
[reference, srate] = getSignalParameters(reference, 'srate', signal, 'srate', 1);
reference = getStructureParameters(reference, 'samples', size(signal.data, 2));
[reference, referenceChannels] = getStructureParameters(reference, 'referenceChannels', 1:size(signal.data, 1));
reference = getSignalParameters(reference, 'chaninfo', signal, 'chaninfo', []);
[reference, chanlocs] = getSignalParameters(reference, 'chanlocs', signal, 'chanlocs', []);
[reference, robustDeviationThreshold] = getStructureParameters(reference, 'robustDeviationThreshold', 5);
[reference, highFrequencyNoiseThreshold] = getStructureParameters(reference, 'highFrequencyNoiseThreshold', 4);
[reference, correlationWindowSize] = getStructureParameters(reference, 'correlationWindowSize', 1);
[reference, correlationThreshold] = getStructureParameters(reference, 'correlationThreshold', 0.4);
[reference, badTimeThreshold] = getStructureParameters(reference, 'badTimeThreshold', 0.01);
[reference, ransacSampleSize] = getStructureParameters(reference, 'ransacSampleSize', 50);
[reference, ransacChannelFraction] = getStructureParameters(reference, 'ransacChannelFraction', 0.25);
[reference, ransacThreshold] = getStructureParameters(reference, 'ransacThreshold', 0.75);
[reference, ransacUnbrokenTime] = getStructureParameters(reference, 'ransacUnbrokenTime', 0.4);
[reference, ransacWindowSize] = getStructureParameters(reference, 'ransacWindowSize', 5);
[reference, doRansacAfterBadRemoval] = getStructureParameters(reference, 'doRansacAfterBadRemoval', true);

%% Set the computed fields to be empty
fields = {'noisyChannels',  'badChannelsFromCorrelation','badChannelsFromDeviation', ...
    'badChannelsFromHFNoise', 'badChannelsFromRansac', 'maximumCorrelations', ...
    'ransacCorrelations', 'robustChannelDeviation', 'zscoreHFNoise', 'fractionBadCorrelationWindows'};
reference = initfields(reference, fields, []);

%% Extact the data required
channels = sort(referenceChannels);      % Make sure channels are sorted
data = signal.data;
orig_nbchans = size(data, 1);          % Save the original channels
data = double(data(channels, :));      % Remove the unneeded channels
[C, S] = size(data);

%% Method 1: Compute the SNR (based on Christian Kothe's clean_channels)
% Note: RANSAC uses the filtered values X of the data
% fprintf('Computing signal to noise ratio\n');
% if srate > 100
%     Remove signal content above 50Hz
%     B = design_fir(100,[2*[0 45 50]/srate 1],[1 1 0 0]);
%     X = zeros(S, C);
%     for k = C:-1:1
%         X(:,k) = filtfilt_fast(B, 1, data(k,:)'); end
%     Determine z-scored level of EM noise-to-signal ratio for each channel
%     noisiness = mad(data'- X, 1)./mad(X, 1);
%     zscoreHFNoiseTemp = (noisiness - median(noisiness)) ./ (mad(noisiness, 1)*1.4826);
%     noise_mask = zscoreHFNoiseTemp > highFrequencyNoiseThreshold;
%     Remap channels to original numbering
%     reference.badChannelsFromHFNoise  = channels(noise_mask);
% else
    X = data';
    zscoreHFNoiseTemp = zeros(C, 1);
    reference.badChannelsFromHFNoise = [];
% end

% Remap the channels to original numbering for the zscoreHFNoise
% reference.zscoreHFNoise = zeros(1, orig_nbchans);
% reference.zscoreHFNoise(channels) = zscoreHFNoiseTemp;

%% Method 2: Global correlation criteria (from Nima Bigdely-Shamlo)
% fprintf('Computing overall minimum max correlation\n');
% win_frames = correlationWindowSize * signal.srate;
% num_windows = floor(size(X, 1) / win_frames);
% frame_inc = round(win_frames / 2); % Half number of frames on each side
% reject_channels = ones(num_windows, C);
% for i = 2:(num_windows - 2) % Ignore last two time windows to stay in range
%     eegPortion = X((i*(win_frames - 1) - frame_inc): ...
%         (i*(win_frames - 1) + frame_inc), :);
%     window_corr = corrcoef(eegPortion);
%     abs_corr = abs(window_corr - diag(diag(window_corr)));
%     max_abs_corr = quantile(abs_corr, 0.98);
%     reject_channels(i, :)  = max_abs_corr;
% end;
% fprintf('Finishing with the correlation computation\n'); 
% reference.maximumCorrelations = ones(num_windows, orig_nbchans);
% reference.maximumCorrelations(:, channels) = reject_channels;
% thresh_channels = reference.maximumCorrelations < correlationThreshold;
% fractionBadCorrelationWindows = mean(thresh_channels(2:(num_windows-2), :), 1);
% fprintf('Remapping\n');
% % Remap channels to their original numbers
% reference.badChannelsFromCorrelation = find(fractionBadCorrelationWindows > badTimeThreshold);
% 
% %% Method 3: Unusually high or low amplitude (using robust std)
% fprintf('Computing large amplitude deviations\n');
% channel_sd =  0.7413 *iqr(data');
% 
% % Estimate the std of the distribution of channel amplitudes (estimated by their standrad deviations)
% % using the inter-quantile distance which is more robust to outliers
% channel_std_est =  0.7413 * iqr(channel_sd);
% 
% % Median used instead of mean to be more robust to bad channel STDs
% reference.robustChannelDeviation = zeros(1, orig_nbchans);
% reference.robustChannelDeviation(channels) = ...
%     (channel_sd - median(channel_sd)) / channel_std_est;
% 
% % Channels with amplitude far from robustDeviationThreshold std. from mean channel powers are unusual (bad).
% reference.badChannelsFromDeviation = ...
%     find(abs(reference.robustChannelDeviation) > robustDeviationThreshold);
% 
% %% Bad so far by amplitude and correlation (take these out before doing ransac)
% noisyChannels = union(reference.badChannelsFromDeviation, ...
%     reference.badChannelsFromCorrelation);

noisyChannels = [];

%% Method 4: Ransac corelation
fprintf('Computing ransac comparison of actual to predicted correlation\n');
% Setup for ransac (if a 2-stage algorithm, remove other bad channels first)
if isempty(chanlocs)
    warning('find_noisyChannels:noChannelLocation', ...
        'ransac could not be computed because there were no channel locations');
else
    if doRansacAfterBadRemoval
        [channels_ransac, idiff] = setdiff(channels, noisyChannels);
        X = X(:, idiff);
        fprintf('Removing previously detected %d bad channels\n', ...
            length(noisyChannels));
    else
        channels_ransac = channels;
    end
    
    % Calculate the parameters for ransac
    ransac_subset = round(ransacChannelFraction*size(data, 1));
    if ransacUnbrokenTime < 0
        error('find_noisyChannels:BadUnbrokenParameter', ...
            'ransacUnbrokenTime must be greater than 0');
    elseif ransacUnbrokenTime < 1
        ransacUnbrokenTime = S*ransacUnbrokenTime;
    else
        ransacUnbrokenTime = srate*ransac_time;
    end
    
    window_len = ransacWindowSize*srate;
    wnd = 0:(window_len - 1);
    offsets = 1:window_len:(S-window_len);
    W = length(offsets);
    nchanlocs = chanlocs(channels_ransac);
    
    
    % Calculate all-channel reconstruction matrices from random channel subsets
    locs = [cell2mat({nchanlocs.X}); cell2mat({nchanlocs.Y});cell2mat({nchanlocs.Z})];
    if isempty(locs)
        error('find_noisyChannels:EmptyChannelLocations', ...
            'The signal chanlocs must have nonempty X, Y, and Z components');
    end
    P = hlp_microcache('cleanchans', @calc_projector, locs, ...
        ransacSampleSize, ransac_subset);
    ransacCorrelationsT = zeros(length(locs), W);
    
    % Calculate each channel's correlation to its RANSAC reconstruction for each window
    for k = 1:W
        XX = X(offsets(k)+ wnd, :);
        YY = sort(reshape(XX*P, length(wnd), length(channels_ransac), ransacSampleSize),3);
        YY = YY(:, :, round(end/2));
        ransacCorrelationsT(:, k) = sum(XX.*YY)./(sqrt(sum(XX.^2)).*sqrt(sum(YY.^2)));
    end
    
    reference.ransacCorrelations = ones(orig_nbchans, W);
    reference.ransacCorrelations(channels_ransac, :) = ransacCorrelationsT;
    flagged = reference.ransacCorrelations < ransacThreshold;
    reference.badChannelsFromRansac = find(sum(flagged, 2)*window_len > ransacUnbrokenTime)';
    
    fprintf('%d bad ransac channels\n', length(reference.badChannelsFromRansac));
end


% Combine bad channels detected from all methods
noisyChannels = union(noisyChannels, ...
    union(reference.badChannelsFromRansac, reference.badChannelsFromHFNoise));
reference.noisyChannels = noisyChannels;


%% Helper functions for findNoisyChannels
function P = calc_projector(locs, num_samples, subset_size)
% Calculate a bag of reconstruction matrices from random channel subsets
stream = RandStream('mt19937ar', 'Seed', 435656);
rand_samples = {};
for k = num_samples:-1:1
    tmp = zeros(size(locs, 2));
    subset = randsample(1:size(locs,2), subset_size,stream);
    tmp(subset, :) = real(spherical_interpolate(locs(:, subset), locs))';
    rand_samples{k} = tmp;
end
P = horzcat(rand_samples{:});

function Y = randsample(X, num, stream)
Y = zeros(1, num);
for k = 1:num
    pick = round(1 + (length(X)-1).*rand(stream));
    Y(k) = X(pick);
    X(pick) = [];
end

function mystruct = initfields(mystruct, fields, value)
% Initializes the specified list of fields in mystruct to value
for k = 1:length(fields)
    mystruct.(fields{k}) = value;
end

