% 
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\VEP'; % Input data directory used for this demo
basename = 'vep_03';
     % Channels to compute reference on
                % Channels to rereference at the end
%fftchans = [ 28, 42, 48, 52, 58 ];   % Pick 3 channels for spectral display
%fftchans = 48;

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
rrefchans = 1:64;
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
g = struct('referenceChannels', rrefchans);
g = findNoisyChannels(EEG, g);
% g = struct('linefreqs', linefreqs, 'fscanbw', [], ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
% g = struct('linefreqs', linefreqs, 'fscanbw', 1, ...
%             'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);

% g = struct('linefreqs', [], 'fscanbw', [], 'p', 0.1, 'multipleComparisons', 1, ...
%            'frequencyLowCutoff', 45, 'chanlist', rrefchans, 'maxiters', 5);
%EEG =  cleanLineNoise(EEG, g);

showNoisyChannels(g, 'High-pass');