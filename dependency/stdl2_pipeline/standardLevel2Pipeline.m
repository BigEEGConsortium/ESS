%% Apply bad channel detection to a single dataset in EEG .set format. 
%  
%  EEG = std2_pipeline(EEG)
%  [EEG, noisyParameters] = std2_pipeline(EEG)
%  [EEG, noisyParameters] = std2_pipeline(EEG, noisyParameters)
%  [EEG, noisyParameters] = std2_pipeline(EEG, noisyParameters, verbose)
%
% NOTE: this pipeline converts the data to double and preserves the double
% throughout. 
% The EEG structure can conform with the EEGLAB data structure. It requires
% the following fields:
%      EEG.data      2D array of data interpreted as channels x time
%      EEG.srate     Sampling rate in Hz
%      EEG.chanlocs  Channel location file with the X, Y, Z channel 
%                    positions
%      EEG.etc  A catchall field where results are stored
%
function [EEG, noisyParameters] = ...
                      standardLevel2Pipeline(EEG, noisyParameters, verbose)


%% Check the parameters for validty
if nargin < 1 
    error('standardLevel2Pipeline:NotEnoughArguments', ...
          'requires at least 1 argument');
elseif ~isstruct(EEG) || ~isfield(EEG, 'data') || ...
        ~isfield(EEG, 'srate') || ~isfield(EEG, 'chanlocs')
    error('standardLevel2Pipeline:NoDataField', ...
          'EEG must be a structure with data, srate, and chanlocs fields');
elseif size(EEG.data, 3) ~= 1
    error('standardLevel2Pipeline:DataNotContinuous', ...
          'data must be a 2D array');
elseif nargin < 2
    noisyParameters = struct();
end
if ~exist('verbose', 'var')
    verbose = true;
end

%% Set general defaults
noisyParameters = getStructureParameters(noisyParameters, ...
                        'referenceChannels', 1:size(EEG.data, 1));
noisyParameters = getStructureParameters(noisyParameters, ...
                        'reReferencedChannels', 1:size(EEG.data, 1));
noisyParameters = getStructureParameters(noisyParameters, ...
                        'channelLocations', EEG.chanlocs);
noisyParameters = getStructureParameters(noisyParameters, 'name', 'Sample');
noisyParameters = getStructureParameters(noisyParameters, 'srate', EEG.srate);
noisyParameters = ...
    getStructureParameters(noisyParameters, 'interpolateBadChannels', true);
%% Set EEGLAB parameters to make sure computations done in double
EEG.data = double(EEG.data);      % We need the precision for rereferencing
pop_editoptions('option_single', false, 'option_savetwofiles', false);
                    
%% High pass filtering -- set up parameters and perform high pass filter
if ~isfield(noisyParameters, 'highPass')
    noisyParameters.highPass = struct();
end
noisyParameters.highPass = getStructureParameters(...
    noisyParameters.highPass, 'highPassCutoff', 1);
noisyParameters.highPass = getStructureParameters(...
    noisyParameters.highPass, 'highPassChannels', ...
    noisyParameters.reReferencedChannels);

[EEG, noisyParameters.highPass] = highPassFilter(EEG, noisyParameters.highPass);

%% Line noise removal --- set up parameters and do line noise removal
if ~isfield(noisyParameters, 'lineNoise')
    noisyParameters.lineNoise = struct();
end
noisyParameters.lineNoise = getStructureParameters( ...
    noisyParameters.lineNoise, 'Fs', noisyParameters.srate);
noisyParameters.lineNoise = getStructureParameters( ...
    noisyParameters.lineNoise, 'lineFrequencies', [60, 120, 180]);
noisyParameters.lineNoise = getStructureParameters( ...
    noisyParameters.lineNoise, 'lineNoiseChannels', ...
    noisyParameters.reReferencedChannels);
noisyParameters.lineNoise = getStructureParameters( ...
    noisyParameters.lineNoise, 'maxLineNoiseIterations', 10); 
noisyParameters.lineNoise = getStructureParameters( ...
    noisyParameters.lineNoise, 'fftWindowFactor', 4);
 
[EEG, noisyParameters.lineNoise] = ...
                 cleanLineNoise(EEG, noisyParameters.lineNoise, verbose);

%% Save temporarily
save('EEGLineClean.mat', 'EEG', '-v7.3');
save('noisyClean.mat', 'noisyParameters', '-v7.3');

%% Now calculate the mean that includes bad channels for downstream
if ~isfield(noisyParameters, 'reference')
    noisyParameters.reference = struct();
end
noisyParameters.reference = getStructureParameters( ...
    noisyParameters.reference, 'srate', noisyParameters.srate);
noisyParameters.reference = getStructureParameters( ...
    noisyParameters.reference, 'referenceChannels', ...
    noisyParameters.referenceChannels);
noisyParameters.reference = getStructureParameters( ...
    noisyParameters.reference, 'reReferencedChannels', ...
    noisyParameters.reReferencedChannels);


[EEG, noisyParameters.reference] = ...
              robustReReference(EEG, noisyParameters.reference, verbose);
          
%% Now interpolate bad channels if appropriate
noisyChannels = noisyParameters.reference.noisyChannels;
if ~isempty(noisyChannels) && noisyParameters.interpolateBadChannels
    fprintf('Interpolating bad channels after rereferencing\n');
    sourceChannels = setdiff(noisyParameters.reference.referenceChannels, noisyChannels);
    EEG = interpolateChannels(EEG, noisyChannels, sourceChannels); 
    noisyParameters.reference.interpolatedChannels = noisyChannels;
else
    noisyParameters.reference.interpolatedChannels = [];
end
EEG.etc.noisyParameters = noisyParameters;
