classdef level2Study
    % Be careful! any properties placed below will be written in the XML
    % file.
    properties
        % version of STDL2 used. Mandatory.
        studyLevel2SchemaVersion = ' ';
        
        % study title, in case file was moved.
        title = ' ';
        
        % a unique identifier (uuid) with 32 random  alphanumeric characters and four hyphens).
        % It is used to uniquely identify each STDL2 document.
        uuid = ' ';
        
        % the URI pointing to the root folder of associated data folder. If the XML file is located
        % in the default root folder, this should be ?.? (current directory). If for example the data files
        % and the root folder are placed on a remote FTP location, <rootURI> should be set to
        % ?ftp://domain.com/study?. The concatenation or <rootURI> and <filename> for each file
        % should always produce a valid, downloadable URI.adable URI.
        rootURI = '.';
        
        % Filters have a similar definition here as in BCILAB. They receive as input the EEG data
        % and output a transformation of the data that can be the input to other filters.
        % Here we are assuming a number of filters to have been executed on the data,
        % in the order specified in executionOrder (multiple numbers here mean multiple filter
        % runs.
        filters = struct('filter', struct('filterLabel', ' ', 'executionOrder', ' ', ...
            'softwareEnvironment', ' ', 'softwarePackage', ' ', 'functionName', ' ',...
            'parameters', struct('parameter', struct('name', ' ', 'value', ' ')), 'recordingParemeterSetLabel', ' '));
        
        % files containing EEGLAB datasets, each recording gets its own studyLevel2 file
        % (we do not combine datasets).
        studyLevel2Files = struct('studyLevel2File', struct('studyLevel2FileName', ' ', ...
            'dataRecordingUuid', ' ', 'noisyParametersFile', ' ', 'reportFileName', ' ', 'averageReferenceChannels', ' ', ...
            'rereferencedChannels', ' ', 'interpolatedChannels', ' ', 'nonInterpolatableChannels',  ' '));
    end;
    
    % properties that we do not want to be written/read to/from the XML
    % file are separated/distinguished here by assigning AbortSet = true.
    % This does not really change any of their behavior since AbortSet is
    % only relevant for handle classes.
    properties (AbortSet = true)
        % Filename (including path) of the ESS Standard Level 2 XML file associated with the
        % object.
        level2XmlFilePath
        
        % Filename (including path) of the ESS Standard Level 1 XML file
        % based on which level 2 data may be computed. Could be kept empty
        % if not available.
        level1XmlFilePath
        
        % Level 1 study contains basic information about study and raw data files.
        % It is created based on level1XmlFilePath input parameter
        level1StudyObj
        
        % ESS-convention level 2 folder where all level 2 data are
        % organized during level 1 -> 2 conversion using the pipeline.
        level2Folder
    end;
    
    methods
        function obj = level2Study(varargin)
            
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            
            inputOptions = arg_define(0,varargin, ...
                arg('level1XmlFilePath', '','','ESS Standard Level 1 XML Filename.', 'type', 'char'), ...
                arg('level2XmlFilePath', '','','ESS Standard Level 2 XML Filename.', 'type', 'char'), ...
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr') ...
                );
            
            obj.level2XmlFilePath = inputOptions.level2XmlFilePath;
            
            if ~isempty(obj.level2XmlFilePath)
                obj = obj.read;
            end;
            
            if ~isempty(inputOptions.level1XmlFilePath)
                level1Obj = level1Study(inputOptions.level1XmlFilePath);
                
                % make sure the uuids of of the level 2 and the provided
                % level 1 match.
                if ~isempty(strtrim(level1Obj.studyUuid)) && ...
                        ~isempty(obj.level1StudyObj) && ...
                        ~strcmp(strstim(level1Obj.studyUuid), strstim(obj.level1StudyObj))
                    error('The level 1 uuid in the provided level 1 XML file is different from the level 1 uuid in the provided level 2 xml file. Are you sure you are using the right file?');
                else
                    obj.level1StudyObj = level1Obj;
                    obj.level1XmlFilePath = inputOptions.level1XmlFilePath;
                end;
            end;
            
        end;
        
        function obj = write(obj, level2XmlFilePath)
            
            % assign the input file path as the object path and write
            % there.
            if nargin > 1
                obj.level2XmlFilePath = level2XmlFilePath;
            end;
            
            % use xml_io tools to write XML from a Matlab structure
            propertiesToExcludeFromXMLIO = findAttrValue(obj, 'AbortSet', true);
            
            % remove fields that are flagged for not being saved to the XML
            % file.
            warning('off', 'MATLAB:structOnObject');
            xmlAsStructure = rmfield(struct(obj), propertiesToExcludeFromXMLIO);
            warning('on', 'MATLAB:structOnObject');
            
            % include level 1 xml in studyLevel1 field. Write in a tempora
            temporaryLevel1XML = [tempname '.xml'];
            obj.level1StudyObj.write(temporaryLevel1XML);
            xmlAsStructure.studyLevel1 = xml_read(temporaryLevel1XML);
            delete(temporaryLevel1XML);
            if ~isempty(obj.level1XmlFilePath)
                pathstr = fileparts(obj.level1XmlFilePath);
                xmlAsStructure.studyLevel1.rootURI = pathstr; % save absolute path in root dir. This is so it can later read the recording files relative to this path.
            end;
            
            % prevent xml_ioi from adding extra 'Item' fields and write the XML
            Pref.StructItem = false;
            Pref.CellItem = false;
            xml_write(obj.level2XmlFilePath, xmlAsStructure, 'studyLevel2', Pref);
        end;
        
        function obj = read(obj)
            Pref.Str2Num = false;
            xmlAsStructure = xml_read(obj.level2XmlFilePath, Pref);
            names = fieldnames(xmlAsStructure);
            
            for i=1:length(names)
                if strcmp(names{i}, 'studyLevel1')
                    % load the level 1 data into its own object instead of
                    % a regular structure field under level 2
                    
                    % prevent xml_ioi from adding extra 'Item' fields and write the XML
                    Pref.StructItem = false;
                    Pref.CellItem = false;
                    temporaryLevel1XmlFilePath = [tempname '.xml'];
                    xml_write(temporaryLevel1XmlFilePath, xmlAsStructure.studyLevel1, 'studyLevel1', Pref);
                    
                    obj.level1StudyObj = level1Study(temporaryLevel1XmlFilePath);
                    
                else
                    obj.(names{i}) = xmlAsStructure.(names{i});
                end;
            end;
            
            %% TODO: convert integer values
            
            % the assignment above is quite raw as it does not check for the
            % consistency of inner values with deeper structures
            % TODO: Perform consistency check here, or use XSD validation.
            
        end;
        
        function obj = createLevel2Study(obj, varargin)
        % creates an ESS standardized data level 2 folder from level 1 XML 
        % and its data recordings using standard level 2 EEG processing pipeline.
        % You can continue where the processing was stopped by running the 
        % exact same command since it skips processing of already
        % calculated sessions.
        
            inputOptions = arg_define(1,varargin, ...
                arg('level2Folder', '','','Level 2 study folder. This folder will contain with processed data files, XML..', 'type', 'char'), ...
                arg({'params', 'Parameters'}, struct(),[],'Input parameters to for the processing pipeline.', 'type', 'object') ...
                );
            
            obj.level2Folder = inputOptions.level2Folder;
            
            % start from index 1 if the first studyLevel2File is pactically empty,
            % otherwise start after the last studyLevel2File
            if length(obj.studyLevel2Files.studyLevel2File) == 1 && isempty(strtrim(obj.studyLevel2Files.studyLevel2File(1).studyLevel2FileName))
                studyLevel2FileCounter = 1;
            else
                studyLevel2FileCounter = 1 + length(obj.studyLevel2Files.studyLevel2File);
            end;
            
            alreadyProcessedDataRecordingUuid = {};
            alreadyProcessedDataRecordingFileName = {};
            for i=1:length(obj.studyLevel2Files.studyLevel2File)
                recordingUuid = strtrim(obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid);
                if ~isempty(recordingUuid)
                    alreadyProcessedDataRecordingUuid{end+1} = recordingUuid;
                    alreadyProcessedDataRecordingFileName{end+1} = strtrim(obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName);
                end;
            end;
            
            % make top folders
            mkdir(inputOptions.level2Folder);
            mkdir([inputOptions.level2Folder filesep 'session']);
            mkdir([inputOptions.level2Folder filesep 'additional_data']);
            
            % process each session before moving to the other
            for i=1:length(obj.level1StudyObj.sessionTaskInfo)
                for j=1:length(obj.level1StudyObj.sessionTaskInfo(i).dataRecording)
                    % do not processed data recordings that have already
                    % been processed.
                    [fileIsListedAsProcessed, id]= ismember(obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid, alreadyProcessedDataRecordingUuid);
                    
                    % make sure not only the file is listed as processed,
                    % but also it exists on disk (otherwise recompute).
                    if fileIsListedAsProcessed
                        level2FileNameOfProcessed = alreadyProcessedDataRecordingFileName{id};
                        processedFileIsOnDisk = ~isempty(findFile(level2FileNameOfProcessed, inputOptions.level2Folder));
                    end;
                    if fileIsListedAsProcessed && processedFileIsOnDisk
                        fprintf('Skipping session %s: it has already been processed (both listed in the XML and exists on disk).\n', obj.level1StudyObj.sessionTaskInfo(i).sessionNumber);
                    else % file has not yet been processed
                        fileNameFromObj = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).filename;
                        
                        % read data
                        if ~isempty(obj.level1XmlFilePath)
                            level1FileFolder = fileparts(obj.level1XmlFilePath);
                            
                            if isempty(obj.rootURI)
                                rootFolder = level1FileFolder;
                            elseif obj.rootURI(1) == '.' % if the path is relative, append the current absolute path
                                rootFolder = [level1FileFolder filesep obj.rootURI(2:end)];
                            else
                                rootFolder = obj.level1StudyObj.rootURI;
                            end;
                        else
                            rootFolder = obj.level1StudyObj.rootURI;
                        end;
                        
                        fileFinalPath = findFile(fileNameFromObj, rootFolder);
                        
                        % read raw EEG data
                        EEG = exp_eval(io_loadset(fileFinalPath));                        
                        
                        % find EEG channels subsets
                        dataRecordingParameterSet = [];
                        for kk = 1:length(obj.level1StudyObj.recordingParameterSet)
                            if strcmpi(obj.level1StudyObj.recordingParameterSet(kk).recordingParameterSetLabel, obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel)
                                dataRecordingParameterSet = obj.level1StudyObj.recordingParameterSet(kk);
                                break;
                            end;
                        end;
                        
                        if isempty(dataRecordingParameterSet)
                            % ToDo: Throw a better error message
                            error('RecordingParameterSet label is not valid');
                        end;
                        
                        % find EEG channels
                        allEEGChannels = [];
                        allScalpChannels = [];
                        allEEGChannelLabels = {};
                        allChannelLabels = {}; % the label for each channel, whether it be EEG, MocaP..
                        allChannelTypes = {}; % the type of each channel
                        for m = 1:length(dataRecordingParameterSet.modality)
                            
                            startChannel = str2double(dataRecordingParameterSet.modality(m).startChannel);
                            endChannel   = str2double(dataRecordingParameterSet.modality(m).endChannel);
                            newChannels = startChannel:endChannel;
                            newChannelLabels = strtrim(strsplit(dataRecordingParameterSet.modality(m).channelLabel, ','));
                            
                            allChannelTypes(newChannels) = {dataRecordingParameterSet.modality(m).type};
                            if length(newChannelLabels) == length(newChannels)
                                allChannelLabels(newChannels) = newChannelLabels;
                            else
                                error('Number of channel lables does not match star and end channel values');
                            end;
                            
                            if strcmpi(dataRecordingParameterSet.modality(m).type, 'EEG')
                                nonScalpChannelLabels = strtrim(strsplit(dataRecordingParameterSet.modality(m).nonScalpChannelLabel, ','));
                                nonScalpChannel = ismember(lower(newChannelLabels), lower(nonScalpChannelLabels));
                                allEEGChannels = [allEEGChannels newChannels];
                                allScalpChannels = [allScalpChannels newChannels(~nonScalpChannel)];
                                
                                allEEGChannelLabels = cat(1, allEEGChannelLabels, newChannelLabels);
                                newChannelLabels = cat(1, newChannelLabels, nonScalpChannelLabels); %#ok<NASGU>
                            end;
                        end;
                        
                        % assign channel type in EEG.chanlocs
                        for chanCounter = 1:length(allChannelTypes)
                            EEG.chanlocs(chanCounter).type = allChannelTypes{chanCounter};
                            
                            % place labels from XML into EEG.chanlocs when
                            % empty.
                            if isempty(EEG.chanlocs(chanCounter).labels)
                                EEG.chanlocs(chanCounter).labels = allChannelLabels{chanCounter};
                            elseif strcmpi(allChannelTypes{chanCounter}, 'EEG') && ~strcmpi(EEG.chanlocs(chanCounter).labels, allChannelLabels{chanCounter});
                                % ToDo: make a better error message.
                                error('Channel labels from level 1 XML file and EEG recording are inconsistent for %s file.', fileNameFromObj);
                            end;
                        end;
                        
                        %ToDo: make it work for multiple subjects and their
                        %channel locations.
                        % read digitized channel locations (if exists)
                        if ~ismember(lower(strtrim(obj.level1StudyObj.sessionTaskInfo(i).subject(1).channelLocations)), {'', 'na'})
                            fileFinalPathForChannelLocation = findFile(obj.level1StudyObj.sessionTaskInfo(i).subject(1).channelLocations, rootFolder);
                            chanlocsFromFile = readlocs(fileFinalPathForChannelLocation);
                            
                            % check if there are enough channels in EEG.data
                            % (at least the size of EEG channels expected).
                            if length(allEEGChannelLabels) > size(EEG.data, 1)
                                error('There are less channels in %s file than EEG channels specified by recordingParameterSet %d',  fileNameFromObj, dataRecordingParameterSet);
                            end;
                            
                            % sometimes channel location file does not
                            % contain locations for all channels, esp.
                            % channels like EXG, Mastoid, EMG.
                            if length(chanlocsFromFile) ~= size(EEG.data, 1)
                                labelsFromFile = {chanlocsFromFile.labels};
                                
                                % the the option with more labels, either
                                % from the EEG.chanlocs or from the XML
                                % file. 
                                % ToDo: rconsider this if.
                                if length(labelsFromFile) >= length(allEEGChannelLabels)
                                    channelLabelsToUse = labelsFromFile;
                                else
                                    channelLabelsToUse = allEEGChannelLabels;
                                end;
                                
                                for ccounter = 1:length(allEEGChannels)
                                    newLocation = chanlocsFromFile(strcmpi(labelsFromFile, channelLabelsToUse{allEEGChannels(ccounter)}));
                                    if isempty(newLocation) && ismember(lower(channelLabelsToUse{allEEGChannels(ccounter)}), lower(allChannelLabels(allScalpChannels)))
                                        error('Label %s on the scalp does not have a location associated with it in %s file.', channelLabelsToUse{allEEGChannels(ccounter)}, fileNameFromObj);
                                    else
                                        fieldNames = fieldnames(newLocation);
                                        for fieldCounter = 1:length(fieldNames)
                                            EEG.chanlocs(allEEGChannels(ccounter)).(fieldNames{fieldCounter}) = newLocation.(fieldNames{fieldCounter});
                                        end;
                                    end;
                                end;
                                
                            end;
                        else % try assigning channel locations by matching labels to known 10-20 montage standard locations in BEM (MNI head) model
                            EEG = pop_chanedit(EEG, 'lookup', 'standard_1005.elc');
                        end;
                        
                        % run the pipeline
                        
                        % set the parameters
                        params = struct();
                        params.lineFrequencies = [60, 120,  180, 212, 240];
                        params.referenceChannels = allScalpChannels;
                        params.rereferencedChannels = allEEGChannels;
                        params.highPassChannels = params.rereferencedChannels;
                        params.lineNoiseChannels = params.rereferencedChannels;
                        params.name = [obj.level1StudyObj.studyTitle ', session ' obj.level1StudyObj.sessionTaskInfo(i).sessionNumber ', task ', obj.level1StudyObj.sessionTaskInfo(i).taskLabel ', recording ' num2str(j)];
                        
                        % execute the pipeline
                        [EEG, computationTimes] = standardLevel2Pipeline(EEG, params);
                        
                        fprintf('Computation times (seconds): %g high pass, %g resampling, %g line noise, %g reference \n', ...
                            computationTimes.highPass, computationTimes.resampling, ...
                            computationTimes.lineNoise, computationTimes.reference);
                        
                        % pop_loadset('eeg_studyLevel2_NCTU_Lane-Keeping_Task_session_5_subject_1_task_motionless_s01_060926_1n_recording_1.set', 'C:\Users\Nima\Documents\MATLAB\tools\playground\level2\session\5');
                        
                        % write processed EEG data
                        sessionFolder = [inputOptions.level2Folder filesep 'session' filesep obj.level1StudyObj.sessionTaskInfo(i).sessionNumber];
                        if ~exist(sessionFolder, 'dir')
                            mkdir(sessionFolder);
                        end;
                        
                        % if recording file name matches ESS Level 1 convention
                        % then just modify it a bit to conform to level2
                        [path, name, ext] = fileparts(fileFinalPath); %#ok<ASGLU>
                        
                        % see if the file name is already in ESS
                        % format, hence no name change is necessary
                        subjectInSessionNumber = obj.level1StudyObj.sessionTaskInfo(i).subject(j).inSessionNumber;
                        itMatches = level1Study.fileNameMatchesEssConvention([name ext], 'eeg', obj.level1StudyObj.studyTitle, obj.level1StudyObj.sessionTaskInfo(i).sessionNumber,...
                            subjectInSessionNumber, obj.level1StudyObj.sessionTaskInfo(i).taskLabel, j);
                        
                        if itMatches
                            % change the eeg_ at the beginning to
                            % eeg_studyLevel2_
                            filenameInEss = ['eeg_studyLevel2_' name(5:end) ext];
                        else % convert to ess convention
                            filenameInEss = obj.essConventionFileName('eeg', ['studyLevel2_' obj.level1StudyObj.studyTitle], obj.level1StudyObj.sessionTaskInfo(i).sessionNumber,...
                                subjectInSessionNumber, obj.level1StudyObj.sessionTaskInfo(i).taskLabel, j, name, extension);
                        end;
                        
                        pop_saveset(EEG, 'filename', filenameInEss, 'filepath', sessionFolder, 'savemode', 'onefile', 'version', '7.3');
                        
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).studyLevel2FileName = filenameInEss;
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).dataRecordingUuid = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid;
                        
                        % create the PDF report, save it and specify in XML
                        reportFileName = ['report_' filenameInEss(1:end-4) '.pdf'];
                        relativeSessionFolder = ['.' filesep 'session' ...
                            filesep obj.level1StudyObj.sessionTaskInfo(i).sessionNumber];
                        publishLevel2Report(EEG, ...
                            inputOptions.level2Folder, 'summaryReport.html', ...
                            relativeSessionFolder, reportFileName);
                        
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).reportFileName = reportFileName;
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).averageReferenceChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, allScalpChannels, 'UniformOutput', false));
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).rereferencedChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, allEEGChannels, 'UniformOutput', false));
                        obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).interpolatedChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, EEG.etc.noisyParameters.reference.interpolatedChannels, 'UniformOutput', false));
                        
                        %% write the filters
                        
                        % only add filters for a recordingParemeterSetLabel
                        % if it does not have fileters for the pipeline
                        % already defined for it.
                        listOfEecordingParemeterSetLabelWithFilters = {};
                        for f = 1:length(obj.filters.filter)
                            listOfEecordingParemeterSetLabelWithFilters{f} = obj.filters.filter(f).recordingParameterSetLabel;
                        end;
                        
                        if ~ismember(dataRecordingParameterSet.recordingParameterSetLabel, listOfEecordingParemeterSetLabelWithFilters)
                            eeglabVersionString = ['EEGLAB ' eeg_getversion];
                            matlabVersionSTring = ['MATLAB '  version];
                            
                            filterLabel = {'High-Pass Filter', 'Resampling', 'Line Noise Removal'};
                            filterFieldName = {'highPass' 'resampling' 'lineNoise' 'reference'};
                            filterFunctionName = {'highPassFilter' 'resampleEEG' 'cleanLineNoise' };
                            
                            for f=1:length(filterLabel)
                                newFilter = struct;
                                newFilter.filterLabel = filterLabel{f};
                                newFilter.executionOrder = num2str(f);
                                newFilter.softwareEnvironment = matlabVersionSTring;
                                newFilter.softwarePackage = eeglabVersionString;
                                newFilter.functionName = filterFunctionName{f};
                                fields = fieldnames(EEG.etc.noisyParameters.(filterFieldName{f}));
                                for p=1:length(fields)
                                    newFilter.parameters.parameter(p).name = fields{p};
                                    newFilter.parameters.parameter(p).value = num2str(EEG.etc.noisyParameters.(filterFieldName{f}).(fields{p}));
                                end;
                                newFilter.recordingParemeterSetLabel = dataRecordingParameterSet.recordingParameterSetLabel;
                                
                                obj.filters.filter(end+1) = newFilter;
                            end;
                            
                            % Reference (too complicated to pu above)
                            newFilter = struct;
                            newFilter.filterLabel = 'Robust Reference Removal';
                            newFilter.executionOrder = '4';
                            newFilter.softwareEnvironment = matlabVersionSTring;
                            newFilter.softwarePackage = eeglabVersionString;
                            newFilter.functionName = 'robustReference';
                            fields = {'robustDeviationThreshold', 'highFrequencyNoiseThreshold', 'correlationWindowSeconds', ...
                                'correlationThreshold', 'badTimeThreshold', 'ransacSampleSize', 'ransacChannelFraction', ...
                                'ransacCorrelationThreshold', 'ransacUnbrokenTime', 'ransacWindowSeconds'};
                            for p=1:length(fields)
                                newFilter.parameters.parameter(p).name = fields{p};
                                newFilter.parameters.parameter(p).value = num2str(EEG.etc.noisyParameters.reference.noisyOut.(fields{p}));
                            end;
                            
                            newFilter.parameters.parameter(end+1).name = 'referenceChannels';
                            newFilter.parameters.parameter(end).value = num2str(EEG.etc.noisyParameters.reference.referenceChannels);
                            
                            newFilter.parameters.parameter(end+1).name = 'rereferencedChannels';
                            newFilter.parameters.parameter(end).value = num2str(EEG.etc.noisyParameters.reference.rereferencedChannels);
                            newFilter.recordingParemeterSetLabel = dataRecordingParameterSet.recordingParameterSetLabel;
                            
                            obj.filters.filter(end+1) = newFilter;
                        end;
                        
                        studyLevel2FileCounter = studyLevel2FileCounter + 1;
                        obj.write([inputOptions.level2Folder filesep 'studyLevel2_description.xml']);
                    end;
                end;
            end;
            
            function fileFinalPathOut = findFile(fileNameFromObjIn, rootFolder)
                % search for the file both next to the xml file and in the standard ESS
                % convention location
                nextToXMLFilePath = [rootFolder filesep fileNameFromObjIn];
                fullEssFilePath = [rootFolder filesep 'session' filesep obj.level1StudyObj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObjIn];
                
                if ~isempty(fileNameFromObjIn) && exist(fullEssFilePath, 'file')
                    fileFinalPathOut = fullEssFilePath;
                elseif ~isempty(fileNameFromObjIn) && exist(nextToXMLFilePath, 'file')
                    fileFinalPathOut = nextToXMLFilePath;
                elseif ~isempty(fileNameFromObjIn) % when the file is specified but cannot be found on disk
                    fileFinalPathOut = [];
                    fprintf('File %s specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s.\n', fileNameFromObjIn, j, obj.level1StudyObj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath);
                    fprintf('You might want to run validate() routine.\n');
                else % the file name is empty
                    fileFinalPathOut = [];
                    fprintf('You have not specified any file for data recoding %d of sesion number %s\n', j, obj.level1StudyObj.sessionTaskInfo(i).sessionNumber);
                    fprintf('You might want to run validate() routine.\n');
                end;
            end
            
        end;
        
        function applyFunctionToLevel2Data(obj, functionHandle, outputFolder, parameters)
            
            % find associated level 1 information for each level 2 (EEG) data file
            uuidList = {};
            sessionId = [];
            dataRecordingInLevel1Id = [];
            for i=1:length(obj.level1StudyObj.sessionTaskInfo)
                for j=1:length(obj.level1StudyObj.sessionTaskInfo(i).dataRecording)
                    uuidList{end+1} = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid;
                    sessionId(end+1) = i;
                    dataRecordingInLevel1Id(end+1) = j;
                end;
            end;
            
            for i=1:length(obj.studyLevel2Files.studyLevel2File)
                 level2DataFilename = obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName;
                 id =strcmp(obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, uuidList);
                 level2DataSessionNumber = sessionId(id);
             end;
        end;
    end;
end