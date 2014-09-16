function [] = showNoisyChannels(noisyParameters, msg)
% A function that outputs information and graphs about the noisy channel removal
    bad_corr_sym = 'c';
    bad_amp_sym = '+';
    bad_noise_sym = 'x';
    bad_ransac_sym = '?';
    
    in_name = noisyParameters.name;
    chanlocs = noisyParameters.channelLocations;
    chaninfo = noisyParameters.channelLocations;
    reference = noisyParameters.reference;
    referenceChannels = reference.referenceChannels;
    
    % Output the parameters of the algorithms
    fprintf('\n\tAlgorithm parameters for %s:\n', msg);
    fprintf('\tamp_thresh: %d z score cutoff of robust channel deviation\n', ...
        reference.robustDeviationThreshold);
    fprintf('\tnoise_thresh: %d z score cutoff of SNR (signal above 50 Hz\n', ...
        reference.highFrequencyNoiseThreshold);
    fprintf('\tcorr_win: %d correlation window size in seconds (default = 1 sec)\n', ...
        reference.correlationWindowSize);
    fprintf('\tcorr_thresh: %d correlation below which window is bad (default = 0.4)\n', ...
        reference.correlationThreshold);
    fprintf('\tbad_time_thresh: %d cutoff fraction of bad corr windows (default = 0.01)\n', ...
        reference.badTimeThreshold);
    fprintf('\transac_samples: %d samples for computing ransac (default = 50)\n', ...
        reference.ransacSampleSize);
    fprintf('\transac_frac: %d fraction of channels for robust reconstruction (default = 0.25)\n', ...
        reference.ransacChannelFraction);
    fprintf('\transac_thresh: %d cutoff correlation for abnormal wrt neighbors(default = 0.85)\n', ...
        reference.ransacThreshold);
    fprintf('\transac_unbroken: %d cutoff fraction of time channel can be bad (default = 0.4)\n', ...
        reference.ransacUnbrokenTime);
    fprintf('\transac_win: %d correlation window for ransac (default = 5 sec)\n', ...
        reference.ransacWindowSize);

    % Output the information
    fprintf('\n\tEEG channels:     [%s]\n', num2str((referenceChannels)));
    fprintf('\n\tBad channels:     [%s]\n', num2str((reference.noisyChannels)));
    fprintf('\tBad by deviation:   [%s]\n', num2str((reference.badChannelsFromDeviation)));
    fprintf('\tBad by HF noise:    [%s]\n', num2str((reference.badChannelsFromHFNoise)));
    fprintf('\tBad by correlation: [%s]\n', num2str((reference.badChannelsFromCorrelation)));
    fprintf('\tBad by ransac:      [%s]\n', num2str((reference.badChannelsFromRansac)));
  
    % Set the bad channel labels
    for j = reference.badChannelsFromCorrelation
        chanlocs(j).labels = [chanlocs(j).labels bad_corr_sym];
    end
    for j = reference.badChannelsFromDeviation
        chanlocs(j).labels = [chanlocs(j).labels bad_amp_sym];
    end
    
    for j = reference.badChannelsFromHFNoise
        chanlocs(j).labels = [chanlocs(j).labels bad_noise_sym];
    end
    
    for j = reference.badChannelsFromRansac
        chanlocs(j).labels = [chanlocs(j).labels bad_ransac_sym];
    end
    
    good_chans = setdiff(referenceChannels, (reference.noisyChannels)');
    for j = good_chans
        chanlocs(j).labels = ' ';
    end
    
    fprintf('\n\tBad channel breakdown: \n')
    fprintf('\tAmp:%s noise:%s corr:%s ransac:%s\n', bad_amp_sym, ...
        bad_noise_sym, bad_corr_sym, bad_ransac_sym);
    fprintf('\tBad by robust deviation:   [%s]\n', ...
        chanstring(chanlocs, reference.badChannelsFromDeviation));
    fprintf('\tBad by noise:       [%s]\n', ...
        chanstring(chanlocs, reference.badChannelsFromHFNoise));
    fprintf('\tBad by correlation: [%s]\n', ...
        chanstring(chanlocs, reference.badChannelsFromCorrelation));
    fprintf('\tBad by ransac:      [%s]\n', ...
        chanstring(chanlocs, reference.badChannelsFromRansac));
    
    % Plot the topoplot of the robust channel deviation
    echans = chanlocs(referenceChannels);
    tString = ['Robust channel deviation (' msg '): ' in_name];
    figure('Name', tString)
    try
    topoplot(reference.robustChannelDeviation(referenceChannels), echans, 'style', 'map', ...
        'electrodes', 'ptslabels','chaninfo',chaninfo);
    title(tString, 'Interpreter', 'none')
    colorbar
    catch mex
        warning(['Distance to mean ' in_name ' topoplot failed: ' ...
            mex.message]);
    end
    
    
    % Plot the topoplot of the robust channel deviation
    tString = ['Noise z-score(' msg '): ' in_name];
    figure('Name', tString)
    try
    topoplot(reference.zscoreHFNoise(reference.referenceChannels), echans, 'style', 'map', ...
        'electrodes', 'ptslabels', 'chaninfo', chaninfo);
    title(tString, 'Interpreter', 'none')
    colorbar
        catch mex
        warning(['Znoise ' in_name ' topoplot failed: ' ...
            mex.message]);
    end
    
%     plotScalpMap(, chanlocs, 'cubic', ...
%     true, [0.75, 0.75, 0.75], [0 0 0]); 
    
    % Plot the median correlation among windows by channel
    chancor = median(reference.maximumCorrelations(2:end-2, :)); 
    tString = ['Median max correlation(' msg '): ' in_name];
    figure('Name', tString)
    try
    topoplot(chancor(referenceChannels), echans, 'style', 'map', ...
        'electrodes', 'ptslabels','chaninfo',chaninfo, ...
        'maplimits', [0.4, 1]);
    title(tString, 'Interpreter', 'none')
    colorbar
    catch mex
        warning(['Median correlation ' in_name ' topoplot failed: ' ...
            mex.message]);
    end
    
    % Plot the length of ransac unbroken
    flagged = reference.ransacCorrelations < reference.ransacThreshold;
    flagged_frac = sum(flagged, 2)/size(flagged, 2);
    tString = ['Fraction of ransac windows with low correlation(' msg '): ' in_name];
    figure('Name', tString)
    try
    topoplot(flagged_frac(referenceChannels), echans, 'style', 'map', ...
        'electrodes', 'ptslabels','chaninfo',chaninfo, ...
        'maplimits', [0.0, 1]);
    title(tString, 'Interpreter', 'none')
    colorbar
    catch mex
        warning(['Ransac correlation ' in_name ' topoplot failed: ' ...
            mex.message]);
    end

function s = chanstring(chanlocs, chanlist)
% Construct a string of channel names from a channel list

if isempty(chanlist)
    s = '';
else
    s = chanlocs(chanlist(1)).labels;
    
    for k = 2:length(chanlist)
        s = [s ' ' chanlocs(chanlist(k)).labels]; %#ok<AGROW>
    end
end
