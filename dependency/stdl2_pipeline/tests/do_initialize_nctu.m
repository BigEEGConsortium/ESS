%% Initialize the rsvp data with channel locations
% 
% Assumptions: The chanlocs file corresponds to the initial channels in the
% data set.
%
indir = 'J:\\NCTULaneKeeping\\session';
outdir = 'J:\\CTAData\\NCTU';  

%% Set the paramters for reading
nbsessions = 80;


%% Run through directory, split off .set, remap channels, and rewrite
for k = 1%1:nbsessions
    in_list = dir([indir filesep num2str(k)]);
    in_names = {in_list(:).name};
    in_types = [in_list(:).isdir];
    in_names = in_names(~in_types);
    for j = 1:length(in_names)   
        in_name = in_names{j};
        if ~strcmp(in_name(end-3:end), '.set')
            break;
        end
        basename = in_name(1:(end-4));
        fprintf('%d: %s', k, basename);
        
        sessiondir = [indir filesep num2str(k)];
        fname = [sessiondir filesep in_name];
        try
            EEG = pop_loadset(fname);
        catch ex
            warning(['Failed to read ' fname]);
            continue;
        end
        chanlocs = EEG.chanlocs;
        fprintf('has %d channels', length(chanlocs));
        if isempty(cell2mat({chanlocs.X}))
            fprintf(' but no channel locations');
        end
        fprintf('\n');
        
%         chname = [sessiondir filesep chanfile];
%         try
%             chanlocs = readlocs(chname);
%         catch ex
%             warning(['Failed to read ' chname]);
%             continue;
%         end
%         data = EEG.data(1:length(chanlocs), :);
%         EEG.urchanlocs = chanlocs;
%         for j = 1:length(chanlocs)
%             chanlocs(j).urchan = j;
%         end;
%         types = strcmp({chanlocs.type}, 'EEG');
%         chanlocs = chanlocs(types);
%         EEG.nbchan = length(chanlocs);
%         EEG.chanlocs = chanlocs;
%         EEG.data = data(types, :);
%         nb = sprintf('%02d', k);
%         EEG = pop_saveset(EEG, 'filename', [basename num2str(nb) '.set'], ...
%             'filepath', outdir, 'savemode', 'onefile', 'version', '7.3');
    end
end
