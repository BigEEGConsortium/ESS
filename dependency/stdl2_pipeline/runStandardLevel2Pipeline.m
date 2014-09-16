%% Here is the call to the pipeline -- assuming certain variables set outside
% You should set:
%  indir        directory of the input EEG
%  outdir       directory to save EEG after rereferencing
%  outrecdir    directory to save noisy channel structure
%  basename     EEG file name (without extension)
%  EEGchans     vector of EEG channel numbers
%  rrefchans    vector of channels to be re-referenced
%  linefreqs    vector of line frequencies to try to remove 
%                   default is [60, 120, 180])
%
% The standardLevel2Pipeline function interpolates bad channels by default
% If you want to turn off interpolation, you should set the
% interpolateBadChannels flag to false.
%
%
% Note: you must make sure that the EEGLAB is in the path and that 
% the utilities subdirectory is in the path.
%
%
% This version is still in progress and is the latest as of 9-15-14.
% It still needs:
%    1)  Automatic line noise peak finding --- approximate peaks now
%        have to be set.
%    2)  Elimination of places where signal is not recorded 
%        (e.g., bad on most or all channels.)
%    3)  Haven't decided how to pad the tapers for removing line noise
%        so there is always a small segment at end that is not cleaned.
%    4)  Haven't finalized how the results are reported.
%
% Written by Kay Robbins 
%
%% Here are example settings
indir = 'E:\\CTAData\\VEP';  % Input data directory used for this demo
outdir = 'N:\\ARLAnalysis\\TESTSTD5\\EEG';  % Processed data directory
outrecdir = 'N:\\ARLAnalysis\\TESTSTD5\\INFO';   % Bad channel info directory
basename = 'vep_01';         % Demo file base name
EEGchans = 1:64;             % Channels to compute reference on
rrefchans = 1:70;            % Channels to rereference at the end
linefreqs = [60, 120, 180];
interpolateBadChannels = true;
fftchans = [1, 12, 28];    % Pick 3 channels -- first should be Cz

%% Load the dataset
fname = [indir filesep basename '.set'];
EEG = pop_loadset(fname);


%% Set the EEGLAB options
pop_editoptions('option_single', false, 'option_savetwofiles', false);

%% Here is the call to the pipeline ------------------
noisyChannelRecord = struct('name', basename, ...
                            'referenceChannels', EEGchans, ...
                            'reReferencedChannels', rrefchans, ...
                            'lineNoise', struct('lineFrequencies', linefreqs), ...
                            'interpolateBadChannels', interpolateBadChannels);
[EEG, noisyChannelRecord] = standardLevel2Pipeline(EEG, noisyChannelRecord);
%---------------------------------------------------------

%% Save the output
fname = [outdir filesep basename '.set'];
save(fname, 'EEG', '-v7.3');
new_name = [outrecdir filesep basename '_noisyChannels.mat'];
save(new_name, 'noisyChannelRecord', '-v7.3');

%% Display the results of the bad channel calculation
fprintf('Show bad channels after rereferencing and interpolation\n');
noisyChannelRecordTemp = noisyChannelRecord;
noisyChannelRecordTemp.reference = findNoisyChannels(EEG, noisyChannelRecord.reference);
showNoisyChannels(noisyChannelRecordTemp, 'High-Line-Huber-ReRef-Interp')

