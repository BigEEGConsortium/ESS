function [signal, lineNoise] = cleanLineNoise(signal, lineNoise, verbose)

% Input:
%
% signal                Structure containing a 2D data field
%                       (An EEGLAB EEG structure will work here.)
% g                     Optional structure with additional parameters
%
% g structure parameters:
%
% Fs   :                Sampling rate in Hz
%                       Input Range  : positive
%                       Default value: 1
%                       Input Data Type: real number (double)
%
% lineFrequencies:            Line noise frequencies to remove
%                       Input Range  : positive
%                       Default value: [60, 120]
%                       Input Data Type: real number (double)
%
% p:                    p-value for detection of significant sinusoid
%                       Input Range  : [0  1]
%                       Default value: 0.01
%                       Input Data Type: real number (double)
%
% bandwidth:            Bandwidth (Hz)
%                       This is the width of a spectral peak for a sinusoid at fixed frequency. As such, this defines the
%                       multi-taper frequency resolution.
%                       Input Range  : Unrestricted
%                       Default value: 1
%                       Input Data Type: real number (double)
% chanlist:             IDs of Chans/Comps to clean
%                       Input Range  : Unrestricted
%                       Default value: 1:152
%                       Input Data Type: any evaluable Matlab expression.
%
% taperWindowSize:              Sliding window length (sec)
%                       Input Range  : [0  4]
%                       Default value: 4
%                       Input Data Type: real number (double)
%
% taperWindowStep:              Sliding window step size (sec)
%                       This determines the amount of overlap between sliding windows. Default is window length (no
%                       overlap).
%                       Input Range  : [0  4]
%                       Default value: 4
%                       Input Data Type: real number (double)
% taperTemplate:       or in the one of the following
%                    forms:
%                   (1) A numeric vector [TW K] where TW is the
%                       time-bandwidth product and K is the number of
%                       tapers to be used (less than or equal to
%                       2TW-1).
%                   (2) A numeric vector [W T p] where W is the
%                       bandwidth, T is the duration of the data and p
%                       is an integer such that 2TW-p tapers are used. In
%                       this form there is no default i.e. to specify
%                       the bandwidth, you have to specify T and p as
%                       well. Note that the units of W and T have to be
%                       consistent: if W is in Hz, T must be in seconds
%                       and vice versa. Note that these units must also
%                       be consistent with the units of params.Fs: W can
%                       be in Hz if and only if params.Fs is in Hz.
%                       The default is to use form 1 with TW=3 and K=5
%
% tau:                  Window overlap smoothing factor
%                       A value of 1 means (nearly) linear smoothing between adjacent sliding windows. A value of Inf means
%                       no smoothing. Intermediate values produce sigmoidal smoothing between adjacent windows.
%                       Input Range  : [1  Inf]
%                       Default value: 100
%                       Input Data Type: real number (double)
%
% pad:                  FFT padding factor
%                       Signal will be zero-padded to the desired power of two greater than the sliding window length. The
%                       formula is NFFT = 2^nextpow2(SlidingWinLen*(PadFactor+1)). e.g. For SlidingWinLen = 500, if PadFactor = -1, we
%                       do not pad; if PadFactor = 0, we pad the FFT to 512 points, if PadFactor=1, we pad to 1024 points etc.
%                       Input Range  : [-1  Inf]
%                       Default value: 2
%                       Input Data Type: real number (double)
%
% pnts:                 Number of data frames on which to remove noise
%                       Input Range  : 2 to all frames in dataset
%                       Default value: all frames in data set
%                       Input Data Type: integer
%
% maxiters:             Maximum number of iterations of algorithm
%                       Input Range  : [1  Inf]
%                       Default value: 1
%                       Input Data Type: integer
%
% tolerance:            If average noise reduction less than this, return
%                       before completing all maxiters iterations
%                       Input Range  : positive
%                       Default value: 1 (db)
%                       Input Data Type: real number (double)
%
% Output:
%
% signal                Cleaned signal dataset
% Sorig                 Original multitaper spectrum for each component/channel
% Sclean                Cleaned multitaper spectrum for each component/channel
% f                     Frequencies at which spectrum is estimated in Sorig, Sclean
% amps                  Complex amplitudes of sinusoidal lines for each
%                       window (line time-series for window i can be
%                       reconstructed by creating a sinudoid with frequency f{i} and complex
%                       amplitude amps{i})
% freqs                 Exact frequencies at which lines were removed for
%                       each window (cell array)
% g                     Parameter structure. Function call can be
%                       replicated exactly by calling >> cleanline(EEG,g);
%
% Usage Example:
%    signalOut = signal(signalIn)
%
% This function is a modification by Kay Robbins of a function written
% by Tim Mullen SCCN/INC/UCSD Copyright (C) 2011
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%% Check the incoming parameters
if nargin < 1
    error('cleanLineNoise:NotEnoughArguments', 'requires at least 1 argument');
elseif isstruct(signal) && ~isfield(signal, 'data')
    error('cleanLineNoise:NoDataField', 'requires a structure data field');
elseif size(signal.data, 3) ~= 1
    error('cleanLineNoise:DataNotContinuous', 'signal data must be a 2D array');
elseif size(signal.data, 2) < 2
    error('cleanLineNoise:NoData', 'signal data must have multiple points');
elseif ~exist('lineNoise', 'var') || isempty(lineNoise)
    lineNoise = struct();
elseif isempty(lineNoise) || ~isstruct(lineNoise)
    error('cleanLineNoise:NoData', 'second argument must be a structure')
end
if ~exist('verbose', 'var')
    verbose = true;
end

%% Set the defaults to appropriate values
lineNoise = getSignalParameters(lineNoise, 'Fs', signal, 'Fs', 1);
lineNoise = getStructureParameters(lineNoise, 'noiseChannels', 1:size(signal.data, 1));
lineNoise = getStructureParameters(lineNoise, 'lineFrequencies', [60, 120, 180]);
lineNoise = getStructureParameters(lineNoise, 'p', 0.01);
lineNoise = getStructureParameters(lineNoise, 'bandwidth', 2);
lineNoise = getStructureParameters(lineNoise, 'fscanbw', 2);
lineNoise = getStructureParameters(lineNoise, 'taperWindowSize', 4);
lineNoise = getStructureParameters(lineNoise, 'taperWindowStep', 1);
lineNoise = getStructureParameters(lineNoise, 'tau', 100);
lineNoise = getStructureParameters(lineNoise, 'pad', 0);  % Pad of 2 is slower but gives better results
lineNoise = getStructureParameters(lineNoise, 'pnts', size(signal.data, 2));
lineNoise = getStructureParameters(lineNoise, 'fPassBand',  ...
                                               [45, lineNoise.Fs/2]);
lineNoise = ...
    getStructureParameters(lineNoise, 'maximumNoiseIterations', 10);
lineNoise = getStructureParameters(lineNoise, 'tolerance', 1);
if any(lineNoise.noiseChannels > size(signal.data, 1))
    error('clean_line:Invalidchannels', ...
        'Channels are not present in the dataset');
end

%% Remove line frequencies that are greater than Nyquist frequencies
tooLarge = lineNoise.lineFrequencies >= lineNoise.Fs/2;
if any(tooLarge)
    warning('cleanLineNoise:LineFrequenciesTooLarge', ...
        'Removing frequencies greater than half the sampling rate');
    lineNoise.lineFrequencies(tooLarge) = [];
    lineNoise.lineFrequencies = squeeze(lineNoise.lineFrequencies);
end

%% Set up multi-taper parameters
hbw = lineNoise.bandwidth/2;   % half-bandwidth
lineNoise.taperTemplate = [hbw, lineNoise.taperWindowSize, 1];
Nwin = round(lineNoise.Fs*lineNoise.taperWindowSize); % number of samples in window
lineNoise.tapers = ...
     checkTapers(lineNoise.taperTemplate, Nwin, lineNoise.Fs); % Calculate the actual tapers

% NOTE: params.tapers = [W, T, p] where:
% T==frequency range in Hz over which the spectrum is maximally concentrated
%    on either side of a center frequency (half of the spectral bandwidth)
% W==time resolution (seconds)
% p is used for num_tapers = 2TW-p (usually p=1).

slidinglen = lineNoise.taperWindowSize*lineNoise.Fs;
if lineNoise.pad >= 0
    NFFT = 2^nextpow2(slidinglen*(lineNoise.pad + 1));
else
    NFFT = slidinglen;
end

ndiff = rem(lineNoise.pnts, lineNoise.taperWindowSize*lineNoise.Fs);
if ndiff > 0
    warning('cleanLineNoise:EndDataNotCleaned', ...
        'Selected window length does not divide the data length, \n');
    fprintf('    %0.4g seconds of data at the end of the record will not be cleaned.\n\n', ndiff/lineNoise.Fs);
end

if verbose
    fprintf('Multi-taper parameters:\n');
    fprintf('\tTime-bandwidth product:%0.4g', hbw*lineNoise.taperWindowSize);
    fprintf(' Tapers:%0.4g', 2*hbw*lineNoise.taperWindowSize - 1);
    fprintf(' FFT points:%d', NFFT);
    fprintf(' Pad:%d', lineNoise.pad);
    fprintf(' Target frequencies:[%s]Hz\n', strtrim(num2str(lineNoise.lineFrequencies)));
end

%% Perform the calculation for each channel separately
lineNoise.iterationCounts = zeros(length(lineNoise.noiseChannels), ...
                        length(lineNoise.lineFrequencies));
for ch = lineNoise.noiseChannels
    if verbose
      fprintf('Channel %g {Hz [iterations]}: ', ch);
    end
    data = squeeze(signal.data(ch, :));
    [initialSpectrum, f] = calculateSegmentSpectrum(data, lineNoise);
    initialSpectrum = 10*log10(initialSpectrum);
    previousSpectrum = initialSpectrum;
    fidx = zeros(length(lineNoise.lineFrequencies), 1);
    for fk = 1:length(lineNoise.lineFrequencies)
        [dummy, fidx(fk)] = min(abs(f - lineNoise.lineFrequencies(fk))); %#ok<ASGLU>
    end
    f0 = lineNoise.lineFrequencies;
    f0Count = zeros(1, length(lineNoise.lineFrequencies));
    f0idx = 1:length(f0);
    for iteration = 1:lineNoise.maximumNoiseIterations
        % Perform the multi-taper remove of line noise
        [datac, f0Mask] = removeLinesMovingWindow(data, f0, lineNoise);
        newMask = zeros(1, length(lineNoise.lineFrequencies));
        newMask(f0idx) = f0Mask;
        f0Count = f0Count + newMask;
        % append to clean dataset any remaining samples that were not cleaned
        % due to sliding window and step size not dividing the data length
        ndiff = length(data) - length(datac);
        if ndiff > 0
            datac(end:end + ndiff) = data(end-ndiff : end);
        end
        cleanedSpectrum = calculateSegmentSpectrum(datac, lineNoise);
        cleanedSpectrum = 10*log10(cleanedSpectrum);
        signal.data(ch, :) = datac';
        
        dBReduction = previousSpectrum - cleanedSpectrum;
        if sum(f0Mask) > 0
            % Now find the line frequencies that have converged
            tIndex = (dBReduction(fidx) < 0)';
            f0(tIndex | ~f0Mask) = [];
            fidx(tIndex | ~f0Mask) = [];
            f0idx(tIndex | ~f0Mask) = [];
        end
        if isempty(f0) 
            break;
        end
        
        %% Iterate another step
        data = squeeze(signal.data(ch, :));
        previousSpectrum = cleanedSpectrum;
    end
    lineNoise.iterationCounts(ch, :) = f0Count;
    if verbose
    for k = 1:length(lineNoise.lineFrequencies)
        fprintf('%0.4gHz[%d] ', lineNoise.lineFrequencies(k), f0Count(k));
    end
    fprintf('\n');
    end
end






