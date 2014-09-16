% 
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\VEP'; % Input data directory used for this demo
basename = 'vep_01';
     % Channels to compute reference on
                % Channels to rereference at the end
%fftchans = [ 28, 42, 48, 52, 58 ];   % Pick 3 channels for spectral display
fftchans = 48;

%EEGchans = 1:length(fftchans);      
linefreqs = [60, 120,  180, 212, 240];

hpassfreq = 1;             % High pass frequency in Hz
fftwinfac = 4;

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
% showChans = fftchans;
% sreforig = cell(length(showChans), 1);
% freforig = cell(length(showChans), 1);
% for k = 1:length(showChans)
%     fftchan = showChans(k);
%     [sreforig{k},freforig{k}]= spectopo(EEG.data(fftchan, :), ...
%         size(EEG.data, 2), EEG.srate, ...
%         'freqfac', 4, 'winsize', ...
%         fftwinfac*EEG.srate, 'plot', 'off');
% end
%%
g = struct('lineFrequencies', linefreqs, 'fscanbw', 2, 'pad', 0, ...
           'chanlist', rrefchans, 'maxiters', 10);
% g = struct('linefreqs', linefreqs, 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
% g = struct('linefreqs', linefreqs, 'fscanbw', 1, ...
%             'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);

% g = struct('linefreqs', [], 'fscanbw', [], 'p', 0.1, 'multipleComparisons', 1, ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
%EEG =  cleanLineNoise(EEG, g);

EEG1 = cleanLineNoise(EEG, g);

% %%
% g = struct('linefreqs', [], 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 1);
% %EEG =  cleanLineNoise(EEG, g);
% EEG = cleanLineNoise2(EEG, g);
%% Show spectra at selected channels
% showChans = fftchans;
% sref = cell(length(showChans), 1);
% fref = cell(length(showChans), 1);
% for k = 1:length(showChans)
%     
%     [sref{k},fref{k}]= spectopo(EEG.data(k, :), ...
%         size(EEG.data, 2), EEG.srate, ...
%         'freqfac', 4, 'winsize', ...
%         fftwinfac*EEG.srate, 'plot', 'off');
% end
% tString = [basename ': power spectra for  channel '];

% for k = 1:length(showChans)
%     figure('Name', tString)
%     hold on
%     plot(freforig{k}, sreforig{k}, 'k')
%     plot(fref{k}, sref{k}, 'r')
%     hold off
%     set(gca, 'XLim', [0, 100])
%     xlabel('Frequency (Hz)')
%     ylabel('Power 10*log(uV2/Hz)')
%     legend('Original', 'Cleaned')
%     title([tString num2str(showChans(k)) ' frequencies [1 100]'], 'Interpreter', 'none')
% end
%%
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
