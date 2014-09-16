% Test script for publishing bad channel visualizations

%% Set up to publish run on the EEGLAB sample data
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'E:\\CTAData\\EEGLAB'; % Input data directory used for this demo
% outdatadir = 'N:\\ARLAnalysis\\TESTSTD2\\EEG'; % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\TESTSTD2\\REC';  % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\TESTSTD2\\HTML';
% 
% %EEGchans = [1, 3:5, 7:32]; % Not using the EOG channels for referencing
% EEGchans = 1:32;
% hpassfreq = 1;             % High pass frequency in Hz
% linefreqs = 60;
% rrefchans = 1:32;          % Applying the average reference to these
% fftchans = [1, 12, 28];    % Pick 3 channels -- first should be Cz
% basename = 'sample';
% fprintf('Publishing %s...\n', basename);
% htmldir = [htmlbase filesep basename];
% if ~exist(htmldir, 'dir')
%     mkdir(htmldir)
% end
% %do_test_std2_pipeline
% script_name = 'do_test_std2_pipeline';
% publish_options.outputDir = htmldir;
% publish_options.maxWidth = maxWidth;
% publish(script_name, publish_options);
% close all
% fclose('all');


%% Set up the data directories and parameters for vep resampled
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'J:\\BCIT-2.0\\2014-08-28 BCIT Driving Data';  % Input data directory used for this demo
outdir = 'J:\\ARLAnalysis\\BCIT3';
%% Get a list of the files in the driving data from level 1
in_list = dir(indir);
in_names = {in_list(:).name};
in_types = [in_list(:).isdir];
in_names = in_names(~in_types);

%% Run through directory, calculate and save correlation and amplitude info
numfiles = length(in_names);
for k = 1:length(in_names)
       fname = [indir filesep in_names{k}];
       fprintf('%d: %s\n', k, in_names{k});
       try
           EEG = pop_loadset(fname);
       catch mex
           warning(['Could not find ' fname]);
           continue;
       end
       fprintf('Computing bad channels\n');
       chanblk = 32* floor(size(EEG.data, 1)/32);
       EEG_chans = 1:chanblk;
       rrefchans = 1:(chanblk+6);
       noisyparams = struct('EEGchans', EEG_chans, 'rrefchans', rrefchans);
       [EEG, noisyparams] = std2_pipeline(EEG, noisyparams);
       show_bad_channels(noisyparams, 'Rereferenced');
       new_name = [outdir filesep names{k}(1:4) '.set'];
       save(new_name, EEG', '-v7.3');
    new_name = [outdir filesep in_names{k}(1:4) 'refrec.mat'];
    save(new_name, 'refrec', '-v7.3');
end


% 
% rootname = 'vep_';         % Demo file base name
% outdatadir = 'N:\\ARLAnalysis\\TESTSTD4\\EEG';  % Processed data directory
% outinterpdir = 'N:\\ARLAnalysis\\TESTSTD4\\EEGINTERP';  % Processed data directory
% outsetdir = 'N:\\ARLAnalysis\\TESTSTD4\\EEGSET';  % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\TESTSTD4\\REC';   % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\TESTSTD4\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% EEGchans = 1:64;           % Channels to compute reference on
% rrefchans = 1:70;          % Channels to rereference at the end
% fftchans = [48, 42, 58];   % Pick 3 channels for spectral display
% linefreqs = [60, 120, 180];
% for k = 15%11:18
%     nb = sprintf('%02d', k);
%     basename = [rootname nb];
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     do_test_std2_pipeline;
% %     script_name = 'do_test_std2_pipeline';
% %     publish_options.outputDir = htmldir;
% %     publish_options.maxWidth = maxWidth;
% %     publish(script_name, publish_options);
% %     close all
% %     fclose('all');
% end
% 
% 
% % %% Set up the data directories and parameters for rsvp
% % maxWidth = 800;   % Maximum width for time series figures in pixels
% % indir = 'E:\\CTAData\\RSVP_HEADIT';  % Input data directory used for this demo
% % rootname = 'rsvp_';         % Demo file base name
% % outdatadir = 'N:\\ARLAnalysis\\TESTSTD3\\EEG';  % Processed data directory
% % outrecdir = 'N:\\ARLAnalysis\\TESTSTD3\\REC';   % Bad channel info directory
% % htmlbase = 'N:\\ARLAnalysis\\TESTSTD3\\HTML';
% % if ~exist(htmlbase, 'dir')
% %     mkdir(htmlbase)
% % end
% % 
% % EEGchans = 1:248;
% % linefreqs = [16, 28, 30, 32, 44, 48, 60, 76, 92, 120];
% % rrefchans = 1:256;
% % hpassfreq = 1;     % High pass frequency in Hz
% % fftchans = [48, 12, 192];   % Pick 3 channels -- first should be Cz
% % fftwin = 2048;
% % for k = [1:7, 9:15]
% %     nb = sprintf('%02d', k);
% %     basename = [rootname nb];
% %     fprintf('Publishing %s...\n', basename);
% %     htmldir = [htmlbase filesep basename];
% %     if ~exist(htmldir, 'dir')
% %         mkdir(htmldir)
% %     end
% %     script_name = 'do_std_level2_comparison_line_noise';
% %     publish_options.outputDir = htmldir;
% %     publish_options.maxWidth = maxWidth;
% %     publish(script_name, publish_options);
% %     close all
% %     fclose('all');
% % end
% % %% Set up the data directories and parameters for vep resampled
% % maxWidth = 800;   % Maximum width for time series figures in pixels
% % indir = 'E:\\CTAData\\VEP';  % Input data directory used for this demo
% % rootname = 'vep_';         % Demo file base name
% % outdatadir = 'N:\\ARLAnalysis\\TESTSTD4\\EEG';  % Processed data directory
% % outinterpdir = 'N:\\ARLAnalysis\\TESTSTD4\\EEGINTERP';  % Processed data directory
% % outsetdir = 'N:\\ARLAnalysis\\TESTSTD4\\EEGSET';  % Processed data directory
% % outrecdir = 'N:\\ARLAnalysis\\TESTSTD4\\REC';   % Bad channel info directory
% % htmlbase = 'N:\\ARLAnalysis\\TESTSTD4\\HTML';
% % if ~exist(htmlbase, 'dir')
% %     mkdir(htmlbase)
% % end
% % 
% % EEGchans = 1:64;           % Channels to compute reference on
% % rrefchans = 1:70;          % Channels to rereference at the end
% % fftchans = [48, 42, 58];   % Pick 3 channels for spectral display
% % linefreqs = [60, 120, 180];
% % for k = 15%11:18
% %     nb = sprintf('%02d', k);
% %     basename = [rootname nb];
% %     fprintf('Publishing %s...\n', basename);
% %     htmldir = [htmlbase filesep basename];
% %     if ~exist(htmldir, 'dir')
% %         mkdir(htmldir)
% %     end
% %     do_test_std2_pipeline;
% % %     script_name = 'do_test_std2_pipeline';
% % %     publish_options.outputDir = htmldir;
% % %     publish_options.maxWidth = maxWidth;
% % %     publish(script_name, publish_options);
% % %     close all
% % %     fclose('all');
% % end
% % 
% % 
% % % %% Set up the data directories and parameters for rsvp
% % % maxWidth = 800;   % Maximum width for time series figures in pixels
% % % indir = 'E:\\CTAData\\RSVP_HEADIT';  % Input data directory used for this demo
% % % rootname = 'rsvp_';         % Demo file base name
% % % outdatadir = 'N:\\ARLAnalysis\\TESTSTD3\\EEG';  % Processed data directory
% % % outrecdir = 'N:\\ARLAnalysis\\TESTSTD3\\REC';   % Bad channel info directory
% % % htmlbase = 'N:\\ARLAnalysis\\TESTSTD3\\HTML';
% % % if ~exist(htmlbase, 'dir')
% % %     mkdir(htmlbase)
% % % end
% % % 
% % % EEGchans = 1:248;
% % % linefreqs = [16, 28, 30, 32, 44, 48, 60, 76, 92, 120];
% % % rrefchans = 1:256;
% % % hpassfreq = 1;     % High pass frequency in Hz
% % % fftchans = [48, 12, 192];   % Pick 3 channels -- first should be Cz
% % % fftwin = 2048;
% % % for k = [1:7, 9:15]
% % %     nb = sprintf('%02d', k);
% % %     basename = [rootname nb];
% % %     fprintf('Publishing %s...\n', basename);
% % %     htmldir = [htmlbase filesep basename];
% % %     if ~exist(htmldir, 'dir')
% % %         mkdir(htmldir)
% % %     end
% % %     script_name = 'do_std_level2_comparison_line_noise';
% % %     publish_options.outputDir = htmldir;
% % %     publish_options.maxWidth = maxWidth;
% % %     publish(script_name, publish_options);
% % %     close all
% % %     fclose('all');
% % % end