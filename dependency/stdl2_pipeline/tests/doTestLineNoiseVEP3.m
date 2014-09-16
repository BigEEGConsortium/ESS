% 
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\VEP'; % Input data directory used for this demo
basename = 'vep_03';
     % Channels to compute reference on
                % Channels to rereference at the end
%fftchans = [ 28, 42, 48, 52, 58 ];   % Pick 3 channels for spectral display
%fftchans = 48;
fftchans = 1:5;   
linefreqs = [60, 120,  180, 212, 240];

%% Load the original data, high-pass and save
% fname = [indir filesep basename '.set'];
% pop_editoptions('option_single', false, 'option_savetwofiles', false);
% EEG = pop_loadset(fname);
% EEG.data = double(EEG.data);      % We need the precision for rereferencing
% rrefchans = 1:size(EEG.data, 1);
% EEG = highPassFilter(EEG, hpassfreq, rrefchans);
% fname = [indir filesep basename '.mat'];
% save(fname, 'EEG', '-v7.3');

%% Load the high-passed data
fname = [basename '.mat'];
load(fname);
rrefchans = fftchans;
%% Calculate the spectrum at selected channels prior to removing line noise
lineNoise = struct('Fs', EEG.srate, 'lineFrequencies', linefreqs, ...
                   'fscanbw', 2, 'pad', 0, 'noiseChannels', rrefchans, ...
                   'maximumNoiseIterations', 10);
[EEG1, lineNoise] = cleanLineNoise(EEG, lineNoise, false);

%% Show spectra at selected channels
fftwinfac = 4;
for k = 1:length(fftchans)
     fftchan = fftchans(k);
    [sreforig, freforig]= spectopo(EEG.data(fftchan, :), ...
        size(EEG.data, 2), EEG.srate, ...
        'freqfac', 4, 'winsize', ...
        fftwinfac*EEG.srate, 'plot', 'off');
     [sref, fref]= spectopo(EEG1.data(fftchan, :), ...
        size(EEG.data, 2), EEG.srate, ...
        'freqfac', 4, 'winsize', ...
        fftwinfac*EEG.srate, 'plot', 'off');
    tString = [basename ': channel ' num2str(fftchan)];
    figure('Name', tString)
    hold on
    plot(freforig, sreforig, 'k')
    plot(fref, sref, 'r')
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    legend('High pass only', 'Line noise removed')
    title(tString, 'Interpreter', 'none')
end
