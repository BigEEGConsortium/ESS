% 
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\VEP'; % Input data directory used for this demo
basename = 'vep_01';
EEGchans = 1:64;           % Channels to compute reference on
rrefchans = 1:70;          % Channels to rereference at the end
fftchans = [48, 42, 58];   % Pick 3 channels for spectral display
linefreqs = [60, 120, 180];

hpassfreq = 1;             % High pass frequency in Hz
fftwinfac = 4;

%% Load the original data, high-pass and save
% fname = [indir filesep basename '.set'];
% EEG = pop_loadset(fname);
% EEG.data = double(EEG.data);      % We need the precision for rereferencing
% EEG = highPassFilter(EEG, hpassfreq, rrefchans);
% fname = [indir filesep basename '.mat'];
% save(fname, 'EEG', '-v7.3');

%% Load the high-passed data
fname = [basename '.mat'];
load(fname);

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
g = struct('linefreqs', linefreqs, 'fscanbw', 2, 'pad', 0, ...
           'chanlist', rrefchans, 'maxiters', 1);
% g = struct('linefreqs', linefreqs, 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
% g = struct('linefreqs', linefreqs, 'fscanbw', 1, ...
%             'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);

% g = struct('linefreqs', [], 'fscanbw', [], 'p', 0.1, 'multipleComparisons', 1, ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
%EEG =  cleanLineNoise(EEG, g);

%EEG = cleanLineNoise(EEG, g);
EEG1 = EEG;
EEG1.data = EEG.data(58, :);
EEG1 = cleanLineNoise(EEG1, g);
% %%
% g = struct('linefreqs', [], 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 1);
% %EEG =  cleanLineNoise(EEG, g);
% EEG = cleanLineNoise2(EEG, g);
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
tString = [basename ': power spectra for  channel '];

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
    title([tString num2str(showChans(k)) ' frequencies [1 100]'], 'Interpreter', 'none')
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
    title([tString num2str(showChans(k))], 'Interpreter', 'none')
end
