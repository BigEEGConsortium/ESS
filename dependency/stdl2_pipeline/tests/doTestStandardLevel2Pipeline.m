%% Here is the call to the pipeline -- assuming certain variables set outside
%  indir, outdatadir, outrecdir, basename, EEGchans, rrefchans, and linefreqs are  set outside
fname = [indir filesep basename '.set'];
EEG = pop_loadset(fname);

%% Here is the call to the pipeline ------------------
noisyParameters = struct('referenceChannels', EEGchans, ...
                         'rereferencedChannels', rrefchans, ...
                          'lineFrequencies', linefreqs);
[EEG, noisyParameters] = standardLevel2Pipeline(EEG, noisyParameters);
%---------------------------------------------------------

%% Save the output
fname = [outdir filesep basename '.set'];
save(fname, 'EEG', '-v7.3');
new_name = [outrecdir filesep basename '_noisyChannels.mat'];
save(new_name, 'noisyParameters', '-v7.3');

%% Display the results of the bad channel calculation
fprintf('Show bad channels after rereferencing\n');
showNoisyChannels(noisyParameters, 'High-Line-Huber-ReRef')

%% Compare average reference of complete process to high then mean
noisyReference = noisyParameters.reference.averageReferenceWithNoisyChannels;
averageReference = noisyParameters.reference.averageReference;
tString = [basename ': Comparison of reference signals (complete)'];
figure('Name', tString)
plot(noisyReference', averageReference', '.k')
title(tString, 'Interpreter', 'none');
xlabel('High pass then aver ref')
ylabel('Complete process')

%% Plot maximum absolute difference in signals for proposed versus average
tsec = (0:length(noisyReference) - 1)/EEG.srate;
diffave = averageReference - noisyReference;
tString = [basename ': Average reference - noisy reference\n'];
figure('Name', tString)
plot(tsec, diffave, '.k')
xlabel('Seconds')
ylabel('Average - noisy')
title(tString, 'Interpreter', 'none');
pos = get(gcf, 'Position');
pos(3) = maxWidth;
set(gcf, 'Position', pos);

%% Histogram maximum absolute difference in reference 
tString = [basename ': Absolute average difference between proposed and averaged'];
figure('Name', tString)
hist(diffave', 100)
xlabel('Max absolute difference')
title(tString, 'Interpreter', 'none');
                      
%% Show spectra at selected channels
showChans = fftchans;
corrChan = setdiff(noisyParameters.badChannelsFromCorrelation, ...
                   noisyParameters.badChannelsFromDeviation);
if ~isempty(noisyParameters.badChannelsFromDeviation)
    showChans(2) = noisyParameters.badChannelsFromDeviation(1);
end
if ~isempty(corrChan)
    showChans(3) = corrChan(1);
end
sref = cell(length(showChans), 1);
fref = cell(length(showChans), 1);
for k = 1:length(showChans)
    fftchan = showChans(k);
    [sref{k},fref{k}]= spectopo(EEG.data(fftchan, :), ...
        size(EEG.data, 2), EEG.srate, ...
        'freqfac', 4, 'winsize', ...
        noisyParameters.fftWindowFactor*EEG.srate, 'plot', 'off');
end
tString = [basename ': power spectra for channel '];

for k = 1:length(showChans)
     figure('Name', tString)
    plot(fref{k}, sref{k}, 'k')
    set(gca, 'XLim', [0, 100])
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title([tString num2str(showChans(k))], 'Interpreter', 'none')
end
for k = 1:length(showChans)
    figure('Name', tString)
    plot(fref{k}, sref{k}, 'k')
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title([tString num2str(showChans(k))], 'Interpreter', 'none')
end

%% Now do the interpolation again if there are still bad channels
noisyChannels = noisyParameters.noisyChannels;
if isempty(noisyChannels)
    EEG.etc.interpolated = [];
    fprintf('No bad channels after rereferencing\n');
else
    fprintf('Interpolating bad channels after rereferencing\n');
    sourceChannels = setdiff(noisyParameters.referenceChannels, noisyChannels);
    EEGtemp = interpolateChannels(EEG, noisyChannels, sourceChannels); 
    noisyParametersTemp = findNoisyChannels(EEGtemp, noisyParameters);
    showNoisyChannels(noisyParametersTemp, 'High-Line-Huber-ReRef-Interp')
    remainingBad = noisyParametersTemp.noisyChannels;
    noisyParameters.remainingBadAfterInterpolation = remainingBad;
    interpolatedChannels = setdiff(noisyChannels, noisyParametersTemp.noisyChannels);
    EEG.etc.interpolatedChannels = interpolatedChannels;
    if ~isempty(interpolatedChannels)
        fprintf('%s: interpolated channels: [%s]\n', basename, ...
               num2str(interpolatedChannels));
        EEG.data(interpolatedChannels, :) = EEGtemp.data(interpolatedChannels, :);
    end
    if ~isempty(remainingBad) 
        warning([basename ' still has bad channels: ' num2str(remainingBad)]);
    end
end
EEG.filename = [basename '_interpolated.mat'];
save([outdir filesep EEG.filename], 'EEG', '-v7.3');