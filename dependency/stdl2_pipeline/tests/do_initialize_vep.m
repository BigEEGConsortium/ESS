%% Initialize the vep data with channel locations
% indir = 'E:\\CTAData\\RawVEP';
% outdir = 'E:\\CTAData\\VEP';  
indir = 'K:\\CTAData\\VEPRaw';
outdir = 'K:\\CTAData\\VEP';  
%% Set number of extra channels to be filtered
nbsessions = 18;
basename = 'B_';
suffix = '_VEP.bdf';
chanfile = 'Biosemi_Chanlocs.ced';
channels = 1:70;
%% Read in the channel locations
fprintf('Reading the channel locations for VEP\n');
chname = [indir filesep chanfile];
chanlocs = readlocs(chname);
for k = 1:64
    chanlocs(k).type = 'EEG';
end;
for k = 65:68
    chanlocs(k).type = 'EOG';
end
for k = 69:70
    chanlocs(k).type = 'MAS';
end
chanlocs = chanlocs(channels);
urchanlocs = chanlocs;
for k = 1:length(chanlocs)
    chanlocs(k).urchan = k;
end;

%% Run through directory, split off .set, remap channels, and rewrite
for k = 1:nbsessions
    nb = sprintf('%02d', k);
    fname = [indir filesep basename nb suffix];
    fprintf('%d: %s\n', k, fname);
    try
        EEG = pop_biosig(fname, 'blockepoch', 'off');
    catch ex
        warning(['Failed to read ' fname]);
        continue;
    end
    fprintf('%g ', EEG.etc.T0);
    EEG.urchanlocs = urchanlocs;
    EEG.nbchan = length(chanlocs);
    EEG.chanlocs = chanlocs;
    EEG.data = EEG.data(channels, :);
    fprintf('\nRewriting with %d channels\n', length(chanlocs));
    EEG = pop_saveset(EEG, 'filename', ['vep_' nb '.set'], ...
        'filepath', outdir, 'savemode', 'onefile', 'version', '7.3');
end
