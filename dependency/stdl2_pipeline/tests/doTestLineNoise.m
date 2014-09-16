
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\EEGLAB'; % Input data directory used for this demo

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
EEG = high_pass(EEG, hpassfreq, rrefchans);

%%
g = struct('linefreqs', linefreqs, ...
           'chanlist', rrefchans, 'maxiters', 5);
EEG =  cleanLineNoise(EEG, g);

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
tString = [basename ': power spectra for selected channels'];

for k = 1:length(showChans)
     figure('Name', tString)
    plot(fref{k}, sref{k}, 'k')
    set(gca, 'XLim', [0, 100])
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title([tString num2str(showChans(k))])
end
for k = 1:length(showChans)
    figure('Name', tString)
    plot(fref{k}, sref{k}, 'k')
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title([tString num2str(showChans(k))])
end
