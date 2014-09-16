%% Generate a comparison of different approaches to preprocessing for a 
% single dataset stored in EEGLAB .set format.
%
%
% Variables assumed set prior to coming in:  
%    indir        Input data directory
%    rootname     File base name
%    outdatadir   Processed data directory
%    outrecdir    Bad channel info directory
%    htmlbase     Html base directory for publishing results
%    linefreqs    Line frequencies to remove (default = [60, 120, 180])
%    EEGchans     Channel numbers of EEG channels
%    rrefchans    Channel numbers of channels which to reference 
%    hpassfreq    High pass frequency in Hz for preprocessing
%    fftchans     Three representative channels to output power spectrum
%    fftwinfac    Window length relative to srate for fft (uses EEGLAB spectopo)
%
%  Outputs produced:
%    x_reffilt.set  EEG for average reference then high pass filter (Mean-High)
%    x_refrecRF.mat Bad channel information for x_reffilt.set
%    x_filt.set     EEG for high pass filter only
%    x_filtref.set  EEG for high pass filter then average reference (Mean-High)
%    x_refrecFR.mat Bad channel information for x_filtref.set
%    x_huber.set    EEG for high pass filter then Huber reference (High-Huber)
%    x_refrec.mat   Bad channel information for x_huber.set
%    x_ref.set      EEG for high pass filter then proposed reference (High-Huber-Recom)
%    x_refrecR.mat  Bad channel information for x_ref.set
%    x_mastref.set  EEG for high pass filter then mastoid reference (High-Mas)
%
fprintf('Standard level 2 comparison for %s....\n', basename);

%% Method 1: High pass -> Remove line noise -> Remove mean -> Find bad channels
fname = [indir filesep basename '.set'];
EEG = pop_loadset(fname);
EEG.data = double(EEG.data);      % We need the precision for rereferencing
EEG = high_pass(EEG, hpassfreq, rrefchans);
EEGhigh = EEG;
g = struct('linefreqs', linefreqs, 'chanlist', rrefchans, 'maxiters', 5);
EEG =  clean_line_noise(EEG, g);
EEG.filename = [basename '_filt.set']; 
EEG.setname = EEG.filename;
EEGfilt = EEG;
save([outdatadir filesep EEG.filename], 'EEG', '-v7.3'); % save as double
pop_saveset(EEG, 'filename', EEG.filename,  ...
    'filepath', outdatadir, 'savemode', 'onefile', 'version', '7.3'); 
clear EEG;

% Now remove the average of EEGchans from the rrefchans
ref_signal_high_aver = mean(EEGfilt.data(EEGchans, :), 1);
EEGfiltref = remove_ref(EEGfilt, rrefchans, ref_signal_high_aver);
refrec = struct('name', basename, 'EEGchans', EEGchans);
refrec = find_bad_channels(EEGfiltref, refrec); 
new_name = [outrecdir filesep basename '_refrecFM.mat'];
save(new_name, 'refrec', '-v7.3'); 

%% Display the results of the bad channel calculation
fprintf('Show bad channels from high pass -> line noise -> average reference\n');
show_bad_channels(refrec, 'High-Line-Mean')

%% Method 2: High pass -> Line -> Remove huber mean -> Find bad channels
EEGhuber = remove_robust_mean(EEGfilt, EEGchans);
EEGhuber.filename = [basename '_huber.set'];
EEGhuber.setname = EEGhuber.filename;
ref_signal_huber = EEGhuber.etc.ref_signal;
refrec = struct('name', basename, 'EEGchans', EEGchans);
refrec = find_bad_channels(EEGhuber, refrec); 
new_name = [outrecdir filesep basename '_huber.mat'];
save(new_name, 'refrec', '-v7.3');

%% Display the results of the bad channel calculation
fprintf('Show bad channels after huber rereferencing\n');
show_bad_channels(refrec, 'High-Line-Huber')

%% Construct new EEG with interpolated channels to find better average reference
fprintf('Interpolating channels\n');
bad_channels = refrec.bad_channels;
EEGtmp = EEGhuber;
EEGtmp.data = EEGtmp.data(refrec.EEGchans, :);
EEGtmp.chanlocs = EEGtmp.chanlocs(refrec.EEGchans);
EEGtmp.nbchan = length(refrec.EEGchans);
chan_array = false(1, EEGhuber.nbchan);
chan_array(bad_channels) = true;
chan_array = chan_array(refrec.EEGchans);
bad_channels_reindexed = find(chan_array);

%% This step is a problem as items are converted to float
EEGtmp = interpolate_channels(EEGtmp, bad_channels_reindexed); 
ref_signal_final = mean(double(EEGtmp.data), 1);
clear EEGtmp;

%% Now remove reference from filtered signal
EEG = remove_ref(EEGfilt, rrefchans, ref_signal_final);
EEG.filename = [basename '_ref.set'];
EEG.setname = EEG.filename;
save([outdatadir filesep EEG.filename], 'EEG', '-v7.3');
pop_saveset(EEG, 'filename', EEG.filename, ...
    'filepath', outdatadir, 'savemode', 'onefile', 'version', '7.3'); 
EEGref = EEG;

%% Now find the final bad channel list
refrec = find_bad_channels(EEG, refrec); 
new_name = [outrecdir filesep basename '_refrecR.mat'];
save(new_name, 'refrec', '-v7.3');

%% Display the results of the bad channel calculation
fprintf('Show bad channels after rereferencing\n');
show_bad_channels(refrec, 'High-Line-Huber-ReRef')

%% Compare average reference to huber robust reference
tString = [basename ': Comparison of reference signals (Huber)'];
figure('Name', tString)
plot(ref_signal_high_aver', ref_signal_huber', '.k')
title(tString, 'Interpreter', 'none');
xlabel('High pass then aver ref')
ylabel('High pass then Huber ref')

% Compare average reference of complete process to high then mean
tString = [basename ': Comparison of reference signals (complete)'];
figure('Name', tString)
plot(ref_signal_high_aver', ref_signal_final', '.k')
title(tString, 'Interpreter', 'none');
xlabel('High pass then aver ref')
ylabel('Complete process')

%% Plot maximum absolute difference in signals for proposed versus average
diffave = max(abs(EEGref.data(EEGchans, :) - EEGfiltref.data(EEGchans, :)));
tsec = (0:length(diffave) - 1)/EEGfiltref.srate;
tString = [basename ': Signal difference between proposed and filter then reference\n'];
figure('Name', tString)
plot(tsec, diffave, '.k')
xlabel('Seconds')
ylabel('Max absolute difference')
title(tString, 'Interpreter', 'none');
pos = get(gcf, 'Position');
pos(3) = maxWidth;
set(gcf, 'Position', pos);

%% Histogram maximum absolute difference in signals for proposed versus average
tString = [basename ': Signal difference between proposed and averaged'];
figure('Name', tString)
hist(diffave', 100)
xlabel('Max absolute difference')
title(tString, 'Interpreter', 'none');
                      
%% Show spectra at selected channels
showChans = fftchans;
refrecName = [outrecdir filesep basename '_refrecR.mat'];
load(refrecName);
corrChan = setdiff(refrec.bad_by_corr, refrec.bad_by_amp);
if ~isempty(refrec.bad_by_amp)
    showChans(2) = refrec.bad_by_amp(1);
end
if ~isempty(corrChan)
    showChans(3) = corrChan(1);
end

for k = 1:length(showChans)
    fftchan = showChans(k);
    [sfiltref,ffiltref]= spectopo(EEGfiltref.data(fftchan, :), ...
        size(EEGfiltref.data, 2), EEGfiltref.srate, ...
        'freqfac', 4, 'winsize', fftwinfac*EEGfiltref.srate, 'plot', 'off');
    [sref, fref]= spectopo(EEGref.data(fftchan, :), ...
        size(EEGref.data, 2), EEGref.srate, ...
        'freqfac', 4, 'winsize', fftwinfac*EEGref.srate, 'plot', 'off');
    [sfilt, ffilt]= spectopo(EEGfilt.data(fftchan, :), ...
        size(EEGfilt.data, 2), EEGfilt.srate, ...
        'freqfac', 4, 'winsize', fftwinfac*EEGfilt.srate, 'plot', 'off');
     [shigh, fhigh]= spectopo(EEGhigh.data(fftchan, :), ...
        size(EEGhigh.data, 2), EEGhigh.srate, ...
        'freqfac', 4, 'winsize', fftwinfac*EEGhigh.srate, 'plot', 'off');
    [shuber, fhuber]= spectopo(EEGhuber.data(fftchan, :), ...
        size(EEGhuber.data, 2), EEGfilt.srate, ...
        'freqfac', 4, 'winsize', fftwinfac*EEGhuber.srate, 'plot', 'off');
    tString = ['Comparison of specta at electrode ' num2str(fftchan) ...
               ' (' EEGref.chanlocs(fftchan).labels ')'];
    figure('Name', tString)
    hold on
    plot(fhigh, shigh, 'c')
    plot(ffilt, sfilt, 'b')
    plot(ffiltref, sfiltref, 'k')
    plot(fhuber, shuber, 'g')
    plot(fref, sref, 'r')
    hold off
    set(gca, 'XLim', [0, 100])
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title(tString)
    legend('High', 'High-line', 'High-line-mean', 'High-line-Huber', 'Proposed')
    
    figure('Name', tString)
    hold on
    plot(fhigh, shigh, 'c')
    plot(ffilt, sfilt, 'b')
    plot(ffiltref, sfiltref, 'k')
    plot(fhuber, shuber, 'g')
    plot(fref, sref, 'r')
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title(tString)
    legend('High', 'High-line', 'High-line-mean', 'High-line-Huber', 'Proposed')
end