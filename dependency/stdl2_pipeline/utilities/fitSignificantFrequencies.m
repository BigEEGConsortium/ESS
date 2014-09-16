function [datafit, Amps, freqs, Fval, sig, f0Significant]= ...
                           fitSignificantFrequencies(data, f0, noisyParameters)
% Fits significant sine waves to specified peaks in continuous data
%
% Usage: 
%   [datafit, Amps, freqs, Fval, sig, f0Significant] = ... 
%                          fitSignificantFrequencies(data, noisyParameters)  
%
% Inputs:
% Note that units of Fs, fpass have to be consistent.
%       data        (data in [N,C] i.e. time x channels/trials or a single
%       vector) - required.
%       params      structure containing parameters - params has the
%       following fields: tapers, Fs, fpass, pad
%           tapers : precalculated tapers from dpss 
%
%	        Fs 	        (sampling frequency) -- optional. Defaults to 1.
%               fpass       (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%	    p		    (P-value to calculate error bars for) - optional.
%                           Defaults to 0.05/N where N is data length.
%       plt         (y/n for plot and no plot respectively) - plots the
%       Fratio at all frequencies if y
%       f0          frequencies at which you want to remove the
%                   lines - if unspecified the program
%                   will compute the significant lines
%       fscanbw     bandwidth centered on ea. f0 to scan for significant
%                   lines (TM)
%
%  Outputs:
%       datafit          Linear superposition of fitted sine waves
%       Amps             Amplitudes at significant frequencies
%       freqs            Significant frequencies
%       Fval             Fstatistic at all frequencies)
%       sig              Significance level for F distribution p value of p)
%       f0Significant    f0 values found to be significant.
data = change_row_to_column(data);
[N, C] = size(data);

[~, fscanbw] = getStructureParameters(noisyParameters, 'fscanbw');
[~, Fs] = getStructureParameters(noisyParameters, 'Fs');
%[~, lineNoiseFrequencyBand] = getStructureParameters(noisyParameters, 'lineNoiseFrequencyBand');

[Fval, A, f, sig] = testSignificantFrequencies(data, noisyParameters);
datafit = zeros(N, C);
Amps  = cell(1, C);
freqs = cell(1, C);
  
frequencyMask = false(1, length(f));
f0Significant = false(1, length(f0));
if ~isempty(fscanbw)
    % For each line f0(n), scan f0+-BW/2 for largest significant peak of Fval
    for n = 1:length(f0)
        % Extract scan range around f0 ( f0 +- fscanbw/2 )
        [~, ridx(1)] = min(abs(f - (f0(n) - fscanbw/2)));
        [~, ridx(2)] = min(abs(f - (f0(n) + fscanbw/2)));
        
        Fvalscan = Fval(ridx(1):ridx(2));
        Fvalscan(Fvalscan < sig) = 0;
        if any(Fvalscan)
            % If there's a significant line, pull the max one
            [~, rmaxidx] = max(Fvalscan);
            indx = ridx(1) + rmaxidx - 1;
            frequencyMask(indx) = true;
            f0Significant(n) = true;
        end    
    end
else
    % Remove exact lines if significant
    for n = 1:length(f0);
        [~, itemp] = min(abs(f - f0(n)));
        frequencyMask(itemp) = Fval(itemp) >= sig;
        f0Significant(n) = frequencyMask(itemp);
    end;   
end
 
% Estimate the contribution of any significant f0 lines
fsig = f(frequencyMask);
if ~isempty(fsig)
    Amps{1} = A(frequencyMask);
    datafit = exp(1i*2*pi*(0:(N - 1))'*fsig/Fs)* ...
        A(frequencyMask) ...
        +exp(-1i*2*pi*(0:(N - 1))'* ...
        fsig/Fs)*conj(A(frequencyMask));
end


