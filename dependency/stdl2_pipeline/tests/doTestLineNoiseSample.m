% 
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'K:\\CTAData\\SAMPLE'; % Input data directory used for this demo

EEGchans = 1:32;
hpassfreq = 1;             % High pass frequency in Hz
linefreqs = 60;
rrefchans = 1:32;          % Applying the average reference to these
fftchans = [1, 12, 28];    % Pick 3 channels -- first should be Cz
basename = 'sample';
fftwinfac = 4;
fname = [indir filesep basename '.set'];

EEG = pop_loadset(fname);

%%
EEG.data = double(EEG.data);      % We need the precision for rereferencing
EEG = highPassFilter(EEG, hpassfreq, rrefchans);

%% Calculate the spectrum at selected channels prior to removing line noise
showChans = fftchans;
sreforig = cell(length(showChans), 1);
freforig = cell(length(showChans), 1);
for k = 1:length(showChans)
    fftchan = showChans(k);
    [sreforig{k},freforig{k}]= spectopo(EEG.data(fftchan, :), ...
        size(EEG.data, 2), EEG.srate, ...
        'freqfac', 4, 'winsize', ...
        fftwinfac*EEG.srate, 'plot', 'off');
end
%%
% g = struct('linefreqs', 60, 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
       g = struct('linefreqs', 60, 'fscanbw', 2, ...
           'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);

% g = struct('linefreqs', [], 'fscanbw', [], 'p', 0.1, 'multipleComparisons', 1, ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
%EEG =  cleanLineNoise(EEG, g);
[EEG, originalSpectrum, cleanedSpectrum, f, amps, ...
    freqs, significantFrequencyCount] = cleanLineNoise(EEG, g);
%% Show spectra at selected channels
showChans = fftchans;
sref = cell(length(showChans), 1);
fref = cell(length(showChans), 1);
for k = 1:length(showChans)
    fftchan = showChans(k);
    [sref{k},fref{k}]= spectopo(EEG.data(fftchan, :), ...
        size(EEG.data, 2), EEG.srate, ...
        'freqfac', 4, 'winsize', ...
        fftwinfac*EEG.srate, 'plot', 'off');
end
tString = [basename ': power spectra for channel '];

for k = 1:length(showChans)
    figure('Name', tString)
    hold on
    plot(freforig{k}, sreforig{k}, 'k')
    plot(fref{k}, sref{k}, 'r')
    hold off
    set(gca, 'XLim', [0, 100])
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    legend('Original', 'Cleaned')
    title([tString num2str(showChans(k)) ' frequencies [1 100]'])
end
for k = 1:length(showChans)
    figure('Name', tString)
    hold on
    plot(freforig{k}, sreforig{k}, 'k')
    plot(fref{k}, sref{k}, 'r')
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    legend('Original', 'Cleaned')
    title([tString num2str(showChans(k))])
end
