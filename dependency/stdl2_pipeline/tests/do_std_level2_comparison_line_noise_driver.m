% Driver script for publishing bad channel visualizations

%% Set up on the EEGLAB sample data
maxWidth = 800;   % Maximum width for time series figures in pixels
indir = 'E:\\CTAData\\EEGLAB'; % Input data directory used for this demo
outdatadir = 'N:\\ARLAnalysis\\EEGLABSTD3\\EEG'; % Processed data directory
outrecdir = 'N:\\ARLAnalysis\\EEGLABSTD3\\REC';  % Bad channel info directory
htmlbase = 'N:\\ARLAnalysis\\EEGLABSTD3\\HTML';

%EEGchans = [1, 3:5, 7:32]; % Not using the EOG channels for referencing
EEGchans = 1:32;
hpassfreq = 1;             % High pass frequency in Hz
linefreqs = 60;
rrefchans = 1:32;          % Applying the average reference to these
fftchans = [1, 12, 28];    % Pick 3 channels -- first should be Cz
fftwin = 2048;             % FFT window size for visualizations
basename = 'sample';
fprintf('Publishing %s...\n', basename);
htmldir = [htmlbase filesep basename];
if ~exist(htmldir, 'dir')
    mkdir(htmldir)
end
do_std_level2_comparison_line_noise;
% script_name = 'do_std_level2_comparison_line_noise';
% publish_options.outputDir = htmldir;
% publish_options.maxWidth = maxWidth;
% publish(script_name, publish_options);
% close all
% fclose('all');

% %% Set up the data directories and parameters for vep resampled
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'E:\\CTAData\\VEP_RES';  % Input data directory used for this demo
% rootname = 'vep_';         % Demo file base name
% outdatadir = 'N:\\ARLAnalysis\\VEPSTD2RES\\EEG';  % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\VEPSTD2RES\\REC';   % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\VEPSTD2RES\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% EEGchans = 1:64;           
% mastchans = 69:70;         
% hpassfreq = 1;              % High pass frequency in Hz
% linefreqs = [60, 120, 180];
% rrefchans = 1:70;
% fftchans = [48, 12, 58];   % Pick 3 channels -- first should be Cz
% fftwin = 2048;             
% for k = 3%2:18
%     nb = sprintf('%02d', k);
%     basename = [rootname nb];
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     %do_std_level2_comparison_line_noise;
%     script_name = 'do_std_level2_comparison_line_noise';
%     publish_options.outputDir = htmldir;
%     publish_options.maxWidth = maxWidth;
%     publish(script_name, publish_options);
%     close all
%     fclose('all');
% end
% 


% %% Set up the data directories and parameters for vep
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'E:\\CTAData\\VEP';  %#ok<NASGU> % Input data directory used for this demo
% rootname = 'vep_';         % Demo file base name
% outdatadir = 'N:\\ARLAnalysis\\VEPSTD3\\EEG';  %#ok<NASGU> % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\VEPSTD3\\REC';   %#ok<NASGU> % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\VEPSTD3\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% EEGchans = 1:64;           %#ok<NASGU>
% mastchans = 69:70;         %#ok<NASGU>
% hpassfreq = 1;             %#ok<NASGU> % High pass frequency in Hz
% linefreqs = [60, 120, 180];
% rrefchans = 1:70;
% fftchans = [48, 12, 58];   %#ok<NASGU> % Pick 3 channels -- first should be Cz
% fftwin = 2048;             %#ok<NASGU>
% for k = 2:18
%     nb = sprintf('%02d', k);
%     basename = [rootname nb];
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     %do_std_level2_comparison_line_noise;
%     script_name = 'do_std_level2_comparison_line_noise';
%     publish_options.outputDir = htmldir;
%     publish_options.maxWidth = maxWidth;
%     publish(script_name, publish_options);
%     close all
%     fclose('all');
% end

% %% Set up the data directories and parameters for rsvp
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'E:\\CTAData\\RSVP_HEADIT';  % Input data directory used for this demo
% rootname = 'rsvp_';         % Demo file base name
% outdatadir = 'N:\\ARLAnalysis\\RSVPSTD2\\EEG';  % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\RSVPSTD2\\REC';   % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\RSVPSTD2\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% EEGchans = 1:248;
% linefreqs = [16, 28, 30, 32, 44, 48, 60, 76, 92, 120];
% rrefchans = 1:256;
% hpassfreq = 1;     % High pass frequency in Hz
% fftchans = [48, 12, 192];   % Pick 3 channels -- first should be Cz
% fftwin = 2048;
% for k = [1:7, 9:15]
%     nb = sprintf('%02d', k);
%     basename = [rootname nb];
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     script_name = 'do_std_level2_comparison_line_noise';
%     publish_options.outputDir = htmldir;
%     publish_options.maxWidth = maxWidth;
%     publish(script_name, publish_options);
%     close all
%     fclose('all');
% end

% %% Set up the data directories and parameters for bcit
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'N:\\Driving\\Level1';  % Input data directory used for this demo
% outdatadir = 'N:\\ARLAnalysis\BCIT\\EEG';  % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\BCIT\\REC';   % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\BCIT\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% % Get a list of the files in the driving data from level 1
% in_list = dir(indir);
% in_names = {in_list(:).name};
% in_types = [in_list(:).isdir];
% in_names = in_names(~in_types);
% 
% num_extra = 6;  % mastoids and 4 EOG channels
% filesuf = 4;  % # of letters to remove from end of file name for save
% linefreqs = [60, 120, 180, 300, 420, 540, 660, 790, 910];
% 
% hpassfreq = 1;     % High pass frequency in Hz
% fftchans = [48, 12, 1];   % Pick 3 channels -- first should be Cz
% fftwinfac = 4;     % Viz power spectra based on fftwinfac*srate FFT
% % EEGchans = 1:64;   % Only 64 channel headsets
% % rrefchans = 1:70;
% EEGchans = 1:256;   % Only 64 channel headsets
% rrefchans = 1:262;
% for k = 200:length(in_names)
% 
%     basename = in_names{k}(1:end-filesuf);
% %     chanblk = 32* floor(size(EEG.data, 1)/32);
% %     EEGchans = 1:chanblk;
% %     rrefchans = 1:(chanblk+num_extra);
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     script_name = 'do_std_level2_comparison_line_noise';
%     publish_options.outputDir = htmldir;
%     publish_options.maxWidth = maxWidth;
%     publish(script_name, publish_options);
%     close all
%     fclose('all');
% end

% %% Set up the data directories and parameters for bcit
% maxWidth = 800;   % Maximum width for time series figures in pixels
% indir = 'E:\\CTAData\BCIT-2.0\\2014-08-21  BCIT Driving Data test 2\\Data\\Missions';  % Input data directory used for this demo
% outdatadir = 'N:\\ARLAnalysis\\BCIT2\\EEG';  % Processed data directory
% outrecdir = 'N:\\ARLAnalysis\\BCIT2\\REC';   % Bad channel info directory
% htmlbase = 'N:\\ARLAnalysis\\BCIT2\\HTML';
% if ~exist(htmlbase, 'dir')
%     mkdir(htmlbase)
% end
% 
% 
% num_extra = 6;  % mastoids and 4 EOG channels
% filesuf = 4;  % # of letters to remove from end of file name for save
% linefreqs = [60, 120, 180, 300, 420, 540, 660, 790, 910];
% 
% hpassfreq = 1;     % High pass frequency in Hz
% fftchans = [48, 12, 1];   % Pick 3 channels -- first should be Cz
% fftwinfac = 4;     % Viz power spectra based on fftwinfac*srate FFT
% EEGchans = 1:64;   % Only 64 channel headsets
% rrefchans = 1:70;
% % EEGchans = 1:256;   % Only 64 channel headsets
% % rrefchans = 1:262;
% 
% 
%     basename = 'temp';
% %     chanblk = 32* floor(size(EEG.data, 1)/32);
% %     EEGchans = 1:chanblk;
% %     rrefchans = 1:(chanblk+num_extra);
%     fprintf('Publishing %s...\n', basename);
%     htmldir = [htmlbase filesep basename];
%     if ~exist(htmldir, 'dir')
%         mkdir(htmldir)
%     end
%     do_std_level2_comparison_line_noise;
% %     script_name = 'do_std_level2_comparison_line_noise';
% %     publish_options.outputDir = htmldir;
% %     publish_options.maxWidth = maxWidth;
% %     publish(script_name, publish_options);
% %     close all
% %     fclose('all');
