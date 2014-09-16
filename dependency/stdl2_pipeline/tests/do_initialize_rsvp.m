%% Initialize the rsvp data with channel locations
% 
% Assumptions: The chanlocs file corresponds to the initial channels in the
% data set.
%
indir = 'E:\\NeuroErgonomicsData\\RSVP_HeadIT\RSVP Target Detection\session';
outdir = 'E:\\CTAData\\RSVP_HEADIT';  

%% Set the paramters for reading
nbsessions = 15;
basename = 'rsvp_';
chanfile = 'channel_locations.elp';
eegfile = 'eeg_recording_1.bdf';
%% Run through directory, split off .set, remap channels, and rewrite
for k = 1:nbsessions
    fprintf('%d: ', k);
    sessiondir = [indir filesep num2str(k)];
    fname = [sessiondir filesep eegfile];
    try
        EEG = pop_biosig(fname);
    catch ex
        warning(['Failed to read ' fname]);
        continue;
    end
    chname = [sessiondir filesep chanfile];
    try
        chanlocs = readlocs(chname);
    catch ex
        warning(['Failed to read ' chname]);
        continue;
    end
    data = EEG.data(1:length(chanlocs), :);
    EEG.urchanlocs = chanlocs;
    for j = 1:length(chanlocs)
        chanlocs(j).urchan = j;
    end;
    types = strcmp({chanlocs.type}, 'EEG');
    chanlocs = chanlocs(types);
    EEG.nbchan = length(chanlocs);
    EEG.chanlocs = chanlocs;
    EEG.data = data(types, :);
    nb = sprintf('%02d', k);
    EEG = pop_saveset(EEG, 'filename', [basename num2str(nb) '.set'], ...
        'filepath', outdir, 'savemode', 'onefile', 'version', '7.3');
end
