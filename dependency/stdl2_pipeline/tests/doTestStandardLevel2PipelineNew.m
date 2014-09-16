%% Here is the call to the pipeline -- assuming certain variables set outside
%  indir, outdatadir, outrecdir, basename, EEGchans, rrefchans, and linefreqs are  set outside
fname = [indir filesep basename '.set'];
EEG = pop_loadset(fname);

%% Here is the call to the pipeline ------------------
noisyParameters= struct('name', basename, ...
                            'referenceChannels', EEGchans, ...
                            'reReferencedChannels', rrefchans, ...
                            'lineNoise', struct('lineFrequencies', linefreqs));
[EEG, noisyParameters] = standardLevel2Pipeline(EEG, noisyParameters);
%---------------------------------------------------------
%% Save the output
fname = [outdir filesep basename '.set'];
save(fname, 'EEG', '-v7.3');
new_name = [outrecdir filesep basename '_noisyChannels.mat'];
save(new_name, 'noisyParameters', '-v7.3');

%% Display the results of the bad channel calculation
fprintf('Show bad channels after rereferencing and interpolation\n');
showNoisyChannels(noisyParameters, 'High-Line-Huber-ReRef-Interp')

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
corrChan = setdiff(noisyParameters.reference.badChannelsFromCorrelation, ...
                   noisyParameters.reference.badChannelsFromDeviation);
if ~isempty(noisyParameters.reference.badChannelsFromDeviation)
    showChans(2) = noisyParameters.reference.badChannelsFromDeviation(1);
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
        4*EEG.srate, 'plot', 'off');
end
tString = [basename ': power spectra for channel '];

for k = 1:length(showChans)
    figure('Name', tString)
    plot(fref{k}, sref{k}, 'k')
    xlabel('Frequency (Hz)')
    ylabel('Power 10*log(uV2/Hz)')
    title([tString num2str(showChans(k))], 'Interpreter', 'none')
end

