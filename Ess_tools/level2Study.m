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
        
        % Total size of data the study folder contains (this could be approximate)
        totalSize = ' ';
        
        % Filters have a similar definition here as in BCILAB. They receive as input the EEG data
        % and output a transformation of the data that can be the input to other filters.
        % Here we are assuming a number of filters to have been executed on the data,
        % in the order specified in executionOrder (multiple numbers here mean multiple filter
        % runs.
        filters = struct('filter', struct('filterLabel', ' ', 'executionOrder', ' ', ...
            'softwareEnvironment', ' ', 'softwarePackage', ' ', 'functionName', ' ',...
            'parameters', struct('parameter', struct('name', ' ', 'value', ' ')), 'recordingParameterSetLabel', ' '));
        
        % files containing EEGLAB datasets, each recording gets its own studyLevel2 file
        % (we do not combine datasets).
        studyLevel2Files = struct('studyLevel2File', struct('studyLevel2FileName', ' ', ...
            'dataRecordingUuid', ' ', 'noiseDetectionResultsFile', ' ', 'reportFileName', ' ',...
            'averageReferenceChannels', ' ', 'eventInstanceFile', ' ',...
            'rereferencedChannels', ' ', 'interpolatedChannels', ' ', 'dataQuality', ' '));
        
        license = struct('type', ' ', 'text', ' ', 'link',' ');
        
        % Information about the project under which this experiment is
        % performed.
        projectInfo = struct('organization', ' ',  'grantId', ' ');
        
        % Information of individual to contact for data results, or more information regarding the study/data.
        contactInfo = struct ('name', ' ', 'phone', ' ', 'email', ' ');
        
        % Iinformation regarding the organization that conducted the
        % research study.
        organizationInfo = struct('name', ' ', 'logoLink', ' ');
        
        % Copyright information.
        copyrightInfo = ' ';
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
        % created a Leve 2 object, either from a Level 2 container, or by starting from a Level 1 container 
        % (using 'level1XmlFilePath' option) and processing it with Standardized Data Level 2 (STDL2) pipeline 
        % to create a Level 2 container. This is done in two stages, see Example 1 below: 
        %
        % Use:
        % obj = level2Study([key, value pairs])
        % 
        % Example 1: creating a proper Level 2 container from Level 1
        %
        %   obj = level2Study('level1XmlFilePath', 'C:\Users\You\Awesome_EEG_stud\level_1\'); % this load the data but does not make a proper Level 2 container yet (Obj it is still mostly empty).
        %   obj = obj.createLevel2Study( 'C:\Users\You\Awesome_EEG_stud\level_2\'); % this command start appling the preprocessing pipelines and makes a proper Level 2 object. 
        %  
        % Example 2: loading an already-made Level 2 container.
        %
        % obj = level2Study('level2XmlFilePath', 'C:\Users\You\Awesome_EEG_stud\level_2\');
        %
        % Options 
        %   Key                      Value
        %   'level2XmlFilePath'      : a string pointing to either a Level 2 container folder or its xml file.  
        %   'level1XmlFilePath'      : a string pointing to either a Level 1 container folder or its xml file.
        %   'createNewFile'          : Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) 
        %                              ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.
        
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            
            inputOptions = arg_define(0,varargin, ...
                arg('level2XmlFilePath', '','','ESS Standard Level 2 XML Filename.', 'type', 'char'), ...
                arg('level1XmlFilePath', '','','ESS Standard Level 1 XML Filename.', 'type', 'char'), ...
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr') ...
                );
            
            % if the folder 'container' is instead of filename provided, use the default
            % 'study_description.xml' file.
            if exist(inputOptions.level1XmlFilePath, 'dir')...
                    && exist([inputOptions.level1XmlFilePath filesep 'study_description.xml'], 'file')
                inputOptions.level1XmlFilePath = [inputOptions.level1XmlFilePath filesep 'study_description.xml'];
            end;
            
            if exist(inputOptions.level2XmlFilePath, 'dir')...
                    && exist([inputOptions.level2XmlFilePath filesep 'studyLevel2_description.xml'], 'file')
                inputOptions.level2XmlFilePath = [inputOptions.level2XmlFilePath filesep 'studyLevel2_description.xml'];
            end;
            
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
            xml_write(obj.level2XmlFilePath, xmlAsStructure, {'studyLevel2' 'xml-stylesheet type="text/xsl" href="xml_level_2_style.xsl"' 'This file is created based on EEG Study Schema (ESS) Level 2. Visit eegstudy.org for more information.'}, Pref);
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
            
            if isempty(obj.title)
                obj.title  = '';
            end;
            
            if isempty(obj.uuid)
                obj.uuid =  '';
            end;
        end;
        
        function obj = createLevel2Study(obj, varargin)
        % creates an ESS standardized data level 2 folder from level 1 XML
        % and its data recordings using standard level 2 EEG processing pipeline.
        % You can continue where the processing was stopped by running the
        % exact same command since it skips processing of already
        % calculated sessions.
	% 
	% Example:
	% 
	%	obj = level2Study('level1XmlFilePath', 'C:\Users\You\Awesome_EEG_stud\level_1\'); % this load the data but does not make a proper Level 2 container yet (Obj it is still mostly empty).
	%	obj = obj.createLevel2Study( 'C:\Users\You\Awesome_EEG_stud\level_2\'); % this command start applying the preprocessing pipelines and makes a proper Level 2 object. 
	% 
	% Options:
	%
	%	Key				Value
	%
	% 	'level2Folder'			: String,  Level 2 study folder. This folder will contain with processed data files, XML..
	% 	'params'			: Cell array, Input parameters to for the processing pipeline.
	%	'sessionSubset' 		: Integer Array, Subset of sessions numbers (empty = all).
	% 	'forTest'			: Logical, For Debugging ONLY. Process a small data sample for test.
		
            
            inputOptions = arg_define(1,varargin, ...
                arg('level2Folder', '','','Level 2 study folder. This folder will contain with processed data files, XML..', 'type', 'char'), ...
                arg({'params', 'Parameters'}, struct(),[],'Input parameters to for the processing pipeline.', 'type', 'object') ...
                ,arg('sessionSubset', [],[],'Subset of sessions numbers (empty = all).', 'type', 'denserealsingle') ...
                ,arg('forTest', false,[],'Process a small data sample for test.', 'type', 'logical') ...
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
            
            obj.uuid = char(java.util.UUID.randomUUID);
            obj.title = obj.level1StudyObj.studyTitle;
            obj.studyLevel2SchemaVersion  = '1.0';
            
            % process each session before moving to the other
            for i=1:length(obj.level1StudyObj.sessionTaskInfo)
                for j=1:length(obj.level1StudyObj.sessionTaskInfo(i).dataRecording)
                    if isempty(inputOptions.sessionSubset) || ismember(str2double(obj.level1StudyObj.sessionTaskInfo(i).sessionNumber), inputOptions.sessionSubset)
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
                            % since io_loadset() assigns arbitrary labels when
                            % EEG.chanlocs is empty, we use pop_loadset for
                            % .set  files
                            [pathstr, nameOfFile,extensionOfFile] = fileparts(fileFinalPath);
                            if strcmpi(extensionOfFile, '.set')
                                EEG = pop_loadset([nameOfFile extensionOfFile], pathstr);
                            else
                                EEG = exp_eval(io_loadset(fileFinalPath));
                            end;
                            
                            % add HED tags based on events
                            if ~strcmpi(obj.level1StudyObj.eventSpecificiationMethod, 'Tags')
                                EEG = addUsertagsToEEG(obj, EEG, i);
                            end;
                            
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
                                    error('Number of channel labels does not match start and end channel values');
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
                                % empty or non-existent.
                                if ~isfield(EEG.chanlocs, 'labels') || isempty(EEG.chanlocs(chanCounter).labels)
                                    EEG.chanlocs(chanCounter).labels = allChannelLabels{chanCounter};
                                elseif strcmpi(allChannelTypes{chanCounter}, 'EEG') && ~strcmpi(EEG.chanlocs(chanCounter).labels, allChannelLabels{chanCounter});
                                    % ToDo: make a better error message.
                                    keyboard;
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
                                        elseif ~isempty(newLocation)                                            
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
                            params.evaluationChannels = allScalpChannels;
                            params.rereferencedChannels = allEEGChannels;
                            params.detrendChannels = params.rereferencedChannels;
                            params.lineNoiseChannels = params.rereferencedChannels;
                            params.name = [obj.level1StudyObj.studyTitle ', session ' obj.level1StudyObj.sessionTaskInfo(i).sessionNumber ', task ', obj.level1StudyObj.sessionTaskInfo(i).taskLabel ', recording ' num2str(j)];
                            
                            % for test only
                            if inputOptions.forTest
                                fprintf('Cutting data, WARNING: ONLY FOR TESTING, REMOVE THIS FOR PRODUCTION!\n');
                                EEG = pop_select(EEG, 'point', 1:round(size(EEG.data,2)/100));
                            end;
                            
                            % execute the pipeline
                            [EEG, computationTimes] = prepPipeline(EEG, params);
                            
                            % use noiseDetection instead of noisyParameters
                            if isfield(EEG.etc, 'noisyParameters')
                                EEG.etc.noiseDetection = EEG.etc.noisyParameters;
                            end;
                            
                            fprintf('Computation times (seconds): \n%s\n', ...
                                getStructureString(computationTimes));

                            % place the recording uuid in EEG.etc so we
                            % keep the association.
                            EEG.etc.dataRecordingUuid = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid;
                            
                            % place subject and group information inside
                            % EEG structure
                            if length(obj.level1StudyObj.sessionTaskInfo(i).subject) == 1                                
                                if isempty(obj.level1StudyObj.sessionTaskInfo(i).subject.labId)
                                    EEG.subject = ['subject_of_session_' obj.level1StudyObj.sessionTaskInfo(i).sessionNumber];
                                else
                                    EEG.subject = obj.level1StudyObj.sessionTaskInfo(i).subject.labId;
                                end;
                                if ~isempty(obj.level1StudyObj.sessionTaskInfo(i).subject.group)
                                    EEG.group = obj.level1StudyObj.sessionTaskInfo(i).subject.group;
                                end;
                            end;
                            
                            
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
                            subjectInSessionNumber = obj.level1StudyObj.getInSessionNumberForDataRecording(obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j));
                            itMatches = level1Study.fileNameMatchesEssConvention([name ext], 'eeg', obj.level1StudyObj.studyTitle, obj.level1StudyObj.sessionTaskInfo(i).sessionNumber,...
                                subjectInSessionNumber, obj.level1StudyObj.sessionTaskInfo(i).taskLabel, j);
                            
                            if itMatches
                                % change the eeg_ at the beginning to
                                % eeg_studyLevel2_
                                filenameInEss = ['eeg_studyLevel2_' name(5:end) ext];
                            else % convert to ess convention
                                filenameInEss = obj.level1StudyObj.essConventionFileName('eeg', ['studyLevel2_' obj.level1StudyObj.studyTitle], obj.level1StudyObj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.level1StudyObj.sessionTaskInfo(i).taskLabel, j, '', extension);
                            end;
                            
                            pop_saveset(EEG, 'filename', filenameInEss, 'filepath', sessionFolder, 'savemode', 'onefile', 'version', '7.3');
                            
                            % copy the event instance file from level 1
                            % into level 2 folder and assign the node in
                            % level 2
                            eventInstantFileFinalPath = findFile(obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile, rootFolder);
                            copyfile(eventInstantFileFinalPath, [sessionFolder filesep obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile]);
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).eventInstanceFile = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile;
                            
                            % write HDF5 file and place the noise detection filename in XML
                            hdf5Filename = writeNoiseDetectionFile(obj, EEG, i, j, sessionFolder);
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).noiseDetectionResultsFile = hdf5Filename;
                            
                            % place EEG filename and UUID in XML
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).studyLevel2FileName = filenameInEss;
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).dataRecordingUuid = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid;
                            
                            % create the PDF report, save it and specify in XML
                            reportFileName = writeReportFile(obj, EEG, filenameInEss, i, inputOptions.level2Folder);
                            
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).reportFileName = reportFileName;
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).averageReferenceChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, allScalpChannels, 'UniformOutput', false));
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).rereferencedChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, allEEGChannels, 'UniformOutput', false));
                            
                            if isfield(EEG.etc.noiseDetection, 'reference')
                                obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).interpolatedChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, EEG.etc.noiseDetection.reference.interpolatedChannels.all, 'UniformOutput', false));
                                % assume data quality hass been 'Good' (can be set to
                                % 'Suspect or 'Unusable' later)
                                obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).dataQuality = 'Good';
                            else
                                obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).interpolatedChannels = [];
                                obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).dataQuality = 'Unusable';
                            end
                            
                            obj.studyLevel2Files.studyLevel2File(studyLevel2FileCounter).interpolatedChannels = strjoin_adjoiner_first(',', arrayfun(@num2str, EEG.etc.noiseDetection.reference.interpolatedChannels.all, 'UniformOutput', false));
                            
                            
                            %% write the filters
                            
                            % only add filters for a recordingParameterSetLabel
                            % if it does not have filters for the pipeline
                            % already defined for it.
                            listOfEecordingParemeterSetLabelWithFilters = {};
                            for f = 1:length(obj.filters.filter)
                                listOfEecordingParemeterSetLabelWithFilters{f} = obj.filters.filter(f).recordingParameterSetLabel;
                            end;
                            
                            if ~ismember(dataRecordingParameterSet.recordingParameterSetLabel, listOfEecordingParemeterSetLabelWithFilters)
                                eeglabVersionString = ['EEGLAB ' eeg_getversion];
                                matlabVersionSTring = ['MATLAB '  version];
                                
                                filterLabel = {'Resampling', 'Line Noise Removal'};
                                filterFieldName = {'resampling' 'lineNoise'};
                                filterFunctionName = {'resampleEEG' 'cleanLineNoise'};

                               
                                for f=1:length(filterLabel)
                                    newFilter = struct;
                                    newFilter.filterLabel = filterLabel{f};
                                    newFilter.executionOrder = num2str(f);
                                    newFilter.softwareEnvironment = matlabVersionSTring;
                                    newFilter.softwarePackage = eeglabVersionString;
                                    newFilter.functionName = filterFunctionName{f};
                                    fields = fieldnames(EEG.etc.noiseDetection.(filterFieldName{f}));
                                    for p=1:length(fields)
                                        newFilter.parameters.parameter(p).name = fields{p};
                                        newFilter.parameters.parameter(p).value = num2str(EEG.etc.noiseDetection.(filterFieldName{f}).(fields{p}));
                                    end;
                                    newFilter.recordingParameterSetLabel = dataRecordingParameterSet.recordingParameterSetLabel;
                                    
                                    obj.filters.filter(end+1) = newFilter;
                                end;
                                
                                % Reference (too complicated to put above)
                                if (isfield(EEG.etc.noiseDetection, 'reference'))
                                    newFilter = struct;
                                    newFilter.filterLabel = 'Robust Reference Removal';
                                    newFilter.executionOrder = '3';
                                    newFilter.softwareEnvironment = matlabVersionSTring;
                                    newFilter.softwarePackage = eeglabVersionString;
                                    newFilter.functionName = 'robustReference';
                                    fields = {'robustDeviationThreshold', 'highFrequencyNoiseThreshold', 'correlationWindowSeconds', ...
                                        'correlationThreshold', 'badTimeThreshold', 'ransacSampleSize', 'ransacChannelFraction', ...
                                        'ransacCorrelationThreshold', 'ransacUnbrokenTime', 'ransacWindowSeconds'};
                                    for p=1:length(fields)
                                        newFilter.parameters.parameter(p).name = fields{p};
                                        newFilter.parameters.parameter(p).value = num2str(EEG.etc.noiseDetection.reference.noisyStatistics.(fields{p}));
                                    end;
                                    
                                    newFilter.parameters.parameter(end+1).name = 'referenceChannels';
                                    newFilter.parameters.parameter(end).value = num2str(EEG.etc.noiseDetection.reference.referenceChannels);
                                    
                                    newFilter.parameters.parameter(end+1).name = 'rereferencedChannels';
                                    newFilter.parameters.parameter(end).value = num2str(EEG.etc.noiseDetection.reference.rereferencedChannels);
                                    newFilter.recordingParameterSetLabel = dataRecordingParameterSet.recordingParameterSetLabel;
                                    
                                    obj.filters.filter(end+1) = newFilter;
                                end;
                            end;
                            
                            % remove any filter with an empty (the first
                            % one created by the object)
                            removeId = [];
                            for f=1:length(obj.filters.filter)
                                if isempty(strtrim(obj.filters.filter(f).filterLabel))
                                    removeId = [removeId f];
                                end;
                            end;
                            obj.filters.filter(removeId) = [];
                            
                            studyLevel2FileCounter = studyLevel2FileCounter + 1;
                            obj.level2XmlFilePath = [inputOptions.level2Folder filesep 'studyLevel2_description.xml'];                            
                            obj.write(obj.level2XmlFilePath);
                        end;
                    end;
                    
                    clear EEG;
                end;
            end;

            % Level 2 total study size
            [dummy, obj.totalSize]= dirsize(fileparts(obj.level2XmlFilePath)); %#ok<ASGLU>
            obj.write(obj.level2XmlFilePath);
            
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
       
        
        function EEG = addUsertagsToEEG(obj, EEG, sessionTaskNumber)
            % add usertags based on (eventcode,hed string) associations for
            % the task.
            
            studyEventCode = {obj.level1StudyObj.eventCodesInfo.code};
            studyEventCodeTaskLabel = {obj.level1StudyObj.eventCodesInfo.taskLabel};
            
            studyEventCodeHedString = {};
            for i = 1:length(obj.level1StudyObj.eventCodesInfo)
                studyEventCodeHedString{i} = obj.level1StudyObj.eventCodesInfo(i).condition.tag;
                
                % add tags for label and description if they do not already exist
                hedTags = strtrim(strsplit(studyEventCodeHedString{i}, ','));
                labelTagExists = strfind(lower(hedTags), 'event/label/');
                descriptionTagExists = strfind(lower(hedTags), 'event/description/');
                
                if all(cellfun(@isempty, labelTagExists))
                    studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Label/' obj.level1StudyObj.eventCodesInfo(i).condition.label];
                end;
                
                if all(cellfun(@isempty, descriptionTagExists))
                    studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Description/' obj.level1StudyObj.eventCodesInfo(i).condition.description];
                end;
            end;
            
            currentTask = obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber).taskLabel;
            currentTaskMask = strcmp(currentTask, studyEventCodeTaskLabel);
            
            for i=1:length(EEG.event)
                type = EEG.event(i).type;
                if isnumeric(type)
                    type = num2str(type);
                end;
                eventType{i} = type;
                eventLatency(i) = EEG.event(i).latency / EEG.srate;
                
                id = currentTaskMask & strcmp(eventType{i}, studyEventCode);
                if any(id)
                    eventHedString = studyEventCodeHedString{id};
                else
                    eventHedString = '';
                end;
                
                EEG.event(i).usertags = eventHedString; % usertags should be a string (not a cell array of tags)
                EEG.urevent(i).usertags = EEG.event(i).usertags;
                
                % make sure event types are strings.
                if isnumeric(EEG.event(i).type)
                    EEG.event(i).type = num2str(EEG.event(i).type);
                end;
                if isnumeric(EEG.urevent(i).type)
                    EEG.urevent(i).type = num2str(EEG.urevent(i).type);
                end;
                
            end;
        end;
        
        function [filename, dataRecordingUuid, taskLabel, sessionNumber, subject] = getFilename(obj, varargin)
        %		[filename, dataRecordingUuid, taskLabel, sessionNumber, subject] = getFilename(obj, varargin)
		% [filename, dataRecordingUuid, taskLabel, sessionNumber, subject] = getFilename(obj, varargin)
		% Obtains [full] filenames and other information for all or a subset of Level 2 data.
		% You may use the returned values to for example run a function on each of EEG recordings. 
		%
		% Options:
		%	Key			Value
		% 	'taskLabel'		: Label(s) for session tasks. A cell array containing task labels.
		%	'includeFolder'		: Add folder to returned filename.
		%	'filetype'		: Either 'EEG' or  'event' to specify which file types should be returned.
		% 	'dataQuality'		: Cell array of Strings. Acceptable data quality values (i.e. whether to include Suspect datta or not.
        	%    
            inputOptions = arg_define(varargin, ...
                arg('taskLabel', {},[],'Label(s) for session tasks. A cell array containing task labels.', 'type', 'cellstr'), ...
                arg('includeFolder', true, [],'Add folder to returned filename.', 'type', 'logical'),...
                arg('filetype', 'eeg',{'eeg' 'EEG', 'event', 'Event'},'Either ''EEG'' or  ''event''. Specifies which file types should be returned.', 'type', 'char'),...
                arg('dataQuality', {},[],'Acceptable data quality values. I.e. whether to include Suspect datta or not.', 'type', 'cellstr') ...
                );
            
            % get the UUids from level 1
            [dummy, selectedDataRecordingUuid, dummy2, sessionTaskNumber, dataRecordingNumber] = obj.level1StudyObj.getFilename('taskLabel',inputOptions.taskLabel, 'filetype',inputOptions.filetype, 'includeFolder', false);
            
            % go over level 2 and match by dataRecordingUuid
            dataRecordingUuid = {};
            taskLabel = {};
            filename = {};
            sessionNumber = {};
            subject = [];
            for i=1:length(obj.studyLevel2Files)
                [match, id] = ismember(obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, selectedDataRecordingUuid);
                if match
                    dataRecordingUuid{end+1} = obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid;
                    taskLabel{end+1} = obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).taskLabel;
                    
                    sessionNumber{end+1} = obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).sessionNumber;
                    
                    inSessionNumber = obj.level1StudyObj.getInSessionNumberForDataRecording(obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).dataRecording(dataRecordingNumber(id)));
                    foundSubjectId = [];
                    for j =1:length(obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject)
                        if strcmp(inSessionNumber, obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject(j).inSessionNumber)
                            foundSubjectId = [foundSubjectId j];
                        end;
                    end;
                    if isempty(foundSubjectId)
                        error('Something iss wrong, subejct with inSession number cannot be found.');
                    elseif length(foundSubjectId) > 1
                        error('Something is wrong, more than one sbject with inSession number found.');
                    else % a single number
                        newSubject = obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject(foundSubjectId);
                        if isempty(subject)
                            subject  = newSubject;
                        else
                            subject(end+1)  = newSubject;
                        end;
                    end;
                    
                    if strcmpi(inputOptions.filetype, 'eeg')
                        basefilename = obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName;
                    else
                        basefilename = obj.studyLevel2Files.studyLevel2File(i).eventInstanceFile;
                    end;
                    
                    if inputOptions.includeFolder
                        baseFolder = fileparts(obj.level2XmlFilePath);
                        % remove extra folder separator
                        if baseFolder(end) ==  filesep
                            baseFolder = baseFolder(1:end-1);
                        end;
                        filename{end+1} = [baseFolder filesep 'session' filesep obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(id)).sessionNumber filesep basefilename];
                    else
                        filename{end+1} = basefilename;
                    end;
                end;
            end;
        end;
        
        function [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, inputDataRecordingUuid, varargin)
            % [filename outputDataRecordingUuid taskLabel moreInfo] = infoFromDataRecordingUuid(obj, inputDataRecordingUuid, {key, value pair options})
            % Returns information about valid data recording UUIDs. For
            % example Level 2 EEG or event files.
            % key, value pairs:
            %
            % includeFolder:   true ot false. Whether to return full file
            % path.
            %
            % filetype:       one of {'eeg' , 'event', 'noiseDetection' , 'report'}
            
            
            inputOptions = arg_define(varargin, ...
                arg('includeFolder', true, [],'Add folder to returned filename.', 'type', 'logical'),...
                arg('filetype', 'eeg',{'eeg' , 'event', 'noiseDetection' , 'report'},'Return EEG or event files.', 'type', 'char')...
                );
            
            [dummy1, level1dataRecordingUuid, level1TaskLabel, sessionTaskNumber, level1MoreInfo] = obj.level1StudyObj.infoFromDataRecordingUuid(inputDataRecordingUuid, 'includeFolder', false);
            
            taskLabel = {};
            filename = {};
            moreInfo = struct;
            moreInfo.sessionNumber = {};
            moreInfo.dataRecordingNumber = [];
            moreInfo.sessionTaskNumber = [];
            outputDataRecordingUuid = {};
            for j=1:length(level1dataRecordingUuid)
                for i=1:length(obj.studyLevel2Files.studyLevel2File)
                    if strcmp(level1dataRecordingUuid{j}, obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid)
                        
                        taskLabel{end+1} = level1TaskLabel{j};
                        outputDataRecordingUuid{end+1} = level1dataRecordingUuid{j};
                        moreInfo.sessionNumber{end+1} = level1MoreInfo.sessionNumber{j};
                        moreInfo.dataRecordingNumber(end+1) = level1MoreInfo.dataRecordingNumber(j);
                        moreInfo.sessionTaskNumber(end+1) = sessionTaskNumber(j);
                        switch lower(inputOptions.filetype)
                            case 'eeg'
                                basefilename = obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName;
                            case 'event'
                                basefilename = obj.studyLevel2Files.studyLevel2File(i).eventInstanceFile;
                            case 'noisedetection'
                                basefilename = obj.studyLevel2Files.studyLevel2File(i).noiseDetectionResultsFile;
                            case 'report'
                                basefilename = obj.studyLevel2Files.studyLevel2File(i).reportFileName;
                        end;
                        
                        if inputOptions.includeFolder
                            baseFolder = fileparts(obj.level2XmlFilePath);
                            filename{end+1} = [baseFolder filesep 'session' filesep obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber(j)).sessionNumber filesep basefilename];
                        else
                            filename{end+1} = basefilename;
                        end;
                        break;
                    end;
                end
            end;
        end;
        
        function [obj, issue] = validate(obj, fixIssues)
        % [obj, issue] = validate(obj, fixIssues)
        % Check the existence and  consistentcy data i Level 2 object. It by default fixes some of the issues in
        % the returned obj value, i.e. obj = obj.validate();
        % you can turn off this fixing by setting fixIssues to false.
        % issues are returned in s structure array.
            
            if nargin < 2
                fixIssues = true;
            end;
            
            issue = []; % a structure with description and howItWasFixed fields.
            baseFolder = fileparts(obj.level2XmlFilePath);
            
            % make sure uuid and title are set
            if isempty(obj.uuid)
                obj.uuid = char(java.util.UUID.randomUUID);
                issue(end+1).description = sprintf('UUID is empty.\n');
                issue(end).howItWasFixed = 'A new UUID is set.';
            end;
            
            if isempty(obj.title)
                obj.title = obj.level1StudyObj.studyTitle;
                issue(end+1).description = sprintf('Title is empty.\n');
                issue(end).howItWasFixed = 'Title set to level 1 title';
            end;
            
            for i=1:length(obj.studyLevel2Files.studyLevel2File)
                
                [dataRecordingFilename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, 'type', 'eeg');
                if isempty(strtrim(obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName))
                    issue(end+1).description = sprintf('Data recording file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                else
                    if ~exist(dataRecordingFilename{1}, 'file')
                        issue(end+1).description = sprintf('Data recording file %s of session %s is missing.\n', dataRecordingFilename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, 'type', 'event');
                if isempty(strtrim(obj.studyLevel2Files.studyLevel2File(i).eventInstanceFile))
                    issue(end+1).description = sprintf('Event instance file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                else
                    if ~exist(filename{1}, 'file')
                        issue(end+1).description = sprintf('Event instance file %s of session %s is missing.\n', filename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, 'type', 'report');
                recreateReportFile = false;
                if isempty(strtrim(obj.studyLevel2Files.studyLevel2File(i).reportFileName))
                    issue(end+1).description = sprintf('Report file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                    recreateReportFile = fixIssues;
                else
                    if ~exist(filename{1}, 'file')
                        issue(end+1).description = sprintf('Report file %s of session %s is missing.\n', filename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                        recreateReportFile = fixIssues;
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevel2Files.studyLevel2File(i).dataRecordingUuid, 'type', 'noiseDetection');
                recreateNoiseFile = false;
                if ~level1Study.isAvailable(obj.studyLevel2Files.studyLevel2File(i).noiseDetectionResultsFile)
                    issue(end+1).description = sprintf('Noise detection parameter file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                    if fixIssues
                        [sessionFolder, name, ext] = fileparts(dataRecordingFilename{1});
                        EEG = pop_loadset([name ext], sessionFolder);
                        hdf5Filename = writeNoiseDetectionFile(obj, EEG, moreInfo.sessionTaskNumber , moreInfo.dataRecordingNumber, sessionFolder);
                        obj.studyLevel2Files.studyLevel2File(i).noiseDetectionResultsFile = hdf5Filename;
                        issue(end).howItWasFixed = 'A new noisy detection file was created.';
                    end;
                else
                    if ~exist(filename{1}, 'file')
                        issue(end+1).description = sprintf('Noise detection parameter file %s of session %s is missing.\n', filename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                        if fixIssues
                            if ~exist(EEG, 'var')
                                [sessionFolder, name, ext] = fileparts(dataRecordingFilename{1});
                                EEG = pop_loadset([name ext], sessionFolder);
                            end;
                            level2Folder = fileparts(obj.level2XmlFilePath);
                            reportFileName = writeReportFile(obj, EEG, [name ext], moreInfo.sessionTaskNumber, level2Folder);
                            obj.studyLevel2Files.studyLevel2File(i).reportFileName = reportFileName;
                            issue(end).howItWasFixed = 'A new report file was created.';
                        end;
                    end;
                end;
                
                clear EEG;
                
            end;
            
            % display issues
            if isempty(issue)
                fprintf('There are no issues. Great!\n');
            else
                % make sure the fields exist
                if ~isfield(issue, 'howItWasFixed')
                    issue(1).howItWasFixed = [];
                end;
                
                if ~isfield(issue, 'issueType')
                    issue(1).issueType = [];
                end;
                
                fprintf('Fixed issues:\n');
                numberOfFixedIssues = 0;
                for i=1:length(issue)
                    if ~isempty(issue(i).howItWasFixed)
                        numberOfFixedIssues = numberOfFixedIssues + 1;
                        fprintf('%d - %s\n', numberOfFixedIssues, issue(i).description);
                        fprintf('    Fixed: %s\n', issue(i).howItWasFixed);
                    end;
                end;
                
                if numberOfFixedIssues == 0
                    fprintf(' None.\n');
                end;
                
                % display fixed and outstanding issues
                fprintf('Outstanding issues:\n');
                
                fprintf('- Missing Files\n');
                numberOfMissingFileIssues = 0;
                for i=1:length(issue)
                    if isempty(issue(i).howItWasFixed) && strcmpi(issue(i).issueType, 'missing file');
                        numberOfMissingFileIssues = numberOfMissingFileIssues + 1;
                        fprintf('  %d - %s\n', numberOfMissingFileIssues, issue(i).description);
                    end;
                end;
                
                if numberOfMissingFileIssues == 0
                    fprintf('   None.\n');
                end;
                
                fprintf('- ESS XML\n');
                numberOfXMLIssues = 0;
                for i=1:length(issue)
                    if isempty(issue(i).howItWasFixed) && ~strcmpi(issue(i).issueType, 'missing file');
                        numberOfXMLIssues = numberOfXMLIssues + 1;
                        fprintf('  %d - %s\n', numberOfXMLIssues, issue(i).description);
                    end;
                end;
            end;
            
        end;
        
        function hdf5Filename = writeNoiseDetectionFile(obj, EEG, sessionTaskNumber, dataRecordingNumber, sessionFolder)
            subjectInSessionNumber = obj.level1StudyObj.getInSessionNumberForDataRecording(obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber));
            hdf5Filename = obj.level1StudyObj.essConventionFileName('noise_detection', ['studyLevel2_' obj.level1StudyObj.studyTitle], obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber).sessionNumber,...
                subjectInSessionNumber, obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber).taskLabel, dataRecordingNumber, '', '.hdf5');
            noiseDetection = EEG.etc.noiseDetection;
            noiseDetection.dataRecordingUuid = EEG.etc.dataRecordingUuid;
            writeHdf5Structure([sessionFolder filesep hdf5Filename], 'root', noiseDetection);
        end;
        
        function reportFileName = writeReportFile(obj, EEG, filenameInEss, sessionTaskNumber, level2Folder)
            reportFileName = ['report_' filenameInEss(1:end-4) '.pdf'];
            relativeSessionFolder = ['.' filesep 'session' ...
                filesep obj.level1StudyObj.sessionTaskInfo(sessionTaskNumber).sessionNumber];
            publishPrepPipelineReport(EEG, ...
                level2Folder, 'summaryReport.html', ...
                relativeSessionFolder, reportFileName);
        end;
        
        function studyFilenameAndPath = createEeglabStudy(obj, studyFolder, varargin)
        % studyFilenameAndPath = createEeglabStudy(obj, studyFolder, {key, value pairs})
	% Create an EEGLAB Study in a separate folder with its own EEGLAb dataset files.
	%
	%	Key			Value
	%	'taskLabel'		: A cell array containing task labels to indicate the subset of files to be used.
	%	'studyFileName'		: Create two files per EEG dataset. Saves the structure without the data in a Matlab 
	%				  ''.set'' file and the transposed data in a binary float ''.dat'' file.
	%	'makeTwoFilesPerSet'	: Create two files per EEG dataset. Saves the structure without the data in a Matlab 
	%				  ''.set'' file and the transposed data in a binary float ''.dat'' file.
	%	'dataQuality'		: {'Good' 'Suspect' 'Unusable'}	, Acceptable data quality values. A cell array containing a combination of acceptable data quality values (Good, Suspect or Unusbale).
	
            inputOptions = arg_define(varargin, ...
                arg('taskLabel', {},[],'Label(s) for session tasks. A cell array containing task labels.', 'type', 'cellstr'), ...
                arg('studyFileName', '', [],'Create two files per EEG dataset. Saves the structure without the data in a Matlab ''.set'' file and the transposed data in a binary float ''.dat'' file.', 'type', 'char'),...
                arg('makeTwoFilesPerSet', true, [],'Create two files per EEG dataset. Saves the structure without the data in a Matlab ''.set'' file and the transposed data in a binary float ''.dat'' file.', 'type', 'logical'),...
                arg('dataQuality', {'Good'},{'Good' 'Suspect' 'Unusable'},'Acceptable data quality values. A cell array containing a combination of acceptable data quality values (Good, Suspect or Unusbale)', 'type', 'cellstr') ...
                );
            
            if ~exist(studyFolder, 'dir')
                mkdir(studyFolder);
            end;
            
            if isempty(inputOptions.studyFileName)
                if isempty(obj.title)
                    inputOptions.studyFileName = 'study_from_ess.study';
                else
                    nameForStudy = level1Study.removeForbiddenWindowsFilenameCharacters(obj.title(1:min(end,22)));
                    nameForStudy = strtrim(nameForStudy);
                    nameForStudy(nameForStudy == ' ') = '_';
                    inputOptions.studyFileName = ['study_from_ess_' nameForStudy '.study'];
                end;
            end;
            
            [filename, dataRecordingUuid, taskLabel, sessionNumber, subject] = getFilename(obj, 'includeFolder', true, 'taskLabel', inputOptions.taskLabel, 'dataQuality', inputOptions.dataQuality);
            
            fileSessionFolder = {};
            clear ALLEEG;
            counter = 1;
            for i=1:length(filename)
                fileSessionFolder{i} = [studyFolder filesep sessionNumber{i}];
                if ~exist(fileSessionFolder{i}, 'dir')
                    mkdir(fileSessionFolder{i});
                end;
                
                [loadPath name ext] = fileparts(filename{i});
                if inputOptions.makeTwoFilesPerSet
                    EEG = pop_loadset([name ext], loadPath);
                    pop_saveset(EEG, 'filename', [name ext], 'filepath', fileSessionFolder{i}, 'savemode', 'twofiles', 'version', '7.3');
                    clear EEG;
                else
                    copyfile(filename{i}, [fileSessionFolder{i} filesep name ext]);
                end;
                
                EEG = pop_loadset('filename', [name ext], 'filepath', fileSessionFolder{i}, 'loadmode', 'info');
                
                if isempty(subject(i).labId)
                    EEG.subject = ['subject_of_session_' sessionNumber{i}];
                else
                    EEG.subject = subject(i).labId;
                end;
                if ~isempty(subject(i).group)
                    EEG.group = subject(i).group;
                end;
                
                if counter == 1
                    ALLEEG = EEG;
                else
                    ALLEEG(end+1) = EEG;
                end;
                clear EEG;
                counter = counter + 1;
            end;
            
            % make a study from all the files
            pop_editoptions('option_storedisk', true); % keep only maximum one dataset data in memory
            STUDY = pop_study([], ALLEEG, 'updatedat', 'on', 'name', obj.title, 'notes', obj.level1StudyObj.studyDescription, 'task', obj.level1StudyObj.studyShortDescription);
            STUDY.filename = inputOptions.studyFileName;
            STUDY.filepath = studyFolder;
            STUDY = pop_savestudy( STUDY, ALLEEG, 'filename', inputOptions.studyFileName, 'filepath', studyFolder);
            studyFilenameAndPath = [studyFolder filesep inputOptions.studyFileName];
        end;
    end;
end
