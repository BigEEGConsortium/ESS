classdef levelDerivedStudy
    % creates a Level-derived object, from a Level 1 or 2 container
        
    % Be careful! any properties placed below will be written in the XML
    % file.
    properties
        % version of STDL2 used. Mandatory.
        studyLevelDerivedSchemaVersion = ' ';
        
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
        studyLevelDerivedFiles = struct('studyLevelDerivedFile', struct('studyLevelDerivedFileName', ' ', ...
            'dataRecordingUuid', ' ', 'reportFileName', ' ',...
            'eventInstanceFile', ' ', 'dataQuality', ' '));
        
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
        % Filename (including path) of the ESS Level-derived XML file associated with the
        % object.
        levelDerivedXmlFilePath
        
        % Filename (including path) of the parent study XML file
        % based on which level-derived data may be computed. Could be kept empty
        % if not available.
        parentStudyXmlFilePath
        
        % Parent study object, created based on parentStudyXmlFilePath input parameter
        parentStudyObj       
        
        % ESS-convention level-derived folder where all level-derived data are
        % organized during parent study -> level-derived conversion using
        % the given filter transformation(s).
        levelDerivedFolder
    end;
    
    methods
        function obj = levelDerivedStudy(varargin)
        
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            
            inputOptions = arg_define(0,varargin, ...
                arg('levelDerivedXmlFilePath', '','','ESS Level-derived XML Filename.', 'type', 'char'), ...
                arg('parentStudyXmlFilePath', '','','Parent study (in ESS) XML Filename.', 'type', 'char'), ...
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr') ...
                );
            
            % if the folder 'container' is instead of filename provided, use the default
            % 'study_description.xml' file.
            if exist(inputOptions.parentStudyXmlFilePath, 'dir')...
                    && exist([inputOptions.parentStudyXmlFilePath filesep 'study_description.xml'], 'file')
                inputOptions.parentStudyXmlFilePath = [inputOptions.parentStudyXmlFilePath filesep 'study_description.xml'];
            end;
            
            if exist(inputOptions.levelDerivedXmlFilePath, 'dir')...
                    && exist([inputOptions.levelDerivedXmlFilePath filesep 'studyLevelDerived_description.xml'], 'file')
                inputOptions.levelDerivedXmlFilePath = [inputOptions.levelDerivedXmlFilePath filesep 'studyLevelDerived_description.xml'];
            end;
            
            obj.levelDerivedXmlFilePath = inputOptions.levelDerivedXmlFilePath;
            
            if ~isempty(obj.levelDerivedXmlFilePath)
                obj = obj.read;
            end;
            
            if ~isempty(inputOptions.parentStudyXmlFilePath)                
                % read the parent XML file and find out what level it is
                parentStudyObj = levelDerivedStudy.readLevelXML(inputOptions.parentStudyXmlFilePath);               
                
                obj.parentStudyObj = parentStudyObj;
                obj.parentStudyXmlFilePath = inputOptions.parentStudyXmlFilePath;
            end;
            
        end;
        
        function obj = write(obj, levelDerivedXmlFilePath)
            
            % assign the input file path as the object path and write
            % there.
            if nargin > 1
                obj.levelDerivedXmlFilePath = levelDerivedXmlFilePath;
            end;
            
            % use xml_io tools to write XML from a Matlab structure
            propertiesToExcludeFromXMLIO = findAttrValue(obj, 'AbortSet', true);
            
            % remove fields that are flagged for not being saved to the XML
            % file.
            warning('off', 'MATLAB:structOnObject');
            xmlAsStructure = rmfield(struct(obj), propertiesToExcludeFromXMLIO);
            warning('on', 'MATLAB:structOnObject');
            
            % include parent xml in parentStudy field. Write in a temporary
            % file
            temporaryParentXML = [tempname '.xml'];
            obj.parentStudyObj.write(temporaryParentXML);
            
            clear Pref;
            % make sure the root is also included, tihs is a bit different
            % from Level 2 xml embedding since we need to include the root XML
            % node under <parentStudy> too.
            Pref.RootOnly = false;
            xmlAsStructure.parentStudy = xml_read(temporaryParentXML, Pref);
            
            if isfield(xmlAsStructure.parentStudy, 'PROCESSING_INSTRUCTION')
                xmlAsStructure.parentStudy = rmfield(xmlAsStructure.parentStudy, 'PROCESSING_INSTRUCTION');
            end;
            
            if isfield(xmlAsStructure.parentStudy, 'COMMENT')
                xmlAsStructure.parentStudy = rmfield(xmlAsStructure.parentStudy, 'COMMENT');
            end;
            
            delete(temporaryParentXML);
            if ~isempty(obj.parentStudyXmlFilePath)
                pathstr = fileparts(obj.parentStudyXmlFilePath);
                
                % there should be only one field name, which is
                % studyLevel1,studyLevel2, etc. 
                fieldName = fieldnames(xmlAsStructure.parentStudy);
                
                xmlAsStructure.parentStudy.(fieldName{1}).rootURI = pathstr; % save absolute path in root dir. This is so it can later read the recording files relative to this path.
            end;
            
            % prevent xml_ioi from adding extra 'Item' fields and write the XML
            clear Pref
            Pref.StructItem = false;
            Pref.CellItem = false;
            xml_write(obj.levelDerivedXmlFilePath, xmlAsStructure, {'studyLevelDerived' 'xml-stylesheet type="text/xsl" href="xml_level_derived_style.xsl"' 'This file is created based on EEG Study Schema (ESS) Level-derived. Visit eegstudy.org for more information.'}, Pref);
        end;
        
        function obj = read(obj)
            Pref.Str2Num = false;
            Pref.PreserveSpace = true; % keep spaces
            xmlAsStructure = xml_read(obj.levelDerivedXmlFilePath, Pref);
            names = fieldnames(xmlAsStructure);
            
            for i=1:length(names)
                if strcmp(names{i}, 'parentStudy')
                    % load the level 1 data into its own object instead of
                    % a regular structure field under level 2
                    
                    % prevent xml_ioi from adding extra 'Item' fields and write the XML
                    clear Pref;
                    Pref.StructItem = false;
                    Pref.CellItem = false;
                    Pref.RootOnly = false;                    
                    temporaryparentStudyXmlFilePath = [tempname '.xml'];
                    xml_write(temporaryparentStudyXmlFilePath, xmlAsStructure.parentStudy, '', Pref);                                        
                    
                    obj.parentStudyObj = levelDerivedStudy.readLevelXML(temporaryparentStudyXmlFilePath);
                    
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
        
        function obj = createLevelDerivedStudy(obj, callbackAndParameters, varargin)
            % obj = createLevelDerivedStudy(obj, callbackAndParameters, filterLabel, a list of ('key', value) pairs)
            % creates an ESS standardized data level-derived folder using
            % the given function (Filter).
            % You can continue where the processing was stopped by running the
            % exact same command since it skips processing of already
            % calculated sessions (unless you change this behavior).
            %
            % callbackAndParameters is a cell array containing these in the exact
            % order:
            % (1) callback      a function handle that  accepts an EEG structure
            %                   as the first argument.
            % (2) either a cell array of ('key', value) pairs to be passed verbatim to 
            % the callback function, or a regular comma-separated list of ('key', value)
            % pairs, were only values will be sent to the callback function 
            % (and the 'keys' to be used to name the values in the ESS filter definition.
            %
            % Example:
            %
            %	obj = levelDerivedStudy('parentStudyXmlFilePath', 'C:\Users\You\Awesome_EEG_stud\level_2\'); % this load the data but does not make a Level-derived 2 container yet (Obj it is still mostly empty).
            %   callbackAndParameters = {@clean_asr, 'cutoff', 5};
            %	
            %   % this command starts applying the ASR function to all the recordings and makes a fully-realized Level-derived object.
            %   obj = obj.createLevelDerivedStudy('asr',callbackAndParameters, ...
            %        'levelDerivedFolder', 'C:\Users\You\Awesome_EEG_study\level_derived_asr\');                
            %
            % Options:
            %
            %	Key				Value
            %
            % 	'levelDerivedFolder'	: String,  Level 2 study folder. This folder will contain with processed data files, XML..
            % 	'params'			    : Cell array, Input parameters to for the processing pipeline.
            %	'sessionSubset' 		: Integer Array, Subset of sessions numbers (empty = all).
            % 	'forTest'			: Logical, For Debugging ONLY. Process a small data sample for test.
            %

    
    
    inputOptions = arg_define(varargin, ...
        arg('filterLabel', '','','Label of the filter function. Like ASR or ICA.', 'type', 'char'), ...
        arg('levelDerivedFolder', '','','Level 2 study folder. This folder will contain with processed data files, XML..', 'type', 'char'), ...
        arg('sessionSubset', [],[],'Subset of sessions numbers (empty = all).', 'type', 'denserealsingle'), ...
        arg('forceRedo', false,[],'re-execute callback on recordings.', 'type', 'logical'), ...
        arg('forTest', false,[],'Process a small data sample for test.', 'type', 'logical') ...
        );
            
            if ~ischar(inputOptions.filterLabel)
                error('Filter label must be a string');
            elseif length(inputOptions.filterLabel) > 10
                error('Filter label is too long. It ust be 10 characters or less');
            end;
        
            if ~iscell(callbackAndParameters)
                error('callbackAndParameters has to be a cell array');
            end;
            if length(callbackAndParameters) < 2
                error('The second index of callbackAndParameters is missing.');
            end;
            callbackFunction = callbackAndParameters{1};
            if iscell(callbackAndParameters{2}) % the second index should contain ('key', value) pair.
                if length(callbackAndParameters) > 2
                    error('Invalid callbackFunction format. In this format only two cell elements should be in callbackFunction');
                end
                callbackArgumentList = callbackAndParameters{2}; % verbatim key, value pairs
                parameterName = callbackArgumentList(1:2:end);
                parameterValue = callbackArgumentList(2:2:end);
            else
                callbackArgumentList = callbackAndParameters(3:2:end); % pick only values
                parameterName = callbackAndParameters(2:2:end);
                parameterValue = callbackArgumentList;
            end;
                     
            obj.levelDerivedFolder = inputOptions.levelDerivedFolder;
            
            % start from index 1 if the first studyLevel2File is pactically empty,
            % otherwise start after the last studyLevel2File
            if length(obj.studyLevelDerivedFiles.studyLevelDerivedFile) == 1 && isempty(strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(1).studyLevelDerivedFileName))
                studyLevelDerivedFileCounter = 1;
            else
                studyLevelDerivedFileCounter = 1 + length(obj.studyLevelDerivedFiles.studyLevelDerivedFile);
            end;
            
            alreadyProcessedDataRecordingUuid = {};
            alreadyProcessedDataRecordingFileName = {};
            for i=1:length(obj.studyLevelDerivedFiles.studyLevelDerivedFile)
                recordingUuid = strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid);
                if ~isempty(recordingUuid)
                    alreadyProcessedDataRecordingUuid{end+1} = recordingUuid;
                    alreadyProcessedDataRecordingFileName{end+1} = strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).studyLevel2FileName);
                end;
            end;
            
            % make top folders
            mkdir(inputOptions.levelDerivedFolder);
            mkdir([inputOptions.levelDerivedFolder filesep 'session']);
            mkdir([inputOptions.levelDerivedFolder filesep 'additional_data']);
            
            obj.uuid = char(java.util.UUID.randomUUID);
            obj.studyLevelDerivedSchemaVersion  = '1.0';
                        
            if ismember(class(obj.parentStudyObj), {'level2Study', 'levelDerivedStudy'})
                
               obj.title = obj.parentStudyObj.title;
                
               [filenames, dataRecordingUuid, taskLabel, sessionNumber, subjectInfo] = obj.parentStudyObj.getFilename('filetype', 'eeg');
               [eventFilenames, eventDataRecordingUuidfrom] = obj.parentStudyObj.getFilename('filetype', 'event');
               
               if ~isequal(dataRecordingUuid, eventDataRecordingUuidfrom)
                   error('someting is wrong');
               end
               
               % sub-select files for requested sessions
               if ~isempty(inputOptions.sessionSubset)
                   id = ismember(str2double(sessionNumber),inputOptions.sessionSubset);
                   filenames = filenames(id);
                   dataRecordingUuid = dataRecordingUuid(id);
                   eventFilenames = eventFilenames(id);
                   eventDataRecordingUuidfrom = eventDataRecordingUuidfrom(id);
                   taskLabel = taskLabel(id);
                   subjectInfo = subjectInfo(id);
               end;
               
               for i=1:length(filenames)
                   [path name ext] = fileparts(filenames{i});
                   clear EEG;
                   EEG = pop_loadset([name ext], path);
                   
                   % for test only
                   if inputOptions.forTest
                       fprintf('Cutting data, WARNING: ONLY FOR TESTING, REMOVE THIS FOR PRODUCTION!\n');
                       EEG = pop_select(EEG, 'point', 1:round(size(EEG.data,2)/100));
                   end;
                   
                   EEG = callbackFunction(EEG, callbackArgumentList{:});
                                     
                   % create a UUID for the study level derived file and add
                   % it to the end of dataRecordingUuidHistory.
                   studyLevelDerivedFileUuid = char(java.util.UUID.randomUUID);
                   EEG.etc.dataRecordingUuidHistory = {EEG.etc.dataRecordingUuidHistory studyLevelDerivedFileUuid};
                   
                   % write processed EEG data
                   sessionFolder = [inputOptions.levelDerivedFolder filesep 'session' filesep sessionNumber{i}];
                   if ~exist(sessionFolder, 'dir')
                       mkdir(sessionFolder);
                   end;
                   
                   [path, name, ext] = fileparts(filenames{i}); %#ok<ASGLU>
                   
                   switch class(obj.parentStudyObj)                       
                       case 'level2Study'
                           nameWithoutLevelpart = name(length('eeg_studyLevel2_'):end);
                       case 'levelDerivedStudy'
                           nameWithoutLevelpart = name(length('eeg_studyLevelDerived_'):end);
                   end;
                   
                   filenameInEss = ['eeg_studyLevelDerived_' inputOptions.filterLabel '_' nameWithoutLevelpart '.set'];                                      
                   pop_saveset(EEG, 'filename', filenameInEss, 'filepath', sessionFolder, 'savemode', 'onefile', 'version', '7.3');

                   % copy the event instance file from parent study
                   [pathstr, name, ext] = fileparts(eventFilenames{i});
                   copyfile(eventFilenames{i}, [sessionFolder filesep name ext]);                   
                   obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).eventInstanceFile = [name ext];
                   
                   % place EEG filename and UUID in XML
                   obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).studyLevelDerivedFileName = filenameInEss;
                   obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid = dataRecordingUuid{i};
                   obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).uuid = studyLevelDerivedFileUuid;
                   
                   % ToDo: Get data quality from the filter.
                   obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataQuality = 'Good';                                                         
                end;
                
                % write the filter
                eeglabVersionString = ['EEGLAB ' eeg_getversion];
                matlabVersionSTring = ['MATLAB '  version];
                
                obj.filters.filter.filterLabel = inputOptions.filterLabel;
                obj.filters.filter.executionOrder = 1;
                obj.filters.filter.softwareEnvironment = matlabVersionSTring;
                obj.filters.filter.softwarePackage = eeglabVersionString;
                obj.filters.filter.functionName = func2str(callbackFunction); % get function name as string from its handle
                
                for p=1:length(parameterName)
                    obj.filters.filter.parameters.parameter(p).name = parameterName{p};
                    obj.filters.filter.parameters.parameter(p).value = evalc('disp(parameterValue{p})');
                end;
                
                obj.levelDerivedXmlFilePath = [inputOptions.levelDerivedFolder filesep 'studyLevelDerived_description.xml'];
                obj.write(obj.levelDerivedXmlFilePath);
            else
                error('Level-derived from Level 1 studies is not implemented yet');
            end;
                
            
            % Calculate total study size
            [dummy, obj.totalSize]= dirsize(fileparts(obj.levelDerivedXmlFilePath)); %#ok<ASGLU>
            obj.write(obj.levelDerivedXmlFilePath);                        
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
        	    
            inputOptions = arg_define(varargin, ...
                arg('taskLabel', {},[],'Label(s) for session tasks. A cell array containing task labels.', 'type', 'cellstr'), ...
                arg('includeFolder', true, [],'Add folder to returned filename.', 'type', 'logical'),...
                arg('filetype', 'eeg',{'eeg' 'EEG', 'event', 'Event'},'Either ''EEG'' or  ''event''. Specifies which file types should be returned.', 'type', 'char'),...
                arg('dataQuality', {},[],'Acceptable data quality values. I.e. whether to include Suspect datta or not.', 'type', 'cellstr') ...
                );
            
            % get the UUids from level 1
            [dummy, selectedDataRecordingUuid, dummy2, sessionTaskNumber, dataRecordingNumber] = obj.parentStudyObj.getFilename('taskLabel',inputOptions.taskLabel, 'filetype',inputOptions.filetype, 'includeFolder', false); %#ok<ASGLU>
            
            % go over level 2 and match by dataRecordingUuid
            dataRecordingUuid = {};
            taskLabel = {};
            filename = {};
            sessionNumber = {};
            subject = [];
            for i=1:length(obj.studyLevelDerivedFiles.studyLevelDerivedFile)
                [match, id] = ismember(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid, selectedDataRecordingUuid);
                if match
                    dataRecordingUuid{end+1} = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid;
                    taskLabel{end+1} = obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).taskLabel;
                    
                    sessionNumber{end+1} = obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).sessionNumber;
                    
                    inSessionNumber = obj.parentStudyObj.getInSessionNumberForDataRecording(obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).dataRecording(dataRecordingNumber(id)));
                    foundSubjectId = [];
                    for j =1:length(obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject)
                        if strcmp(inSessionNumber, obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject(j).inSessionNumber)
                            foundSubjectId = [foundSubjectId j];
                        end;
                    end;
                    if isempty(foundSubjectId)
                        error('Something iss wrong, subejct with inSession number cannot be found.');
                    elseif length(foundSubjectId) > 1
                        error('Something is wrong, more than one sbject with inSession number found.');
                    else % a single number
                        newSubject = obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).subject(foundSubjectId);
                        if isempty(subject)
                            subject  = newSubject;
                        else
                            subject(end+1)  = newSubject;
                        end;
                    end;
                    
                    if strcmpi(inputOptions.filetype, 'eeg')
                        basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).studyLevelDerivedFileName;
                    else
                        basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).eventInstanceFile;
                    end;
                    
                    if inputOptions.includeFolder
                        baseFolder = fileparts(obj.levelDerivedXmlFilePath);
                        % remove extra folder separator
                        if baseFolder(end) ==  filesep
                            baseFolder = baseFolder(1:end-1);
                        end;
                        filename{end+1} = [baseFolder filesep 'session' filesep obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(id)).sessionNumber filesep basefilename];
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
            
            [dummy1, level1dataRecordingUuid, level1TaskLabel, sessionTaskNumber, level1MoreInfo] = obj.parentStudyObj.infoFromDataRecordingUuid(inputDataRecordingUuid, 'includeFolder', false); %#ok<ASGLU>
            
            taskLabel = {};
            filename = {};
            moreInfo = struct;
            moreInfo.sessionNumber = {};
            moreInfo.dataRecordingNumber = [];
            moreInfo.sessionTaskNumber = [];
            outputDataRecordingUuid = {};
            for j=1:length(level1dataRecordingUuid)
                for i=1:length(obj.studyLevelDerivedFiles.studyLevelDerivedFile)
                    if strcmp(level1dataRecordingUuid{j}, obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid)
                        
                        taskLabel{end+1} = level1TaskLabel{j};
                        outputDataRecordingUuid{end+1} = level1dataRecordingUuid{j};
                        moreInfo.sessionNumber{end+1} = level1MoreInfo.sessionNumber{j};
                        moreInfo.dataRecordingNumber(end+1) = level1MoreInfo.dataRecordingNumber(j);
                        moreInfo.sessionTaskNumber(end+1) = sessionTaskNumber(j);
                        switch lower(inputOptions.filetype)
                            case 'eeg'
                                basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).studyLevelDerivedFileName;
                            case 'event'
                                basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).eventInstanceFile;
                            case 'noisedetection'
                                basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).noiseDetectionResultsFile;
                            case 'report'
                                basefilename = obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).reportFileName;
                        end;
                        
                        if inputOptions.includeFolder
                            baseFolder = fileparts(obj.levelDerivedXmlFilePath);

                            filename{end+1} = [baseFolder filesep 'session' filesep obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber(j)).sessionNumber filesep basefilename];
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
            
            % make sure uuid and title are set
            if isempty(obj.uuid)
                obj.uuid = char(java.util.UUID.randomUUID);
                issue(end+1).description = sprintf('UUID is empty.\n');
                issue(end).howItWasFixed = 'A new UUID is set.';
            end;
            
            if isempty(obj.title)
                obj.title = obj.parentStudyObj.studyTitle;
                issue(end+1).description = sprintf('Title is empty.\n');
                issue(end).howItWasFixed = 'Title set to level 1 title';
            end;
            
            for i=1:length(obj.studyLevelDerivedFiles.studyLevelDerivedFile)
                
                [dataRecordingFilename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid, 'type', 'eeg'); %#ok<ASGLU>
                if isempty(strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).studyLevelDerivedFileName))
                    issue(end+1).description = sprintf('Data recording file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                else
                    if ~exist(dataRecordingFilename{1}, 'file')
                        issue(end+1).description = sprintf('Data recording file %s of session %s is missing.\n', dataRecordingFilename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid, 'type', 'event'); %#ok<ASGLU>
                if isempty(strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).eventInstanceFile))
                    issue(end+1).description = sprintf('Event instance file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                else
                    if ~exist(filename{1}, 'file')
                        issue(end+1).description = sprintf('Event instance file %s of session %s is missing.\n', filename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid, 'type', 'report'); %#ok<ASGLU>
                recreateReportFile = false; %#ok<NASGU>
                if isempty(strtrim(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).reportFileName))
                    issue(end+1).description = sprintf('Report file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                    recreateReportFile = fixIssues; %#ok<NASGU>
                else
                    if ~exist(filename{1}, 'file')
                        issue(end+1).description = sprintf('Report file %s of session %s is missing.\n', filename{1}, moreInfo.sessionNumber{1});
                        issue(end).issueType = 'missing file';
                        recreateReportFile = fixIssues; %#ok<NASGU>
                    end;
                end;
                
                [filename, outputDataRecordingUuid, taskLabel, moreInfo] = infoFromDataRecordingUuid(obj, obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).dataRecordingUuid, 'type', 'noiseDetection'); %#ok<ASGLU>
                recreateNoiseFile = false; %#ok<NASGU>
                if ~level1Study.isAvailable(obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).noiseDetectionResultsFile)
                    issue(end+1).description = sprintf('Noise detection parameter file for Level 2 record associated with session %s (recording number %d) is empty.\n', moreInfo.sessionNumber{1}, moreInfo.dataRecordingNumber);
                    if fixIssues
                        [sessionFolder, name, ext] = fileparts(dataRecordingFilename{1});
                        EEG = pop_loadset([name ext], sessionFolder);
                        hdf5Filename = writeNoiseDetectionFile(obj, EEG, moreInfo.sessionTaskNumber , moreInfo.dataRecordingNumber, sessionFolder);
                        obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).noiseDetectionResultsFile = hdf5Filename;
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

                            levelDerivedFolder = fileparts(obj.levelDerivedXmlFilePath); %#ok<PROP>
                            reportFileName = writeReportFile(obj, EEG, [name ext], moreInfo.sessionTaskNumber, levelDerivedFolder); %#ok<PROP>
                            obj.studyLevelDerivedFiles.studyLevelDerivedFile(i).reportFileName = reportFileName;
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
        

        function reportFileName = writeReportFile(obj, EEG, filenameInEss, sessionTaskNumber, levelDerivedFolder)
            reportFileName = ['report_' filenameInEss(1:end-4) '.pdf'];
            relativeSessionFolder = ['.' filesep 'session' ...
                filesep obj.parentStudyObj.sessionTaskInfo(sessionTaskNumber).sessionNumber];
            publishPrepPipelineReport(EEG, ...
                levelDerivedFolder, 'summaryReport.html', ...
                relativeSessionFolder, reportFileName);
        end;
        
        function [STUDY, studyFilenameAndPath] = createEeglabStudy(obj, studyFolder, varargin)
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
            
            [filename, dataRecordingUuid, taskLabel, sessionNumber, subject] = getFilename(obj, 'includeFolder', true, 'taskLabel', inputOptions.taskLabel, 'dataQuality', inputOptions.dataQuality); %#ok<ASGLU>
            
            fileSessionFolder = {};
            clear ALLEEG;
            counter = 1;
            for i=1:length(filename)
                fileSessionFolder{i} = [studyFolder filesep sessionNumber{i}];
                if ~exist(fileSessionFolder{i}, 'dir')
                    mkdir(fileSessionFolder{i});
                end;
                
                [loadPath name ext] = fileparts(filename{i}); %#ok<NCOMMA>
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
            STUDY = pop_study([], ALLEEG, 'updatedat', 'on', 'name', obj.title, 'notes', obj.parentStudyObj.studyDescription, 'task', obj.parentStudyObj.studyShortDescription);
            STUDY.filename = inputOptions.studyFileName;
            STUDY.filepath = studyFolder;
            STUDY = pop_savestudy( STUDY, ALLEEG, 'filename', inputOptions.studyFileName, 'filepath', studyFolder);
            studyFilenameAndPath = [studyFolder filesep inputOptions.studyFileName];
        end;
    end;
     methods (Static)
         function levelObject = readLevelXML(levelXML)
              xmlAsStructure = xml2struct(levelXML);
                
                if isfield(xmlAsStructure, 'studyLevel1') % level 1
                    levelObject = level1Study(levelXML);
                elseif isfield(xmlAsStructure, 'studyLevel2') % level 2
                    levelObject = level2Study('level2XmlFilePath', levelXML);
                elseif isfield(xmlAsStructure, 'studyLevelDerived') % level-derived
                    levelObject = levelDerivedStudy('levelDerivedXmlFilePath', levelXML); %#ok<*PROP>
                else
                    error('Provided xml file cannot be recognized as either Level 1, 2 or derived.');
                end
         end
     end;
end
