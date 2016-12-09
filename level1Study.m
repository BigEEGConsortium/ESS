classdef level1Study < levelStudy;
    % Allow reading, writing and manipulation of information contained in ESS-formatted Standard Level 1 XML files.
    % EEG Studdy Schema (ESS) Level 1 contains EEG study meta-data information (subject information, sessions file
    % associations...). On read data are loaded in the object properties, you can change this data
    % (e.g. add a ne session) and then save using the write() method into a new ESS XML file.
    %
    % Written by Nima Bigdely-Shamlo and Jessica Hsi.
    % Copyright 2014-2016 Qusp.
    % Copyright 2013-2014 University of California San Diego.
    % Released under BSD License.
    
    properties
        % Version of ESS schema used.
        essVersion = ' ';
        hedVersion = ' ';
        
        % The title of the study.
        studyTitle = ' ';
        
        % a short (less than 120 characters)  description of the study (e.g. explanation of study
        % goals, experimental procedures  utilized, etc.)
        studyShortDescription = ' ';
        
        % Long description of the study (e.g. explanation of study goals,
        % experimental procedures utilized, etc.).
        studyDescription = ' ';
        
        % Unique identifier (uuid) with 32 random  alphanumeric characters and four hyphens). It is used to uniquely identify each ESS document.
        studyUuid = ' ';
        
        % the URI pointing to the root folder of associated ESS folder. If the ESS file is located
        % in the default root folder, this should be . (current directory). If for example the data files
        % and the root folder are placed on a remote FTP location, <rootURI> should be set to
        % ftp://domain.com/study. The concatenation or <rootURI> and <filename> for each file
        % should always produce a valid, downloadable URI.
        rootURI = '.';
        
        % Information about the project under which this experiment is
        % performed.
        projectInfo = struct('organization', ' ',  'grantId', ' ');
        
        %         holds one or more  recordingParameterSet structures, each containing
        %         information about one set of recording data parameters. Most studies have only a
        %         single parameter set, i.e. the same types of data (EEG,Mocap, etc.) are
        %         recorded in the same channel ranges, with the same device types and with the
        %         same sampling rates. In these cases only a single recordingParameterSet is to be
        %         defined. Otherwise multiple recordingParameterSet are defined and
        %         associated with dataRecording nodes.
        recordingParameterSet = struct('recordingParameterSetLabel', ' ', ...
            'modality', struct('type', ' ', 'samplingRate', ' ', 'name', ' ', 'description', ' ',...
            'startChannel', ' ', 'endChannel', ' ', 'subjectInSessionNumber', ' ',...
            'referenceLocation',' ', 'referenceLabel', ' ', 'channelLocationType', ' ', 'channelLabel', ' ', 'nonScalpChannelLabel', ' '));
        
        % Information about (session, task) tuples. Diifferent tasks in
        % a session are each assigned a separate structure in sessionTaskInfo.
        sessionTaskInfo = struct('sessionNumber', [], 'taskLabel', [], 'labId', [],...
            'dataRecording', struct('filename', [], 'dataRecordingUuid', [], 'startDateTime', [], 'recordingParameterSetLabel', [], 'eventInstanceFile', [], 'originalFileNameAndPath', []),...
            'note', [], 'linkName', [], 'link', [], 'subject', struct('labId', [],...
            'inSessionNumber', [], 'group', [], 'gender', [], 'YOB', [], 'age', [], 'hand', [], 'vision', [], ...
            'hearing', [], 'height', [], 'weight', [], 'channelLocations', [], ...
            'medication', struct('caffeine', [], 'alcohol', [])));
        
        % information about different tasks in each session of the study.
        tasksInfo = struct('taskLabel', ' ', 'tag', ' ', 'description', ' ');
        
        eventSpecificationMethod = ' '; % should be either 'codes' or 'tags'.
        
        isInEssContainer = 'No'; % should be either 'Yes' or 'No'.
        
        % Information about event codes (i.e. triggers, event numbers).
        % Notice, we do not have a separate 'event' node inside the
        % eventCodesInfo. This is a slightly different mapping from XML.
        eventCodesInfo = struct('code', ' ', 'taskLabel', ' ', 'numberOfInstances', ' ', 'condition', struct(...
            'label', ' ', 'description', ' ', 'tag', ' '));
        
        % Summary of study information.
        summaryInfo = struct('totalSize', ' ', 'allSubjectsHealthyAndNormal', ' '...
            , 'license', struct('type', ' ', 'text', ' ', 'link',' '));
        
        % List of publications produced from the data collected in this study.
        publicationsInfo = struct('citation', ' ', 'DOI', ' ', 'link', ' ');
        
        % List of experimenters involved in the study.
        experimentersInfo = struct('name', ' ', 'role', ' ');
        
        % Information of individual to contact for data results, or more information regarding the study.
        contactInfo = struct ('name', ' ', 'phone', ' ', 'email', ' ');
        
        % Information regarding the organization that conducted the
        % research study or experiment.
        organizationInfo = struct('name', ' ', 'logoLink', ' ');
        
        % Copyright information.
        copyrightInfo = ' ';
        
        % IRB (Institutional Review Board or equivalent) information, including IRB number study was conducted under.
        irbInfo = ' ';
        
        % Filename (including path) of the ESS XML file associated with the
        % object.
        essFilePath
    end;
    
    methods
        function obj = level1Study(varargin)
            % obj = level1Study(essFilePath)
            % create an instance of the object. If essFilePath is provided (optional) it also read the
            % XML file. If the file does not exist, it will be created on
            % obj.write();
            %
            % Example:
            %
            % obj = level1Study(xmlFile); % read an existing file
            %
            % obj = level1Study(newXmlFile, 'createNewFile', true); % create a new XML file
            %
            % Options:
            %   Key                                     Value
            %
            %   essFilePath                             : String, ESS Standard Level 1 XML Filename or Container folder. Name of the ESS XML file associated with the level1 study. It should include path and if it does not exist a new file with (mostly) empty fields in created.  It is highly recommended to use the name study_description.xml to comply with ESS folder convention.
            %   numberOfSessions                        : Number of study sessions. A session is best described as a single application of EEG cap for subjects, for data to be recorded under a single study. Multiple (and potentially quite different) tasks may be recorded during each session but they should all belong to the same study.
            %   numberOfSubjectsPerSession              : Number of subjects per session. Most studies only have one session per subject but some may have two or more subejcts interacting in a single study session.
            %   numberOfRecordingsPerSessionTask        : Number of EEG recordings per task. Sometimes data for each task in a session is recorded in multiple files.
            %   taskLabels                              : Cell array of strings, Labels for session tasks. A cell array containing task labels. Optional if study only has a single task.
            %   createNewFile                           : Logical, Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an unpromted overwrite if an ESS file already exists in the specified path.
            %   recordingParameterSet                   : Structure array, Common data recording parameter set. If assigned indicates that all data recording have the exact same recording parameter set (same number of channels, sampling frequency, modalities and their orders...).
            %
            
            obj = obj@levelStudy;
            
            inputOptions = arg_define([0 1],varargin, ...
                arg('essFilePath', '','','ESS Standard Level 1 XML Filename. Name of the ESS XML file associated with the level1 study. It should include path and if it does not exist a new file with (mostly) empty fields in created.  It is highly recommended to use the name study_description.xml to comply with ESS folder convention.', 'type', 'char'), ...
                arg('numberOfSessions', uint32(1),[1 Inf],'Number of study sessions. A session is best described as a single application of EEG cap for subjects, for data to be recorded under a single study. Multiple (and potentially quite different) tasks may be recorded during each session but they should all belong to the same study.'), ...
                arg('numberOfSubjectsPerSession', uint32(1),[1 Inf],'Number of subjects per session. Most studies only have one session per subject but some may have two or more subejcts interacting in a single study session.'), ...
                arg('numberOfRecordingsPerSessionTask', uint32(1),[1 Inf],'Number of EEG recordings per task. Sometimes data for each task in a session is recorded in multiple files.'), ...
                arg('taskLabels', {'main'},[],'Labels for session tasks. A cell array containing task labels. Optional if study only has a single task. Each study may contain multiple tasks. For example a baseline ''eyes closed'' task, followed by a ''target detection'' task and a ''mind wandering'', eyes open, task. Each task contains a single paradigm and in combination they allow answering scientific questions investigated in the study. ESS allows for event codes to have different meanings in each task, although such event encoding is discouraged due to potential for experimenter confusion.', 'type', 'cellstr'), ...
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr'), ...
                arg('recordingParameterSet', unassigned,[],'Common data recording parameter set. If assigned indicates that all data recording have the exact same recording parameter set (same number of channels, sampling frequency, modalities and their orders...).') ...
                );
            
            % read the ESS File that is provided.
            if ~isempty(inputOptions.essFilePath)
                obj.essFilePath = inputOptions.essFilePath;
                
                % if the folder 'container' is provided instead of filename, use the default
                % 'study_description.xml' file.
                if exist(obj.essFilePath, 'dir')...
                        && exist([obj.essFilePath filesep 'study_description.xml'], 'file')
                    obj.essFilePath = [obj.essFilePath filesep 'study_description.xml'];
                end;
                
                [path, name, ext] = fileparts(obj.essFilePath);
                if ~inputOptions.createNewFile && exist(obj.essFilePath, 'file') && ~strcmpi(ext, '.xml')
                    error('The input file %s needs to be an XML file with .xml extension', obj.essFilePath);
                end;
                
                if exist(obj.essFilePath, 'file') && ~inputOptions.createNewFile % read the ESS information from the file
                    obj = obj.read(obj.essFilePath);
                    if nargin > 1
                        fprintf('An ESS file already exists at the specified location. Loading the file and ignoring other input parameters.\n');
                    end;
                elseif ~exist(obj.essFilePath, 'file') && ~inputOptions.createNewFile
                    error('There is no ESS containr or manifest file with the given path. If you want to create a manifest file with this name, set ''createNewFile'' option to ''true''.');                                            
                elseif inputOptions.createNewFile
                    % input file did not exist. Create an ESS file at that located
                    % and populate it with empty fields according to input
                    % values.
                    
                    % prepare the object based on input values.
                    % assigns a random UUID.
                    [toolsVersion, level1SchemaVersion, level2SchemaVersion, levelDerivedSchemaVersion] = get_ess_versions;
                    obj.essVersion = level1SchemaVersion;
                    obj.studyUuid = ['studylevel1_' getUuid];
                    
                    % if data recording parameter set if assigned, use it
                    % for all the recordings.
                    typicalDataRecording = obj.sessionTaskInfo(1).dataRecording;
                    recordingParameterSetIsConstant = isfield(inputOptions, 'recordingParameterSet') && ~isempty(inputOptions.recordingParameterSet);
                    if recordingParameterSetIsConstant
                        obj.recordingParameterSet = inputOptions.recordingParameterSet;
                        typicalDataRecording.recordingParameterSetLabel = inputOptions.recordingParameterSet.recordingParameterSetLabel;
                    end;
                    
                    % create number of sessions x number of task records in
                    % sessionTaskInfo and fill them with provided session numbers and
                    % task labels.
                    numberOfSessionTaskTuples = inputOptions.numberOfSessions * length(inputOptions.taskLabels);
                    obj.sessionTaskInfo(1:numberOfSessionTaskTuples) = obj.sessionTaskInfo;
                    counter = 1;
                    
                    for i=1:inputOptions.numberOfSessions
                        for j=1:length(inputOptions.taskLabels)
                            obj.sessionTaskInfo(counter).sessionNumber = num2str(i);
                            obj.sessionTaskInfo(counter).taskLabel = inputOptions.taskLabels{j};
                            
                            for k=1:inputOptions.numberOfRecordingsPerSessionTask
                                obj.sessionTaskInfo(counter).dataRecording = typicalDataRecording;
                            end;
                            
                            counter = counter + 1;
                        end;
                    end;
                    
                    
                    obj.tasksInfo(1:length(inputOptions.taskLabels)) = obj.tasksInfo;
                    
                    subjectStructure = obj.sessionTaskInfo(1).subject;
                    if inputOptions.numberOfSubjectsPerSession > 1
                        for i=1:length(obj.sessionTaskInfo)
                            obj.sessionTaskInfo(i).subject(1:inputOptions.numberOfSubjectsPerSession) = subjectStructure;
                            
                            if inputOptions.numberOfSubjectsPerSession == 1
                                obj.sessionTaskInfo(i).subject(1).inSessionNumber = 1;
                            end;
                        end;
                    end;
                    
                    obj = obj.write(obj.essFilePath);
                    if exist(obj.essFilePath, 'file')
                    else
                        fprintf('Input file does not exist, creating a new ESS file with empty fields at %s.\n', obj.essFilePath);
                    end;
                end;
            end;
        end;
        
        function obj = read(obj, essFilePath)
            %  obj = read(essFilePath);
            %
            % Reads the information contained an ESS-formatted XML file and places it into object properties.
            
            function result = nodeExistsAndHasAChild(node)
                result = node.getLength > 0 && ~isempty( node.item(0).getFirstChild);
            end
            
            function outString  = readStringFromNode(node)
                firstChild = node.getFirstChild;
                if isempty(firstChild)
                    outString = '';
                else
                    outString = strtrim(char(firstChild.getData));
                end;
            end
            
            % first validate the XML file according to ESS STDL1 schema encoded in XML (an XSD file)
            % this is useful since during read we are only looking for the
            % first instance of each node but the XML might mistakanly
            % contain two more nodes, in which case the wrong information
            % may be read
            
            % get the class path
            thisClassFilenameAndPath = mfilename('fullpath');
            essDocumentPathStr = fileparts(thisClassFilenameAndPath);
            
            %             schemaFile = [essDocumentPathStr filesep 'asset' filesep 'ESS_STDL 1_schema.xsd'];
            %             [isValid, errorMessage] = validate_schema(essFilePath, schemaFile);
            %             if ~isValid
            %                 fprintf('The input XML failed to be validated against ESS Schema provided in %s.\n',  schemaFile);
            %                 error(errorMessage);
            %             end;
            %
            xmlDocument = xmlread(essFilePath);
            potentialStudyNodeArray = xmlDocument.getElementsByTagName('studyLevel1');
            
            if potentialStudyNodeArray.getLength == 0
                error('The XML file does not contain a study node.');
            elseif potentialStudyNodeArray.getLength == 1
                studyNode = potentialStudyNodeArray.item(0);
            else
                error('The XML file contains more than one study node.');
            end;
            
            % read ESS version.
            currentNode = studyNode;
            potentialEssVersionNodeArray = currentNode.getElementsByTagName('essVersion');
            obj.essVersion = readStringFromNode(potentialEssVersionNodeArray.item(0));
            
            % read HED version.
            currentNode = studyNode;
            potentialHedVersionNodeArray = currentNode.getElementsByTagName('hedVersion');
            if isempty(potentialHedVersionNodeArray.item(0))
                obj.hedVersion = 'NA';
            else
                obj.hedVersion = readStringFromNode(potentialHedVersionNodeArray.item(0));
            end;
            
            % if the file is in ESS 1.0 create an EEG modality with the
            % correct number for sampling rate.
            obj.recordingParameterSet(1).recordingParameterSetLabel = 'default EEG for ESS 1.0';
            obj.recordingParameterSet(1).modality(1).type = 'EEG';
            
            potentialDescriptionNodeArray = currentNode.getElementsByTagName('shortDescription');
            if nodeExistsAndHasAChild(potentialDescriptionNodeArray)
                obj.studyShortDescription = strtrim(char(potentialDescriptionNodeArray.item(0).getFirstChild.getData));
            else
                obj.studyShortDescription = '';
            end;
            
            
            potentialDescriptionNodeArray = currentNode.getElementsByTagName('description');
            if nodeExistsAndHasAChild(potentialDescriptionNodeArray)
                obj.studyDescription = strtrim(char(potentialDescriptionNodeArray.item(0).getFirstChild.getData));
            else
                obj.studyDescription = '';
            end;
            
            
            potentialTitleNodeArray = currentNode.getElementsByTagName('title');
            if nodeExistsAndHasAChild(potentialTitleNodeArray)
                obj.studyTitle = strtrim(char(potentialTitleNodeArray.item(0).getFirstChild.getData));
            else
                obj.studyTitle = '';
            end;
            
            potentialTitleNodeArray = currentNode.getElementsByTagName('uuid');
            if nodeExistsAndHasAChild(potentialTitleNodeArray)
                obj.studyUuid = readStringFromNode(potentialTitleNodeArray.item(0));
            else
                obj.studyUuid = '';
            end;
            
            
            rootURINodeArray = currentNode.getElementsByTagName('rootURI');
            if nodeExistsAndHasAChild(rootURINodeArray)
                obj.rootURI = readStringFromNode(rootURINodeArray.item(0));
            else
                obj.rootURI = '.';
            end;
            
            % start project node
            potentialProjectNodeArray = currentNode.getElementsByTagName('project');
            if nodeExistsAndHasAChild(potentialProjectNodeArray)
                obj.projectInfo = strtrim(char(potentialProjectNodeArray.item(0).getFirstChild.getData));
                
                potentialFundingNodeArray = currentNode.getElementsByTagName('funding'); % inside <Sessions> .. find <session> <session>
                if potentialFundingNodeArray.getLength > 0
                    
                    for fundingCounter = 0:(potentialFundingNodeArray.getLength-1)
                        currentNode = potentialFundingNodeArray.item(fundingCounter); % select a session and make it the current node.
                        fundingNode = currentNode;
                        
                        potentialFundingOrganizationNodeArray = currentNode.getElementsByTagName('organization');
                        
                        % to distinguish this from the organization node at the top level we need to
                        % look at its parent
                        theItemNumber = [];
                        for itemCounter = 0:(potentialFundingOrganizationNodeArray.getLength-1)
                            if potentialFundingOrganizationNodeArray.item(itemCounter).getParentNode == fundingNode
                                theItemNumber = itemCounter;
                            end;
                        end;
                        
                        if ~isempty(theItemNumber)
                            obj.projectInfo(fundingCounter+1).organization = readStringFromNode(potentialFundingOrganizationNodeArray.item(theItemNumber));
                        else
                            obj.projectInfo(fundingCounter+1).organization  = '';
                        end;
                        
                        potentialFundingGrantIdNodeArray = currentNode.getElementsByTagName('grantId');
                        if potentialFundingGrantIdNodeArray.getLength > 0
                            obj.projectInfo(fundingCounter+1).grantId = readStringFromNode(potentialFundingGrantIdNodeArray.item(0));
                        else
                            obj.projectInfo(fundingCounter+1).grantId = '';
                        end;
                    end;
                end;
            else % project information has not been provided, we need to create the appropriate subfields though.
                obj.projectInfo = struct('organization', '', 'grantId', '');
            end;
            
            
            % start tasks node
            currentNode = studyNode;
            potentialTasksNodeArray = currentNode.getElementsByTagName('tasks');
            if nodeExistsAndHasAChild(potentialTasksNodeArray)
                obj.tasksInfo = strtrim(char(potentialTasksNodeArray.item(0).getFirstChild.getData));
                
                potentialTaskNodeArray = currentNode.getElementsByTagName('task'); % inside <Sessions> .. find <session> <session>
                if potentialTaskNodeArray.getLength > 0
                    
                    for taskCounter = 0:(potentialTaskNodeArray.getLength-1)
                        currentNode = potentialTaskNodeArray.item(taskCounter); % select a session and make it the current node.
                        
                        potentialTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialTaskLabelNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).taskLabel = readStringFromNode(potentialTaskLabelNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).taskLabel  = '';
                        end;
                        
                        potentialTaskTagNodeArray = currentNode.getElementsByTagName('tag');
                        if potentialTaskTagNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).tag = readStringFromNode(potentialTaskTagNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).tag = '';
                        end;
                        
                        potentialTaskDescriptionNodeArray = currentNode.getElementsByTagName('description');
                        if potentialTaskDescriptionNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).description = readStringFromNode(potentialTaskDescriptionNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).description = '';
                        end;
                    end;
                end;
            else
                obj.tasksInfo= [];
            end;
            
            % recordingParameterSets
            currentNode = studyNode;
            potentialRecordingParameterSetsNodeArray = currentNode.getElementsByTagName('recordingParameterSets');
            if potentialRecordingParameterSetsNodeArray.getLength > 0
                currentNode = potentialRecordingParameterSetsNodeArray.item(0); % only use the first recordingParameterSets node
                
                potentialRecordingParameterSetNodeArray = currentNode.getElementsByTagName('recordingParameterSet');
                if potentialRecordingParameterSetNodeArray.getLength > 0
                    % go over all recording parameter sets
                    for parameterSetCounter = 0:(potentialRecordingParameterSetNodeArray.getLength-1)
                        currentNode = potentialRecordingParameterSetNodeArray.item(parameterSetCounter); % select a parameter set and make it the current node.
                        
                        % currentNode is now a single parameterSet node.
                        % read recordingParameterSetLabel
                        potentialrecordingParameterSetLabelNodeArray = currentNode.getElementsByTagName('recordingParameterSetLabel');
                        if potentialrecordingParameterSetLabelNodeArray.getLength > 0
                            obj.recordingParameterSet(parameterSetCounter+1).recordingParameterSetLabel = readStringFromNode(potentialrecordingParameterSetLabelNodeArray.item(0));
                        else
                            obj.recordingParameterSet(parameterSetCounter+1).recordingParameterSetLabel= '';
                        end;
                        
                        % find modality nodes under channelType node and
                        % read their data.
                        potentialChannelTypeNodeArray = currentNode.getElementsByTagName('channelType');
                        if potentialChannelTypeNodeArray.getLength > 0
                            currentNode = potentialChannelTypeNodeArray.item(0); % only use the first channelType node
                            
                            % go over modality nodes.
                            potentialModalityNodeArray = currentNode.getElementsByTagName('modality');
                            if potentialModalityNodeArray.getLength > 0
                                for modalityCounter = 0:(potentialModalityNodeArray.getLength-1)
                                    currentNode = potentialModalityNodeArray.item(modalityCounter);
                                    
                                    % read modality/type
                                    potentialTypeNodeArray = currentNode.getElementsByTagName('type');
                                    if potentialTypeNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).type = readStringFromNode(potentialTypeNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).type = '';
                                    end;
                                    
                                    % read modality/samplingRate
                                    potentialSamplingRateNodeArray = currentNode.getElementsByTagName('samplingRate');
                                    if potentialSamplingRateNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).samplingRate = readStringFromNode(potentialSamplingRateNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).samplingRate = '';
                                    end;
                                    
                                    
                                    % read modality/name
                                    potentialNameNodeArray = currentNode.getElementsByTagName('name');
                                    if potentialNameNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).name = readStringFromNode(potentialNameNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).name = '';
                                    end;
                                    
                                    % read modality/description
                                    potentialDescriptionNodeArray = currentNode.getElementsByTagName('description');
                                    if potentialDescriptionNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).description = readStringFromNode(potentialDescriptionNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).description = '';
                                    end;
                                    
                                    % read modality/startChannel
                                    potentialStartChannelNodeArray = currentNode.getElementsByTagName('startChannel');
                                    if potentialStartChannelNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).startChannel = readStringFromNode(potentialStartChannelNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).startChannel = '';
                                    end;
                                    
                                    % read modality/endChannel
                                    potentialEndChannelNodeArray = currentNode.getElementsByTagName('endChannel');
                                    if potentialEndChannelNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).endChannel = readStringFromNode(potentialEndChannelNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).endChannel = '';
                                    end;
                                    
                                    
                                    % read modality/subjectInSessionNumber
                                    potentialSubjectInSessionNumberNodeArray = currentNode.getElementsByTagName('subjectInSessionNumber');
                                    if potentialSubjectInSessionNumberNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).subjectInSessionNumber = readStringFromNode(potentialSubjectInSessionNumberNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).subjectInSessionNumber = '';
                                    end;
                                    
                                    % read modality/referenceLocation
                                    potentialReferenceLocationNodeArray = currentNode.getElementsByTagName('referenceLocation');
                                    if potentialReferenceLocationNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).referenceLocation = readStringFromNode(potentialReferenceLocationNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).referenceLocation = '';
                                    end;
                                    
                                    
                                    % read modality/referenceLabel
                                    potentialReferenceLabelNodeArray = currentNode.getElementsByTagName('referenceLabel');
                                    if potentialReferenceLabelNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).referenceLabel = readStringFromNode(potentialReferenceLabelNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).referenceLabel = '';
                                    end;
                                    
                                    % read modality/channelLocationType
                                    potentialChannelLocationTypeNodeArray = currentNode.getElementsByTagName('channelLocationType');
                                    if potentialChannelLocationTypeNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).channelLocationType = readStringFromNode(potentialChannelLocationTypeNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).channelLocationType= '';
                                    end;
                                    
                                    % read modality/channelLabel
                                    potentialChannelLabelNodeArray = currentNode.getElementsByTagName('channelLabel');
                                    if potentialChannelLabelNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).channelLabel = readStringFromNode(potentialChannelLabelNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).channelLabel= '';
                                    end;
                                    
                                    % read modality/nonScalpChannelLabel
                                    potentialNonScalpChannelLabelNodeArray = currentNode.getElementsByTagName('nonScalpChannelLabel');
                                    if potentialNonScalpChannelLabelNodeArray.getLength > 0
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).nonScalpChannelLabel = readStringFromNode(potentialNonScalpChannelLabelNodeArray.item(0));
                                    else
                                        obj.recordingParameterSet(parameterSetCounter+1).modality(modalityCounter + 1).nonScalpChannelLabel= '';
                                    end;
                                end;
                            end;
                        end;
                        
                        
                    end;
                end;
                
            end;
            
            currentNode = studyNode;
            potentialSessionsNodeArray = currentNode.getElementsByTagName('sessions');
            if potentialSessionsNodeArray.getLength > 0
                currentNode = potentialSessionsNodeArray.item(0);
                
                potentialSessionNodeArray = currentNode.getElementsByTagName('session'); % inside <Sessions> .. find <session> <session>
                if potentialSessionNodeArray.getLength > 0
                    % go each session found under 'sessions' node.
                    for sessionCounter = 0:(potentialSessionNodeArray.getLength-1)
                        currentNode = potentialSessionNodeArray.item(sessionCounter); % select a session and make it the current node.
                        singleSessionNode = currentNode;
                        
                        % currentNode is now a single-session node.
                        potentialNumberNodeArray = currentNode.getElementsByTagName('number');
                        if potentialNumberNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).sessionNumber = readStringFromNode(potentialNumberNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).sessionNumber= '';
                        end;
                        
                        potentialTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialTaskLabelNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).taskLabel = readStringFromNode(potentialTaskLabelNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).taskLabel= '';
                        end;                                                   
                        
                        potentialLabIdNodeArray = currentNode.getElementsByTagName('labId');
                        if potentialLabIdNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).labId = readStringFromNode(potentialLabIdNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).labId= '';
                        end;
                        
                        
                        if str2double(obj.essVersion) <= 1 % for ESS 1.0
                            potentialEegSamplingRateNodeArray = currentNode.getElementsByTagName('eegSamplingRate');
                            if potentialEegSamplingRateNodeArray.getLength > 0
                                % for now we asume all had the same
                                % sampling, a better way is to check all
                                % sampling rates and create different
                                % recordingParameter sets.
                                obj.recordingParameterSet(1).modality(1).samplingRate = readStringFromNode(potentialEegSamplingRateNodeArray.item(0));
                            end;
                        end;
                        
                        if str2double(obj.essVersion) <= 1 % for ESS 1.0
                            potentialEegRecordingsNodeArray = currentNode.getElementsByTagName('eegRecordings'); % inside <eegRecordings> find <eegRecording>
                            if potentialEegRecordingsNodeArray.getLength > 0
                                currentNode = potentialEegRecordingsNodeArray.item(0);
                                
                                potentialEegRecordingNodeArray = currentNode.getElementsByTagName('eegRecording');
                                for eegRecordingCounter = 0:(potentialEegRecordingNodeArray.getLength-1)
                                    if  potentialEegRecordingNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(eegRecordingCounter+1).filename = readStringFromNode(potentialEegRecordingNodeArray.item(eegRecordingCounter));
                                    end;
                                end;
                            end;
                        else % for ESS 2.0 and after
                            potentialDataRecordingsNodeArray = currentNode.getElementsByTagName('dataRecordings'); % inside <eegRecordings> find <eegRecording>
                            if potentialDataRecordingsNodeArray.getLength > 0
                                currentNode = potentialDataRecordingsNodeArray.item(0);
                                potentialDataRecordingNodeArray = currentNode.getElementsByTagName('dataRecording');
                                for dataRecordingCounter = 0:(potentialDataRecordingNodeArray.getLength-1)
                                    currentNode = potentialDataRecordingNodeArray.item(dataRecordingCounter);
                                    
                                    % inside each dataRecording
                                    potentialFilenameNodeArray = currentNode.getElementsByTagName('filename');
                                    if  potentialFilenameNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).filename = readStringFromNode(potentialFilenameNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).filename = '';
                                    end;
                                    
                                    potentialDataRecordingUuidNodeArray = currentNode.getElementsByTagName('dataRecordingUuid');
                                    if  potentialDataRecordingUuidNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).dataRecordingUuid = readStringFromNode(potentialDataRecordingUuidNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).dataRecordingUuid = '';
                                    end;
                                    
                                    potentialStartDateNodeArray = currentNode.getElementsByTagName('startDateTime');
                                    if  potentialStartDateNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).startDateTime = readStringFromNode(potentialStartDateNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).startDateTime = '';
                                    end;
                                    
                                    potentialrecordingParameterSetLabelNodeArray = currentNode.getElementsByTagName('recordingParameterSetLabel');
                                    if  potentialrecordingParameterSetLabelNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).recordingParameterSetLabel = readStringFromNode(potentialrecordingParameterSetLabelNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).recordingParameterSetLabel = '';
                                    end;
                                    
                                    potentialEventInstanceFileNodeArray = currentNode.getElementsByTagName('eventInstanceFile');
                                    if  potentialEventInstanceFileNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).eventInstanceFile = readStringFromNode(potentialEventInstanceFileNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).eventInstanceFile = '';
                                    end;
                                    
                                    potentialOriginalFileNameAndPathNodeArray = currentNode.getElementsByTagName('originalFileNameAndPath');
                                    if  potentialOriginalFileNameAndPathNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).originalFileNameAndPath = readStringFromNode(potentialOriginalFileNameAndPathNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).dataRecording(dataRecordingCounter+1).originalFileNameAndPath = '';
                                    end;
                                    
                                end;
                            end;
                        end;
                        
                        potentialNotesNodeArray = currentNode.getElementsByTagName('notes'); % inside <notes>
                        if potentialNotesNodeArray.getLength > 0
                            potentialNoteNodeArray = currentNode.getElementsByTagName('note');
                            if  potentialNoteNodeArray.getLength > 0
                                obj.sessionTaskInfo(sessionCounter+1).note= readStringFromNode(potentialNoteNodeArray.item(0));
                            else
                                obj.sessionTaskInfo(sessionCounter+1).note= '';
                            end;
                            
                            currentNode = potentialNotesNodeArray.item(0);
                            potentialLinkNameNodeArray = currentNode.getElementsByTagName('linkName');
                            if  potentialLinkNameNodeArray.getLength > 0
                                obj.sessionTaskInfo(sessionCounter+1).linkName = readStringFromNode(potentialLinkNameNodeArray.item(0)); % the if empty line
                            else
                                obj.sessionTaskInfo(sessionCounter+1).linkName= '';
                            end;
                            
                            potentialLinkNodeArray = currentNode.getElementsByTagName('link');
                            if  potentialLinkNodeArray.getLength > 0
                                obj.sessionTaskInfo(sessionCounter+1).link  = readStringFromNode(potentialLinkNodeArray.item(0));
                            else
                                obj.sessionTaskInfo(sessionCounter+1).link= '';
                            end;
                            
                        end;
                        
                        
                        
                        potentialSubjectNodeArray = singleSessionNode.getElementsByTagName('subject'); % inside <subject> for each session
                        
                        if potentialSubjectNodeArray.getLength > 0
                            for sessionSubjectCounter = 0:(potentialSubjectNodeArray.getLength-1)
                                
                                currentNode = potentialSubjectNodeArray.item(sessionSubjectCounter); % select a subject and make it the current node.
                                
                                potentialSubjectLabIdNodeArray = currentNode.getElementsByTagName('labId');
                                if potentialSubjectLabIdNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).labId = readStringFromNode(potentialSubjectLabIdNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).labId= '';
                                end;
                                
                                potentialSubjectInSessionNumberNodeArray = currentNode.getElementsByTagName('inSessionNumber');
                                if potentialSubjectInSessionNumberNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).inSessionNumber = readStringFromNode(potentialSubjectInSessionNumberNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).inSessionNumber = '';
                                end;
                                
                                potentialGroupNodeArray = currentNode.getElementsByTagName('group');
                                if potentialGroupNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).group = readStringFromNode(potentialGroupNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).group= '';
                                end;
                                
                                potentialGenderNodeArray = currentNode.getElementsByTagName('gender');
                                if potentialGenderNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).gender = readStringFromNode(potentialGenderNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).gender= '';
                                end;
                                
                                potentialYearOfBirthNodeArray = currentNode.getElementsByTagName('YOB');
                                if potentialYearOfBirthNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).YOB = readStringFromNode(potentialYearOfBirthNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).YOB= '';
                                end;
                                
                                potentialAgeNodeArray = currentNode.getElementsByTagName('age');
                                if potentialAgeNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).age = readStringFromNode(potentialAgeNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).age= '';
                                end;
                                
                                potentialHandNodeArray = currentNode.getElementsByTagName('hand');
                                if potentialHandNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hand = readStringFromNode(potentialHandNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hand= '';
                                end;
                                
                                potentialVisionNodeArray = currentNode.getElementsByTagName('vision');
                                if potentialVisionNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).vision = readStringFromNode(potentialVisionNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).vision= '';
                                end;
                                
                                potentialHearingNodeArray = currentNode.getElementsByTagName('hearing');
                                if potentialHearingNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hearing = readStringFromNode(potentialHearingNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hearing= '';
                                end;
                                
                                potentialHeightNodeArray = currentNode.getElementsByTagName('height');
                                if potentialHeightNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).height = readStringFromNode(potentialHeightNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).height= '';
                                end;
                                
                                potentialWeightNodeArray = currentNode.getElementsByTagName('weight');
                                if potentialWeightNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).weight = readStringFromNode(potentialWeightNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).weight= '';
                                end;
                                
                                potentialChannelLocationsNodeArray = currentNode.getElementsByTagName('channelLocations');
                                if potentialChannelLocationsNodeArray.getLength > 0
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocations = readStringFromNode(potentialChannelLocationsNodeArray.item(0));
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocations= '';
                                end;
                                
                                potentialMedicationNodeArray = currentNode.getElementsByTagName('medication');
                                if potentialMedicationNodeArray.getLength > 0
                                    potentialCaffeineNodeArray = currentNode.getElementsByTagName('caffeine');
                                    if potentialCaffeineNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine = readStringFromNode(potentialMedicationNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine= '';
                                    end
                                    
                                    potentialAlcoholNodeArray = currentNode.getElementsByTagName('alcohol');
                                    if potentialAlcoholNodeArray.getLength > 0
                                        obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol = readStringFromNode(potentialAlcoholNodeArray.item(0));
                                    else
                                        obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol= '';
                                    end
                                else
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine= '';
                                    obj.sessionTaskInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol= '';
                                end;
                                
                            end;
                        else % if subject node is not provided, use an empty array.
                            obj.sessionTaskInfo(sessionCounter+1).subject = [];
                        end; %end subject info
                        
                        
                    end;%ends specific session node, end for loop
                end;
                
            end; %ends sessions node
            
            % eventSpecificationMethod
            potentialeventSpecificationMethodNodeArray = studyNode.getElementsByTagName('eventSpecificationMethod');
            if nodeExistsAndHasAChild(potentialeventSpecificationMethodNodeArray)
                obj.eventSpecificationMethod = strtrim(char(potentialeventSpecificationMethodNodeArray.item(0).getFirstChild.getData));
            else % read the legacy files with the eventSpecificiationMethod typo
                potentialeventSpecificationMethodNodeArray = studyNode.getElementsByTagName('eventSpecificiationMethod');
                if nodeExistsAndHasAChild(potentialeventSpecificationMethodNodeArray)
                    obj.eventSpecificationMethod = strtrim(char(potentialeventSpecificationMethodNodeArray.item(0).getFirstChild.getData));
                    warning('Legacy file containing ''eventSpecificiationMethod'' typo detected. Please save the object (obj.write) to fix the file');
                else
                    obj.eventSpecificationMethod = '';
                end;
            end;
            
            % isInEssContainer
            potentialIsInEssContainerNodeArray = studyNode.getElementsByTagName('isInEssContainer');
            if nodeExistsAndHasAChild(potentialIsInEssContainerNodeArray)
                obj.isInEssContainer = strtrim(char(potentialIsInEssContainerNodeArray.item(0).getFirstChild.getData));
            else
                obj.isInEssContainer = '';
            end;
            
            currentNode = studyNode;
            %start event codes
            potentialEventCodesNodeArray = currentNode.getElementsByTagName('eventCodes');
            if potentialEventCodesNodeArray.getLength > 0
                obj.eventCodesInfo = strtrim(char(potentialEventCodesNodeArray.item(0).getFirstChild.getData));
                
                potentialEventCodeNodeArray = currentNode.getElementsByTagName('eventCode'); % inside <Sessions> .. find <session> <session>
                if potentialEventCodeNodeArray.getLength > 0
                    
                    for eventCodeCounter = 0:(potentialEventCodeNodeArray.getLength-1)
                        currentNode = potentialEventCodeNodeArray.item(eventCodeCounter); % select a session and make it the current node.
                        singleEventCodeNode = currentNode;
                        
                        potentialCodeNodeArray = currentNode.getElementsByTagName('code');
                        if potentialCodeNodeArray.getLength > 0
                            obj.eventCodesInfo(eventCodeCounter+1).code = readStringFromNode(potentialCodeNodeArray.item(0));
                        else
                            obj.eventCodesInfo(eventCodeCounter+1).code = '';
                        end;
                        
                        potentialCodeTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialCodeTaskLabelNodeArray.getLength > 0
                            obj.eventCodesInfo(eventCodeCounter+1).taskLabel = readStringFromNode(potentialCodeTaskLabelNodeArray.item(0));
                        else
                            obj.eventCodesInfo(eventCodeCounter+1).taskLabel = '';
                        end;
                        
                        potentialCodeNumberOfInstancesNodeArray = currentNode.getElementsByTagName('numberOfInstances');
                        if potentialCodeNumberOfInstancesNodeArray.getLength > 0
                            obj.eventCodesInfo(eventCodeCounter+1).numberOfInstances = readStringFromNode(potentialCodeNumberOfInstancesNodeArray.item(0));
                        else
                            obj.eventCodesInfo(eventCodeCounter+1).numberOfInstances = '';
                        end;
                        
                        potentialCodeConditionNodeArray = singleEventCodeNode.getElementsByTagName('condition');
                        if potentialCodeConditionNodeArray.getLength > 0
                            for codeConditionCounter = 0:(potentialCodeConditionNodeArray.getLength-1)
                                currentNode = potentialCodeConditionNodeArray.item(codeConditionCounter); % select a session and make it the current node.
                                
                                potentialConditionLabelArray = currentNode.getElementsByTagName('label');
                                if potentialConditionLabelArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).label = readStringFromNode(potentialConditionLabelArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).label = '';
                                end;
                                
                                potentialConditionDescriptionArray = currentNode.getElementsByTagName('description');
                                if potentialConditionDescriptionArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).description = readStringFromNode(potentialConditionDescriptionArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).description = '';
                                end;
                                
                                potentialConditionTagArray = currentNode.getElementsByTagName('tag');
                                if potentialConditionTagArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).tag = readStringFromNode(potentialConditionTagArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).tag = '';
                                end;
                            end;
                            
                        end;
                    end;
                    
                    
                end;
                
            end; %ends event codes
            
            
            %starts summary info
            currentNode = studyNode;
            potentialSummaryNodeArray = currentNode.getElementsByTagName('summary');
            if potentialSummaryNodeArray.getLength > 0
                obj.summaryInfo = strtrim(char(potentialSummaryNodeArray.item(0).getFirstChild.getData));
                
                potentialTotalSizeArray = currentNode.getElementsByTagName('totalSize');
                if potentialTotalSizeArray.getLength > 0
                    obj.summaryInfo.totalSize = readStringFromNode(potentialTotalSizeArray.item(0));
                else isempty(obj.summaryInfo.totalSize)
                    obj.summaryInfo.totalSize= '';
                end;
                potentialAllSubjectsHealthyAndNormalArray = currentNode.getElementsByTagName('allSubjectsHealthyAndNormal');
                if potentialAllSubjectsHealthyAndNormalArray.getLength > 0
                    obj.summaryInfo.allSubjectsHealthyAndNormal = readStringFromNode(potentialAllSubjectsHealthyAndNormalArray.item(0));
                else
                    obj.summaryInfo.allSubjectsHealthyAndNorma= '';
                end;
                
                
                currentNode = studyNode;
                potentialLicenseNodeArray = currentNode.getElementsByTagName('license');
                if potentialLicenseNodeArray.getLength > 0
                    currentNode = potentialLicenseNodeArray.item(0);
                    obj.summaryInfo.license = strtrim(char(potentialLicenseNodeArray.item(0).getFirstChild.getData));
                    potentialLicenseTypeArray = currentNode.getElementsByTagName('type');
                    if potentialLicenseTypeArray.getLength > 0
                        obj.summaryInfo.license.type = readStringFromNode(potentialLicenseTypeArray.item(0));
                    end;
                    if isempty(obj.summaryInfo.license.type)
                        obj.summaryInfo.license.type= '';
                    end;
                    
                    potentialLicenseTextArray = currentNode.getElementsByTagName('text');
                    if potentialLicenseTextArray.getLength > 0
                        obj.summaryInfo.license.text = readStringFromNode(potentialLicenseTextArray.item(0));
                    end;
                    
                    potentialLicenseLinkArray = currentNode.getElementsByTagName('link');
                    if potentialLicenseLinkArray.getLength > 0
                        obj.summaryInfo.license.link = readStringFromNode(potentialLicenseLinkArray.item(0));
                    end;
                    
                end;
                
            end;%end summary info
            
            
            %start publications info
            currentNode = studyNode;
            
            potentialPublicationsNodeArray = currentNode.getElementsByTagName('publications');
            if potentialPublicationsNodeArray.getLength > 0
                obj.publicationsInfo = strtrim(char(potentialPublicationsNodeArray.item(0).getFirstChild.getData));
                
                potentialPublicationNodeArray = currentNode.getElementsByTagName('publication'); % inside <Sessions> .. find <session> <session>
                if potentialPublicationNodeArray.getLength > 0
                    
                    for publicationCounter = 0:(potentialPublicationNodeArray.getLength-1)
                        currentNode = potentialPublicationNodeArray.item(publicationCounter); % select a session and make it the current node.
                        
                        potentialPublicationCitationNodeArray = currentNode.getElementsByTagName('citation');
                        if potentialPublicationCitationNodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).citation = readStringFromNode(potentialPublicationCitationNodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).citation ='';
                        end;
                        
                        potentialPublicationDOINodeArray = currentNode.getElementsByTagName('DOI');
                        if potentialPublicationDOINodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).DOI = readStringFromNode(potentialPublicationDOINodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).DOI = '';
                        end;
                        
                        potentialPublicationLinkNodeArray = currentNode.getElementsByTagName('link');
                        if potentialPublicationLinkNodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).link = readStringFromNode(potentialPublicationLinkNodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).link = '';
                        end;
                    end;
                    
                    
                end;
            else % if subject node is not provided, use an empty array.
                obj.publicationsInfo = [];
            end; %end publications info
            
            
            %start experimenters
            currentNode = studyNode;
            potentialExperimentersNodeArray = currentNode.getElementsByTagName('experimenters');
            if potentialExperimentersNodeArray.getLength > 0
                obj.experimentersInfo = strtrim(char(potentialExperimentersNodeArray.item(0).getFirstChild.getData));
                
                potentialExperimenterNodeArray = currentNode.getElementsByTagName('experimenter'); % inside <Sessions> .. find <session> <session>
                if potentialExperimenterNodeArray.getLength > 0
                    
                    for experimenterCounter = 0:(potentialExperimenterNodeArray.getLength-1)
                        currentNode = potentialExperimenterNodeArray.item(experimenterCounter); % select a session and make it the current node.
                        
                        %name is not showing up
                        potentialExperimenterNameNodeArray = currentNode.getElementsByTagName('name');
                        if potentialExperimenterNameNodeArray.getLength > 0
                            obj.experimentersInfo(experimenterCounter+1).name = readStringFromNode(potentialExperimenterNameNodeArray.item(0));
                        else
                            obj.experimentersInfo(experimenterCounter+1).name = '';
                        end;
                        
                        potentialExperimenterRoleNodeArray = currentNode.getElementsByTagName('role');
                        if potentialExperimenterRoleNodeArray.getLength > 0
                            obj.experimentersInfo(experimenterCounter+1).role = readStringFromNode(potentialExperimenterRoleNodeArray.item(0));
                        else
                            obj.experimentersInfo(experimenterCounter+1) = '';
                        end;
                    end;
                    
                    
                end;
            else
                obj.experimentersInfo= [];
            end; %end experimenters information
            
            
            % start contact info
            currentNode = studyNode;
            
            potentialContactNodeArray = currentNode.getElementsByTagName('contact');
            if potentialContactNodeArray.getLength > 0
                obj.contactInfo = struct;
                currentNode = potentialContactNodeArray.item(0); % go inside the contact node
                potentialContactNameNodeArray = currentNode.getElementsByTagName('name');
                if potentialContactNameNodeArray.getLength > 0
                    obj.contactInfo.name = readStringFromNode(potentialContactNameNodeArray.item(0));
                else
                    obj.contactInfo.name = '';
                end;
                
                potentialContactPhoneNodeArray = currentNode.getElementsByTagName('phone');
                if potentialContactPhoneNodeArray.getLength > 0
                    obj.contactInfo.phone = readStringFromNode(potentialContactPhoneNodeArray.item(0));
                else
                    obj.contactInfo.phone= '';
                end;
                potentialContactEmailNodeArray = currentNode.getElementsByTagName('email');
                if potentialContactEmailNodeArray.getLength > 0
                    obj.contactInfo.email = readStringFromNode(potentialContactEmailNodeArray.item(0));
                else
                    obj.contactInfo.email= '';
                end;
            else
                obj.contactInfo = [];
            end;%end contact info
            
            
            %start organization info
            currentNode = studyNode; % going back to the study node.
            potentialOrgNodeArray = currentNode.getElementsByTagName('organization');
            
            % there are two 'organization' nodes in the ESS, the one that is under <project<funding> and
            % specifies the organization that has funded the projects, e.g. NIH or NSF and then there is
            % the organization node that is under the study node and contains name and logoLink info.
            % Here we need to find the one that is under the study node.
            theItemNumber = [];
            for itemCounter = 0:(potentialOrgNodeArray.getLength-1)
                if potentialOrgNodeArray.item(itemCounter).getParentNode == studyNode
                    theItemNumber = itemCounter;
                end;
            end;
            
            if ~isempty(theItemNumber)
                currentNode = potentialOrgNodeArray.item(theItemNumber);
                potentialOrgNameNodeArray = currentNode.getElementsByTagName('name');
                if potentialOrgNameNodeArray.getLength > 0
                    obj.organizationInfo.name = readStringFromNode(potentialOrgNameNodeArray.item(0));
                else
                    obj.organizationInfo.name = '';
                end;
                
                potentialOrganizationLogoNodeArray = currentNode.getElementsByTagName('logoLink');
                if potentialOrganizationLogoNodeArray.getLength > 0
                    obj.organizationInfo.logoLink = readStringFromNode(potentialOrganizationLogoNodeArray.item(0));
                else
                    obj.organizationInfo.logoLink ='';
                end;
            else
                obj.organizationInfo = struct('name', '', 'logoLink', '');
                
            end;%end organization Info
            
            currentNode = studyNode;
            potentialCopyrightNodeArray = currentNode.getElementsByTagName('copyright');
            if potentialCopyrightNodeArray.getLength > 1
                obj.copyrightInfo = readStringFromNode(potentialCopyrightNodeArray.item(0));
            else
                obj.copyrightInfo = '';
            end;%end copyright Info
            
            currentNode = studyNode;
            potentialIRBNodeArray = currentNode.getElementsByTagName('IRB');
            if potentialIRBNodeArray.getLength > 0
                obj.irbInfo = readStringFromNode(potentialIRBNodeArray.item(0));
            else
                obj.irbInfo = '';
            end;
            
            % sort data recordings for each (session, task) tuple by time
            % (startDateTime)
            obj = sortDataRecordingsByStartTime(obj);
            
        end;
        
        function obj = write(obj, essFilePath, alsoWriteJson)
            % obj = write(essFilePath, alsoWriteJson)
            %
            % Writes the information into an ESS-formatted XML file and JSON manifest.js file.
            
            if nargin < 3
                alsoWriteJson = true;
            end;                       
            
            if nargin < 2 && isempty(obj.essFilePath)
                error('Please provide the name of the output file in the first input argument');
            end;
            
            if nargin >=2
                obj.essFilePath = essFilePath;
            end;
            
            if alsoWriteJson
                obj.writeJSONP(fileparts(obj.essFilePath)); % since this function has an internal call to obj.write, this prevents circular references
            end;
            
            docNode = com.mathworks.xml.XMLUtils.createDocument('studyLevel1');
            docRootNode = docNode.getDocumentElement;
            
            essVersionElement = docNode.createElement('essVersion');
            essVersionElement.appendChild(docNode.createTextNode(obj.essVersion));
            docRootNode.appendChild(essVersionElement);
            
            hedVersionElement = docNode.createElement('hedVersion');
            hedVersionElement.appendChild(docNode.createTextNode(obj.hedVersion));
            docRootNode.appendChild(hedVersionElement);
            
            titleElement = docNode.createElement('title');
            titleElement.appendChild(docNode.createTextNode(obj.studyTitle));
            docRootNode.appendChild(titleElement);
            
            shortDescriptionElement = docNode.createElement('shortDescription');
            shortDescriptionElement.appendChild(docNode.createTextNode(obj.studyShortDescription));
            docRootNode.appendChild(shortDescriptionElement);
            
            
            descriptionElement = docNode.createElement('description');
            descriptionElement.appendChild(docNode.createTextNode(obj.studyDescription));
            docRootNode.appendChild(descriptionElement);
            
            uuidElement = docNode.createElement('uuid');
            uuidElement.appendChild(docNode.createTextNode(obj.studyUuid));
            docRootNode.appendChild(uuidElement);
            
            rootURIElement = docNode.createElement('rootURI');
            rootURIElement.appendChild(docNode.createTextNode(obj.rootURI));
            docRootNode.appendChild(rootURIElement);
            
            eventSpecificationMethodElement = docNode.createElement('eventSpecificationMethod');
            eventSpecificationMethodElement.appendChild(docNode.createTextNode(obj.eventSpecificationMethod));
            docRootNode.appendChild(eventSpecificationMethodElement);
            
            % isInEssContainer
            isInEssContainerElement = docNode.createElement('isInEssContainer');
            isInEssContainerElement.appendChild(docNode.createTextNode(obj.isInEssContainer));
            docRootNode.appendChild(isInEssContainerElement);
            
            projectElement = docNode.createElement('project');
            projectRootNode=docRootNode.appendChild(projectElement);
            
            for y=1:length(obj.projectInfo)
                fundingElement = docNode.createElement('funding');
                fundingRootNode= projectRootNode.appendChild(fundingElement);
                
                fundingOrganizationElement = docNode.createElement('organization');
                fundingOrganizationElement.appendChild(docNode.createTextNode(obj.projectInfo(y).organization));
                fundingRootNode.appendChild(fundingOrganizationElement);
                
                fundingGrantIdElement = docNode.createElement('grantId');
                fundingGrantIdElement.appendChild(docNode.createTextNode(obj.projectInfo(y).grantId));
                fundingRootNode.appendChild(fundingGrantIdElement);
                
            end;
            
            % write recordingParameterSets
            recordingParameterSetsElement = docNode.createElement('recordingParameterSets');
            recordingParameterSetsRootNode = docRootNode.appendChild(recordingParameterSetsElement);
            
            for i=1:length(obj.recordingParameterSet)
                recordingParameterSetElement = docNode.createElement('recordingParameterSet');
                recordingParameterSetRootNode = recordingParameterSetsRootNode.appendChild(recordingParameterSetElement);
                
                recordingParameterSetLabelElement = docNode.createElement('recordingParameterSetLabel');
                recordingParameterSetLabelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).recordingParameterSetLabel));
                recordingParameterSetRootNode.appendChild(recordingParameterSetLabelElement);
                
                % create channelType node.
                channelTypeElement = docNode.createElement('channelType');
                channelTypeRootNode = recordingParameterSetRootNode.appendChild(channelTypeElement);
                
                
                
                for j=1:length(obj.recordingParameterSet(i).modality)
                    % create modality  node
                    modalityElement = docNode.createElement('modality');
                    modalityRootNode = channelTypeRootNode.appendChild(modalityElement);
                    
                    % create modality/type  node
                    typeElement = docNode.createElement('type');
                    typeElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).type));
                    modalityRootNode.appendChild(typeElement);
                    
                    % create modality/samplingRate  node
                    samplingRateElement = docNode.createElement('samplingRate');
                    samplingRateElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).samplingRate));
                    modalityRootNode.appendChild(samplingRateElement);
                    
                    % create modality/type node
                    nameElement = docNode.createElement('name');
                    nameElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).name));
                    modalityRootNode.appendChild(nameElement);
                    
                    % create modality/description node
                    descriptionElement = docNode.createElement('description');
                    descriptionElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).description));
                    modalityRootNode.appendChild(descriptionElement);
                    
                    % create modality/startChannel node
                    startChannelElement = docNode.createElement('startChannel');
                    startChannelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).startChannel));
                    modalityRootNode.appendChild(startChannelElement);
                    
                    % create modality/endChannel  node
                    endChannelElement = docNode.createElement('endChannel');
                    endChannelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).endChannel));
                    modalityRootNode.appendChild(endChannelElement);
                    
                    % create modality/subjectInSessionNumber  node
                    subjectInSessionNumberElement = docNode.createElement('subjectInSessionNumber');
                    subjectInSessionNumberElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).subjectInSessionNumber));
                    modalityRootNode.appendChild(subjectInSessionNumberElement);
                    
                    
                    % create modality/referenceLocation node
                    referenceLabelElement = docNode.createElement('referenceLocation');
                    referenceLabelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).referenceLocation));
                    modalityRootNode.appendChild(referenceLabelElement);
                    
                    
                    % create modality/referenceLabel node
                    referenceLabelElement = docNode.createElement('referenceLabel');
                    referenceLabelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).referenceLabel));
                    modalityRootNode.appendChild(referenceLabelElement);
                    
                    % create modality/channelLocationType node
                    channelLocationTypeElement = docNode.createElement('channelLocationType');
                    channelLocationTypeElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).channelLocationType));
                    modalityRootNode.appendChild(channelLocationTypeElement);
                    
                    % create modality/channelLabel node
                    channelLabelElement = docNode.createElement('channelLabel');
                    channelLabelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).channelLabel));
                    modalityRootNode.appendChild(channelLabelElement);
                    
                    % create modality/nonScalpChannelLabel node
                    nonScalpChannelLabelElement = docNode.createElement('nonScalpChannelLabel');
                    nonScalpChannelLabelElement.appendChild(docNode.createTextNode(obj.recordingParameterSet(i).modality(j).nonScalpChannelLabel));
                    modalityRootNode.appendChild(nonScalpChannelLabelElement);
                end
                
            end;
            
            
            sessionsElement = docNode.createElement('sessions');
            sessionsRootNode = docRootNode.appendChild(sessionsElement);
            
            for i=1:length(obj.sessionTaskInfo)
                sessionElement = docNode.createElement('session');
                sessionRootNode= sessionsRootNode.appendChild(sessionElement);
                
                numberElement = docNode.createElement('number');
                numberElement.appendChild(docNode.createTextNode (obj.sessionTaskInfo(i).sessionNumber));
                sessionRootNode.appendChild(numberElement);
                
                sessionTaskLabelElement = docNode.createElement('taskLabel');
                sessionTaskLabelElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).taskLabel));
                sessionRootNode.appendChild(sessionTaskLabelElement);                      
                                 
                labIdElement = docNode.createElement('labId');
                labIdElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).labId));
                sessionRootNode.appendChild(labIdElement);
                
                for j=1:length(obj.sessionTaskInfo(i).subject)
                    subjectElement = docNode.createElement('subject');
                    subjectRootNode= sessionRootNode.appendChild(subjectElement);
                    
                    subjectLabIdElement = docNode.createElement('labId');
                    subjectLabIdElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).labId));
                    subjectRootNode.appendChild(subjectLabIdElement);
                    
                    subjectInSessionNumberElement = docNode.createElement('inSessionNumber');
                    subjectInSessionNumberElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).inSessionNumber));
                    subjectRootNode.appendChild(subjectInSessionNumberElement);
                    
                    subjectGroupElement = docNode.createElement('group');
                    subjectGroupElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).group));
                    subjectRootNode.appendChild(subjectGroupElement);
                    
                    subjectGenderElement = docNode.createElement('gender');
                    subjectGenderElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).gender));
                    subjectRootNode.appendChild(subjectGenderElement);
                    
                    subjectYOBElement = docNode.createElement('YOB');
                    subjectYOBElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).YOB));
                    subjectRootNode.appendChild(subjectYOBElement);
                    
                    subjectAgeElement = docNode.createElement('age');
                    subjectAgeElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).age));
                    subjectRootNode.appendChild(subjectAgeElement);
                    
                    subjectHandElement = docNode.createElement('hand');
                    subjectHandElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).hand));
                    subjectRootNode.appendChild(subjectHandElement);
                    
                    subjectVisionElement = docNode.createElement('vision');
                    subjectVisionElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).vision));
                    subjectRootNode.appendChild(subjectVisionElement);
                    
                    subjectHearingElement = docNode.createElement('hearing');
                    subjectHearingElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).hearing));
                    subjectRootNode.appendChild(subjectHearingElement);
                    
                    subjectHeightElement = docNode.createElement('height');
                    subjectHeightElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).height));
                    subjectRootNode.appendChild(subjectHeightElement);
                    
                    subjectWeightElement = docNode.createElement('weight');
                    subjectWeightElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).weight));
                    subjectRootNode.appendChild(subjectWeightElement);
                    
                    subjectMedicationElement = docNode.createElement('medication');
                    medicationRootNode= subjectRootNode.appendChild(subjectMedicationElement);
                    
                    % caffeine and alcohol elements producing error
                    caffeineElement = docNode.createElement('caffeine');
                    caffeineElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).medication.caffeine));
                    medicationRootNode.appendChild(caffeineElement);
                    
                    alcoholElement = docNode.createElement('alcohol');
                    alcoholElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).medication.alcohol));
                    medicationRootNode.appendChild(alcoholElement);
                    
                    
                    subjectChannelLocationsElement = docNode.createElement('channelLocations');
                    subjectChannelLocationsElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).subject(j).channelLocations));
                    subjectRootNode.appendChild(subjectChannelLocationsElement);
                end;
                
                % ToDo: take care of channel the same way as eegSampling
                % rate
                notesElement = docNode.createElement('notes');
                notesRootNode= sessionRootNode.appendChild(notesElement);
                
                noteElement = docNode.createElement('note');
                noteElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).note));
                notesRootNode.appendChild(noteElement);
                
                noteLinkNameElement = docNode.createElement('linkName');
                noteLinkNameElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).linkName));
                notesRootNode.appendChild(noteLinkNameElement);
                
                noteLinkElement = docNode.createElement('link');
                noteLinkElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).link));
                notesRootNode.appendChild(noteLinkElement);
                
                dataRecordingsElement = docNode.createElement('dataRecordings');
                dataRecordingsRootNode= sessionRootNode.appendChild(dataRecordingsElement);
                
                for k=1:length(obj.sessionTaskInfo(i).dataRecording)
                    % create the recording node
                    dataRecordingElement = docNode.createElement('dataRecording');
                    
                    % create the filename node under dataRecording node.
                    dataRecordingFilenameElement = docNode.createElement('filename');
                    dataRecordingFilenameElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).filename));
                    dataRecordingElement.appendChild(dataRecordingFilenameElement);
                    
                    % create the dataRecordingUuid node under dataRecording node.
                    dataRecordingDataRecordingUuidElement = docNode.createElement('dataRecordingUuid');
                    dataRecordingDataRecordingUuidElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).dataRecordingUuid));
                    dataRecordingElement.appendChild(dataRecordingDataRecordingUuidElement);
                    
                    % create the startDateTime node under dataRecording node.
                    dataRecordingStartDateElement = docNode.createElement('startDateTime');
                    dataRecordingStartDateElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).startDateTime));
                    dataRecordingElement.appendChild(dataRecordingStartDateElement);
                    
                    % create the recordingParameterSetLabel node under dataRecording node.
                    dataRecordingRecordingParameterSetLabelElement = docNode.createElement('recordingParameterSetLabel');
                    dataRecordingRecordingParameterSetLabelElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).recordingParameterSetLabel));
                    dataRecordingElement.appendChild(dataRecordingRecordingParameterSetLabelElement);
                    
                    
                    
                    % create the eventInstanceFile node under dataRecording node.
                    dataRecordingEventInstanceFilelElement = docNode.createElement('eventInstanceFile');
                    dataRecordingEventInstanceFilelElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).eventInstanceFile));
                    dataRecordingElement.appendChild(dataRecordingEventInstanceFilelElement);
                    
                    
                    % create the originalFileNameAndPath node under dataRecording node.
                    dataRecordingOriginalFileNameAndPathElement = docNode.createElement('originalFileNameAndPath');
                    dataRecordingOriginalFileNameAndPathElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).dataRecording(k).originalFileNameAndPath));
                    dataRecordingElement.appendChild(dataRecordingOriginalFileNameAndPathElement);
                    
                    
                    dataRecordingsRootNode.appendChild(dataRecordingElement);
                end;
            end;
            
            tasksElement = docNode.createElement('tasks');
            tasksRootNode=docRootNode.appendChild(tasksElement);
            
            for m=1:length(obj.tasksInfo)
                taskElement = docNode.createElement('task');
                taskRootNode= tasksRootNode.appendChild(taskElement);
                
                taskLabelElement = docNode.createElement('taskLabel');
                taskLabelElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).taskLabel));
                taskRootNode.appendChild(taskLabelElement);
                
                taskTagElement = docNode.createElement('tag');
                taskTagElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).tag));
                taskRootNode.appendChild(taskTagElement);
                
                taskDescriptionElement = docNode.createElement('description');
                taskDescriptionElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).description));
                taskRootNode.appendChild(taskDescriptionElement);
            end;
            
            eventCodesElement = docNode.createElement('eventCodes');
            eventCodesRootNode=docRootNode.appendChild(eventCodesElement);
            
            for n=1:length(obj.eventCodesInfo)
                eventCodeElement = docNode.createElement('eventCode');
                eventCodeRootNode=eventCodesRootNode.appendChild(eventCodeElement);
                
                eventCodeNodeElement = docNode.createElement('code');
                eventCodeNodeElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).code));
                eventCodeRootNode.appendChild(eventCodeNodeElement);
                
                eventCodeTaskLabelElement = docNode.createElement('taskLabel');
                eventCodeTaskLabelElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).taskLabel));
                eventCodeRootNode.appendChild(eventCodeTaskLabelElement);
                
                eventCodeNumberOfInstancesElement = docNode.createElement('numberOfInstances');
                eventCodeNumberOfInstancesElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).numberOfInstances));
                eventCodeRootNode.appendChild(eventCodeNumberOfInstancesElement);
                
                for p= 1:length(obj.eventCodesInfo(n).condition)
                    eventCodeConditionElement = docNode.createElement('condition');
                    eventCodeConditionRootNode=eventCodeRootNode.appendChild(eventCodeConditionElement);
                    
                    eventCodeConditionLabelElement = docNode.createElement('label');
                    eventCodeConditionLabelElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).label));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionLabelElement);
                    
                    eventCodeConditionDescriptionElement = docNode.createElement('description');
                    eventCodeConditionDescriptionElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).description));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionDescriptionElement);
                    
                    eventCodeConditionTagElement = docNode.createElement('tag');
                    eventCodeConditionTagElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).tag));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionTagElement);
                end;
            end;
            
            summaryElement = docNode.createElement('summary');
            summaryRootNode=docRootNode.appendChild(summaryElement);
            
            summaryTotalSizeElement = docNode.createElement('totalSize');
            summaryTotalSizeElement.appendChild(docNode.createTextNode(obj.summaryInfo.totalSize));
            summaryRootNode.appendChild(summaryTotalSizeElement);
            
            summaryAllSubjectsElement = docNode.createElement('allSubjectsHealthyAndNormal');
            summaryAllSubjectsElement.appendChild(docNode.createTextNode(obj.summaryInfo.allSubjectsHealthyAndNormal));
            summaryRootNode.appendChild(summaryAllSubjectsElement);
            
            summaryLicenseElement = docNode.createElement('license');
            summaryLicenseRootNode=summaryRootNode.appendChild(summaryLicenseElement);
            
            summaryLicenseTypeElement = docNode.createElement('type');
            summaryLicenseTypeElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.type));
            summaryLicenseRootNode.appendChild(summaryLicenseTypeElement);
            
            summaryLicenseTextElement = docNode.createElement('text');
            summaryLicenseTextElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.text));
            summaryLicenseRootNode.appendChild(summaryLicenseTextElement);
            
            summaryLicenseLinkElement = docNode.createElement('link');
            summaryLicenseLinkElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.link));
            summaryLicenseRootNode.appendChild(summaryLicenseLinkElement);
            
            publicationsElement = docNode.createElement('publications');
            publicationsRootNode=docRootNode.appendChild(publicationsElement);
            
            for r= 1: length(obj.publicationsInfo)
                publicationElement = docNode.createElement('publication');
                publicationRootNode=publicationsRootNode.appendChild(publicationElement);
                
                publicationCitationElement = docNode.createElement('citation');
                publicationCitationElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).citation));
                publicationRootNode.appendChild(publicationCitationElement);
                
                publicationDoiElement = docNode.createElement('DOI');
                publicationDoiElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).DOI));
                publicationRootNode.appendChild(publicationDoiElement);
                
                publicationLinkElement = docNode.createElement('link');
                publicationLinkElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).link));
                publicationRootNode.appendChild(publicationLinkElement);
                
            end;
            
            experimentersElement = docNode.createElement('experimenters');
            experimentersRootNode=docRootNode.appendChild(experimentersElement);
            
            for x=1:length(obj.experimentersInfo)
                experimenterElement = docNode.createElement('experimenter');
                experimenterRootNode=experimentersRootNode.appendChild(experimenterElement);
                
                experimenterNameElement = docNode.createElement('name');
                experimenterNameElement.appendChild(docNode.createTextNode(obj.experimentersInfo(x).name));
                experimenterRootNode.appendChild(experimenterNameElement);
                
                experimenterRoleElement = docNode.createElement('role');
                experimenterRoleElement.appendChild(docNode.createTextNode(obj.experimentersInfo(x).role));
                experimenterRootNode.appendChild(experimenterRoleElement);
            end;
            
            contactElement = docNode.createElement('contact');
            contactRootNode=docRootNode.appendChild(contactElement);
            
            contactNameElement = docNode.createElement('name');
            contactNameElement.appendChild(docNode.createTextNode(obj.contactInfo.name));
            contactRootNode.appendChild(contactNameElement);
            
            contactPhoneElement = docNode.createElement('phone');
            contactPhoneElement.appendChild(docNode.createTextNode(obj.contactInfo.phone));
            contactRootNode.appendChild(contactPhoneElement);
            
            contactEmailElement = docNode.createElement('email');
            contactEmailElement.appendChild(docNode.createTextNode(obj.contactInfo.email));
            contactRootNode.appendChild(contactEmailElement);
            
            organizationElement = docNode.createElement('organization');
            organizationRootNode=docRootNode.appendChild(organizationElement);
            
            organizationNameElement = docNode.createElement('name');
            organizationNameElement.appendChild(docNode.createTextNode(obj.organizationInfo.name));
            organizationRootNode.appendChild(organizationNameElement);
            
            organizationLogoLinkElement = docNode.createElement('logoLink');
            organizationLogoLinkElement.appendChild(docNode.createTextNode(obj.organizationInfo.logoLink));
            organizationRootNode.appendChild(organizationLogoLinkElement);
            
            copyrightElement = docNode.createElement('copyright');
            copyrightElement.appendChild(docNode.createTextNode(obj.copyrightInfo));
            docRootNode.appendChild(copyrightElement);
            
            IrbElement = docNode.createElement('IRB');
            IrbElement.appendChild(docNode.createTextNode(obj.irbInfo));
            docRootNode.appendChild(IrbElement);
            
            proc = docNode.createProcessingInstruction('xml-stylesheet', 'type="text/xsl" href="xml_style.xsl"');
            
            docNode.insertBefore(proc, docNode.getFirstChild());
            
            xmlwrite(obj.essFilePath, docNode);
        end;
        
        function [obj, issue]= validate(obj, fixIssues)
            
            function itIs = isProperNumber(inputString, mustBeInteger, minValue, allowedUnits)
                % check to see if the input value is a valid number. It can
                % have a unit too, e.g. 25 Hz or 25Hz
                
                if nargin < 2
                    mustBeInteger = false;
                end;
                
                if nargin < 3
                    minValue = -Inf;
                end;
                
                if nargin < 4
                    allowedUnits = {};
                end;
                
                inputString = strtrim(inputString);
                
                % separate the unit part
                
                allowedUnitsLenght = [];
                for iii=1:length(allowedUnits)
                    allowedUnitsLenght(iii) = length(allowedUnits{iii});
                end;
                
                % sort based on length so match first by the longest
                [dummy, ord] = sort(allowedUnitsLenght, 'descend'); %#ok<ASGLU>
                allowedUnits  = allowedUnits(ord);
                
                for iii=1:length(allowedUnits)
                    id = strfind(lower(inputString), lower(allowedUnits{iii}));
                    if ~isempty(id)
                        inputString = inputString(1:id-1);
                    end;
                end;
                
                asNumber = str2double(strtrim(inputString));
                if length(asNumber) > 1 || isnan(asNumber) || isempty(asNumber)
                    itIs = false;
                else
                    itIs = true;
                    
                    if asNumber < minValue
                        itIs = false;
                    end;
                    
                    if mustBeInteger && round(asNumber) ~= asNumber
                        itIs = false;
                    end;
                end;
                
            end
            
            if nargin < 2
                fixIssues = true;
            end;
            
            issue = []; % a structure with description and howItWasFixed fields.
            
            if ~level1Study.isAvailable(obj.studyTitle)
                issue(end+1).description = 'Study title is not available. This value is required.';
            end;
            
            if ~level1Study.isAvailable(obj.studyShortDescription)
                issue(end+1).description = 'Study Short Description is not available. This value is required.';
            elseif length(obj.studyShortDescription) > 120
                issue(end+1).description = 'Study Short Description is too long (over 120 characters).';
            end;
            
            if ~level1Study.isAvailable(obj.studyDescription)
                issue(end+1).description = 'Study Description is not available. This value is required.';
            end;
            
            if length(obj.studyUuid) < 10 % uuid shoudllbe at least 10 random characters
                issue(end+1).description = 'UUID is empty or less than 10 (random) characters.';
                if fixIssues
                    obj.studyUuid = ['studylevel1_' getUuid];
                    issue(end).howItWasFixed = 'A new UUID is set.';
                end;
            end;
            
            
            if ~level1Study.isAvailable(obj.rootURI) % rootURI shoudl be . or some other URI
                issue(end+1).description = 'root URI is not available.';
                
                if fixIssues
                    obj.rootURI = '.';
                    issue(end).howItWasFixed = 'Root URI is set to ''.'' .';
                end;
            end;
            
            % make sure there is at least one recording parameter set
            if isempty(obj.recordingParameterSet)
                issue(end+1).description = 'There has to be at least one Recording Parameter Set defined.';
            end;
            
            % make sure there is at least one contact (phone or email)
            if ~(level1Study.isAvailable(obj.contactInfo.name) || level1Study.isAvailable(obj.contactInfo.phone) || level1Study.isAvailable(obj.contactInfo.email))
                issue(end+1).description = 'There has to be at least some contact information available (name, phone or email)';
            end;
            
            % validate task information and find out how many tasks are present
            numberOfTasks = max(1, length(obj.tasksInfo));
            taskLabels = {};
            for i=1:length(obj.tasksInfo)
                taskLabels{end+1} = obj.tasksInfo(i).taskLabel;
                
                if ~level1Study.isAvailable(obj.tasksInfo(i).taskLabel)
                    issue(end+1).description = sprintf('Task label is not available for task %d.', i);
                end;
                
                if ~level1Study.isAvailable(obj.tasksInfo(i).description)
                    issue(end+1).description = sprintf('Task description is not available for task %d.', i);
                end;
            end;
            
            
            % validating recordingParameterSet
            listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation = {};
            if isempty(obj.recordingParameterSet)
                issue(end+1).description = sprintf('There is no recording parameter set defined. You need to at least have one of these to hold number of EEG channels, etc.');
            else
                for i=1:length(obj.recordingParameterSet)
                    if ~level1Study.isAvailable(obj.recordingParameterSet(i).recordingParameterSetLabel)
                        issue(end+1).description = sprintf('The label of recording parameter set %d is empty.', i);
                    end;
                    
                    if isempty(obj.recordingParameterSet(i).modality)
                        issue(end+1).description = sprintf('There are no modalities defined for recording parameter set %d (labeled ''%s'')', i, obj.recordingParameterSet(i).recordingParameterSetLabel);
                    else
                        startChannelForModalityNumber = {};
                        endChannelForModalityNumber = {};
                        for j=1:length(obj.recordingParameterSet(i).modality)
                            if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).type)
                                issue(end+1).description = sprintf('The type of modality %d of recording parameter set %d is empty.', j, i);
                            end;
                            
                            % we need sampling rate at least for EEG
                            if strcmpi(obj.recordingParameterSet(i).modality(j).type, 'EEG')
                                if ~isProperNumber(obj.recordingParameterSet(i).modality(j).samplingRate, false, 0, {'Hz' 'hz' 'HZ'})
                                    issue(end+1).description = sprintf('Sampling rate value of EEG (modality %d) in recording parameter set %d is empty or invalid (it is ''%s'').', j, i, obj.recordingParameterSet(i).modality(j).samplingRate);
                                end;
                                
                                % Reference location is needed for EEG
                                if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).referenceLocation)
                                    issue(end+1).description = sprintf('Reference location of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                                
                                % Channel Location Type is needed for EEG
                                if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).channelLocationType)
                                    issue(end+1).description = sprintf('Channel location type of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                else
                                    if ~ismember(lower(obj.recordingParameterSet(i).modality(j).channelLocationType), lower({'10-20', '10-10', '10-5', 'EGI', 'Custom'}))
                                        issue(end+1).description = sprintf('Invalid channel location type (%s) is specified for EEG (modality %d) in recording parameter set %d.\r Valid type are 10-20, 10-10, 10-5, EGI and Custom.', obj.recordingParameterSet(i).modality(j).channelLocationType, j, i);
                                    end;
                                    
                                    % make sure all the scalp labels match 10-20
                                    % labels if 10-20 montage is specified.
                                    listof10_20_labels = {'LPA', 'RPA', 'Nz', 'Fp1', 'Fpz', 'Fp2', 'AF9', 'AF7', 'AF5', 'AF3', 'AF1', 'AFz', 'AF2', 'AF4', 'AF6', 'AF8', 'AF10', 'F9', 'F7', 'F5', 'F3', 'F1', 'Fz', 'F2', 'F4', 'F6', 'F8', 'F10', 'FT9', 'FT7', 'FC5', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', 'FC6', 'FT8', 'FT10', 'T9', 'T7', 'C5', 'C3', 'C1', 'Cz', 'C2', 'C4', 'C6', 'T8', 'T10', 'TP9', 'TP7', 'CP5', 'CP3', 'CP1', 'CPz', 'CP2', 'CP4', 'CP6', 'TP8', 'TP10', 'P9', 'P7', 'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO9', 'PO7', 'PO5', 'PO3', 'PO1', 'POz', 'PO2', 'PO4', 'PO6', 'PO8', 'PO10', 'O1', 'Oz', 'O2', 'I1', 'Iz', 'I2', 'AFp9h', 'AFp7h', 'AFp5h', 'AFp3h', 'AFp1h', 'AFp2h', 'AFp4h', 'AFp6h', 'AFp8h', 'AFp10h', 'AFF9h', 'AFF7h', 'AFF5h', 'AFF3h', 'AFF1h', 'AFF2h', 'AFF4h', 'AFF6h', 'AFF8h', 'AFF10h', 'FFT9h', 'FFT7h', 'FFC5h', 'FFC3h', 'FFC1h', 'FFC2h', 'FFC4h', 'FFC6h', 'FFT8h', 'FFT10h', 'FTT9h', 'FTT7h', 'FCC5h', 'FCC3h', 'FCC1h', 'FCC2h', 'FCC4h', 'FCC6h', 'FTT8h', 'FTT10h', 'TTP9h', 'TTP7h', 'CCP5h', 'CCP3h', 'CCP1h', 'CCP2h', 'CCP4h', 'CCP6h', 'TTP8h', 'TTP10h', 'TPP9h', 'TPP7h', 'CPP5h', 'CPP3h', 'CPP1h', 'CPP2h', 'CPP4h', 'CPP6h', 'TPP8h', 'TPP10h', 'PPO9h', 'PPO7h', 'PPO5h', 'PPO3h', 'PPO1h', 'PPO2h', 'PPO4h', 'PPO6h', 'PPO8h', 'PPO10h', 'POO9h', 'POO7h', 'POO5h', 'POO3h', 'POO1h', 'POO2h', 'POO4h', 'POO6h', 'POO8h', 'POO10h', 'OI1h', 'OI2h', 'Fp1h', 'Fp2h', 'AF9h', 'AF7h', 'AF5h', 'AF3h', 'AF1h', 'AF2h', 'AF4h', 'AF6h', 'AF8h', 'AF10h', 'F9h', 'F7h', 'F5h', 'F3h', 'F1h', 'F2h', 'F4h', 'F6h', 'F8h', 'F10h', 'FT9h', 'FT7h', 'FC5h', 'FC3h', 'FC1h', 'FC2h', 'FC4h', 'FC6h', 'FT8h', 'FT10h', 'T9h', 'T7h', 'C5h', 'C3h', 'C1h', 'C2h', 'C4h', 'C6h', 'T8h', 'T10h', 'TP9h', 'TP7h', 'CP5h', 'CP3h', 'CP1h', 'CP2h', 'CP4h', 'CP6h', 'TP8h', 'TP10h', 'P9h', 'P7h', 'P5h', 'P3h', 'P1h', 'P2h', 'P4h', 'P6h', 'P8h', 'P10h', 'PO9h', 'PO7h', 'PO5h', 'PO3h', 'PO1h', 'PO2h', 'PO4h', 'PO6h', 'PO8h', 'PO10h', 'O1h', 'O2h', 'I1h', 'I2h', 'AFp9', 'AFp7', 'AFp5', 'AFp3', 'AFp1', 'AFpz', 'AFp2', 'AFp4', 'AFp6', 'AFp8', 'AFp10', 'AFF9', 'AFF7', 'AFF5', 'AFF3', 'AFF1', 'AFFz', 'AFF2', 'AFF4', 'AFF6', 'AFF8', 'AFF10', 'FFT9', 'FFT7', 'FFC5', 'FFC3', 'FFC1', 'FFCz', 'FFC2', 'FFC4', 'FFC6', 'FFT8', 'FFT10', 'FTT9', 'FTT7', 'FCC5', 'FCC3', 'FCC1', 'FCCz', 'FCC2', 'FCC4', 'FCC6', 'FTT8', 'FTT10', 'TTP9', 'TTP7', 'CCP5', 'CCP3', 'CCP1', 'CCPz', 'CCP2', 'CCP4', 'CCP6', 'TTP8', 'TTP10', 'TPP9', 'TPP7', 'CPP5', 'CPP3', 'CPP1', 'CPPz', 'CPP2', 'CPP4', 'CPP6', 'TPP8', 'TPP10', 'PPO9', 'PPO7', 'PPO5', 'PPO3', 'PPO1', 'PPOz', 'PPO2', 'PPO4', 'PPO6', 'PPO8', 'PPO10', 'POO9', 'POO7', 'POO5', 'POO3', 'POO1', 'POOz', 'POO2', 'POO4', 'POO6', 'POO8', 'POO10', 'OI1', 'OIz', 'OI2', 'T3', 'T5', 'T4', 'T6', 'M1', 'M2', 'A1', 'A2'};
                                    if strcmp(obj.recordingParameterSet(i).modality(j).channelLocationType, '10-20')
                                        channelLabel = strsplit(obj.recordingParameterSet(i).modality(j).channelLabel,',');
                                        channelLabel = lower(strtrim(channelLabel));
                                        
                                        nonScalpChannelLabel = strsplit(obj.recordingParameterSet(i).modality(j).nonScalpChannelLabel, ',');
                                        nonScalpChannelLabel = lower(strtrim(nonScalpChannelLabel));
                                        
                                        scalpLabel = setdiff(channelLabel, nonScalpChannelLabel);
                                        unknownLabel = setdiff(scalpLabel, lower(listof10_20_labels));
                                        
                                        if ~isempty(unknownLabel)
                                            fprintf('Channel labels (%s) \n specified for EEG with 10-20 montage (modality %d) in recording parameter set %d \n do not follow conventional 10-20 montage names.', strjoin_adjoiner_first(',', unknownLabel), j, i);
                                        end;
                                    end;
                                    
                                    
                                    if strcmpi('custom', obj.recordingParameterSet(i).modality(j).channelLocationType)
                                        listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation(end+1) = {obj.recordingParameterSet(i).recordingParameterSetLabel};
                                    end;
                                end;
                                
                                % Channel labels are needed for EEG
                                if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).channelLabel)
                                    issue(end+1).description = sprintf('Channel labels of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                                
                                % Non-scalp channel labels are needed for
                                % EEG
                                if isempty(strtrim(obj.recordingParameterSet(i).modality(j).nonScalpChannelLabel))
                                    issue(end+1).description = sprintf('Non-scalp channel labels of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                            end;
                            
                            % start channel
                            if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).startChannel)
                                issue(end+1).description = sprintf('Start channel of modality %d of recording parameter set %d is empty.', j, i);
                                startChannel = [];
                            else
                                startChannel = str2double(obj.recordingParameterSet(i).modality(j).startChannel);
                            end;
                            
                            % end channel
                            if ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).endChannel)
                                issue(end+1).description = sprintf('End channel of modality %d of recording parameter set %d is empty.', j, i);
                                endChannel = [];
                            else
                                endChannel = str2double(obj.recordingParameterSet(i).modality(j).endChannel);
                            end;
                            
                            startChannelForModalityNumber{j} = startChannel;
                            endChannelForModalityNumber{j} = endChannel;
                            
                            % number of channel labels provided must be either zero or match
                            % the number specified by startChannel and
                            % endChannel
                            channelLabel = strsplit(obj.recordingParameterSet(i).modality(j).channelLabel,',');
                            expectedNumberOfChannels = (endChannel - startChannel + 1);
                            if ~(isempty(startChannel) || isempty(endChannel)) && length(channelLabel) ~= expectedNumberOfChannels
                                issue(end+1).description = sprintf('Number of channel labels (%d) of modality %d of recording parameter set %d does not match number of channel expected (%d) from startChannel and endChannel values.', length(channelLabel), j, i, expectedNumberOfChannels);
                            end;
                            
                            % we need a description when data type is not any of
                            % EEG, Mocap, or Gaze
                            
                            if ~ismember(lower(obj.recordingParameterSet(i).modality(j).type), {'eeg', 'mocap', 'gaze'}) ...
                                    && ~level1Study.isAvailable(obj.recordingParameterSet(i).modality(j).description)
                                issue(end+1).description = sprintf('Description is missing for type %s in modality %d of recording parameter set %d. \n     A description is required for any type other than EEG, Mocap and Gaze.', obj.recordingParameterSet(i).modality(j).type, j, i);
                            end;
                            
                        end;
                        
                        % make sure each channel is associated with exactly
                        % one modality
                        
                        % make sure each channel at least has one
                        % modality
                        channelsForWhichAModalityIsDefined = [];
                        for j=1:length(startChannelForModalityNumber)
                            channelsForWhichAModalityIsDefined = cat(2, channelsForWhichAModalityIsDefined, startChannelForModalityNumber{j}:endChannelForModalityNumber{j});
                        end;
                        channelsWithNoModality = setdiff(1:max(channelsForWhichAModalityIsDefined), channelsForWhichAModalityIsDefined);
                        if ~isempty(channelsWithNoModality)
                            issue(end+1).description = sprintf('No modality is defined for channels (%s) in recording parameter set %d.', num2str(channelsWithNoModality), i);
                        end;
                        
                        % write code to detect overlapping channel
                        % modalities
                        for j=1:length(startChannelForModalityNumber)
                            for k=(j+1):length(startChannelForModalityNumber)
                                channelsForModalityA = startChannelForModalityNumber{j}:endChannelForModalityNumber{j};
                                channelsForModalityB = startChannelForModalityNumber{k}:endChannelForModalityNumber{k};
                                overlapChannels = intersect(channelsForModalityA, channelsForModalityB);
                                
                                if ~isempty(overlapChannels)
                                    issue(end+1).description = sprintf('Modalities %d and %d of parameter set %d both claim channels %s. Each channel can only be associated with one modality.', j, k, i, num2str(overlapChannels));
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            
            
            % validate session values
            sessionNumbers = [];
            for i=1:length(obj.sessionTaskInfo)
                sessionNumber  = str2double(obj.sessionTaskInfo(i).sessionNumber);
                % session numbers must be an integer number
                if isnan(sessionNumber) || round(sessionNumber) ~= sessionNumber || sessionNumber < 1
                    issue(end+1).description = sprintf('session number in sessionTaskInfo(%d).sessionNumber is not a positive integer.', i); %#ok<AGROW>
                else
                    sessionNumbers = [sessionNumbers sessionNumber];
                end;
                
                % if channel location type is specified as Custom (versus e.g. 10-20)
                % for a recording, and it is not a ,set file (which might have the locations inside it)
                % each subject has to have a channel location file.
                eegChannelLocationFileIsNeeded = false;
                for rcordingCounter=1:length(obj.sessionTaskInfo(i).dataRecording)
                    [dummy1, dummy2, ext] = fileparts(obj.sessionTaskInfo(i).dataRecording(rcordingCounter).filename); %#ok<ASGLU>
                    if ismember(obj.sessionTaskInfo(i).dataRecording(rcordingCounter).recordingParameterSetLabel, listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation) && ...
                            ~strcmpi(ext, '.set')
                        eegChannelLocationFileIsNeeded = true;
                    end;
                end;
                
                % validate subject existence
                if isempty(obj.sessionTaskInfo(i).subject)
                    issue(end+1).description = sprintf('Session %s does not have any subjects.', obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                else % check if inSessionNumber is set for all subejcts in the session
                    for j=1:length(obj.sessionTaskInfo(i).subject)
                        
                        if ~level1Study.isAvailable(obj.sessionTaskInfo(i).subject(j).inSessionNumber)
                            issue(end+1).description =  sprintf('Subject %d of session %s does not an inSessionNumber.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            
                            if fixIssues && length(obj.sessionTaskInfo(i).subject) == 1
                                issue(end).howItWasFixed = 'inSessionNumber was assigned to 1';
                            end;
                        end;
                        
                        if ~isfield(obj.sessionTaskInfo(i).subject(j), 'labId')
                            issue(end+1).description =  sprintf('Subject %d of session %s does not have a labId field.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            
                            if fixIssues && length(obj.sessionTaskInfo(i).subject) == 1
                                obj.sessionTaskInfo(i).subject(j).labId = 'NA';
                                issue(end).howItWasFixed = 'labId field created and set to NA';
                            end;
                        end;
                        
                        if isfield(obj.sessionTaskInfo(i).subject(j), 'height') && (~isempty(strfind(obj.sessionTaskInfo(i).subject(j).height, '''')) || ~isempty(strfind(obj.sessionTaskInfo(i).subject(j).height, '"')))
                            issue(end+1).description =  sprintf('Subject %d of session %s has a ''height'' field that seems to be in feet and inches (instead of centimeters).', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>                                                        
                        end;
                        
                        
                        
                        % check the existence of referred channel locations
                        % and make sure they are specified if channel
                        % location type is specified as Custom (versus e.g. 10-20).
                        if eegChannelLocationFileIsNeeded && (isempty(obj.sessionTaskInfo(i).subject(j).channelLocations)...
                                || strcmpi('NA', obj.sessionTaskInfo(i).subject(j).channelLocations))
                            issue(end+1).description =  sprintf('Subject %d of session %s does not have a channelLocations while \r its channelLocationType is defined as ''custom''.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        end;
                        
                        % check if the channel location file actually
                        % exists.
                        if level1Study.isAvailable(obj.sessionTaskInfo(i).subject(j).channelLocations)
                            allSearchFolders = getSessionFileSearchFolders(obj, sessionNumber);
                            
                            fileFound = false;
                            searchFullPath = {};
                            for z = 1:length(allSearchFolders)
                                searchFullPath{z} = [allSearchFolders{z} filesep obj.sessionTaskInfo(i).subject(j).channelLocations];
                                if exist(searchFullPath{z}, 'file')
                                    fileFound = true;
                                end;
                            end;
                            
                            if ~fileFound
                                issue(end+1).description =  sprintf('Channel location file recording of subject %d of session number %s cannot be found \r at any of these locations: %s .', j, obj.sessionTaskInfo(i).sessionNumber, strjoin_adjoiner_first(', ', searchFullPath)); %#ok<AGROW>
                                issue(end).issueType = 'missing file';
                            end;
                            
                        end;
                        
                    end;
                end;
                
                % validate the existence of valid data recordings for the session
                if isempty(obj.sessionTaskInfo(i).dataRecording)
                    issue(end+1).description = sprintf('session %s does not have any data recording.', obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                else
                    for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                        
                        % check filename
                        if ~level1Study.isAvailable(obj.sessionTaskInfo(i).dataRecording(j).filename)
                            issue(end+1).description =  sprintf('Data recording %d of session number %s does not have a filename.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        else % file has to be found according to ESS convention
                            
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber); %#ok<ASGLU>
                            
                            nextToXMLFilePath = [nextToXMLFolder filesep obj.sessionTaskInfo(i).dataRecording(j).filename];
                            fullEssFilePath = [fullEssFolder filesep obj.sessionTaskInfo(i).dataRecording(j).filename];
                            
                            if ~(exist(fullEssFilePath, 'file') || exist(nextToXMLFilePath, 'file'))
                                issue(end+1).description = [sprintf('File specified for data recording %d of session number %s does not exist, \r         i.e. cannot find either %s or %s', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath)  '.'];
                                issue(end).issueType = 'missing file';
                                
                            else % if file exists, check if its adheres to ESS naming convention
                                subjectInSessionNumber = obj.getInSessionNumberForDataRecording(obj.sessionTaskInfo(i).dataRecording(j));
                                [dataRecordingModalities, dataRecordingModalityString]= obj.getModalitiesForDataRecording(i, j); %#ok<ASGLU>
                                if ~level1Study.fileNameMatchesEssConvention(obj.sessionTaskInfo(i).dataRecording(j).filename, dataRecordingModalityString, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                        subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject))
                                    fprintf('Warning: Filename %s (data recording %d of session number %s) does not follow ESS convention.\n', obj.sessionTaskInfo(i).dataRecording(j).filename, j, obj.sessionTaskInfo(i).sessionNumber);
                                end;
                            end
                        end;
                        
                        
                        % check dataRecordingUuid
                        if ~level1Study.isAvailable(obj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid)
                            issue(end+1).description =  sprintf('Data recording %d of session number %s does not have a UUID in dataRecordingUuid.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            obj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid = ['datarecording_' getUuid];
                            issue(end).howItWasFixed = 'UUID placed into the field.';
                        end;
                        
                        % check eventInstanceFile (only if in ESS
                        % Container and EEG type)
                        dataRecordingModalities = lower(obj.getModalitiesForDataRecording(i,j));
                        if ismember('eeg', dataRecordingModalities) && ~level1Study.isAvailable(obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile)
                            if strcmpi(strtrim(obj.isInEssContainer), 'yes')
                                issue(end+1).description =  sprintf('Data recording %d of session number %s does not have an event instance file.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                                obj = obj.recreateEventInstanceFiles(false, i);
                                issue(end).howItWasFixed = 'Event instance file created.';
                            end;
                        else % file has to be found according to ESS convention
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber); %#ok<ASGLU>
                            
                            nextToXMLFilePath = [nextToXMLFolder filesep obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile];
                            fullEssFilePath = [fullEssFolder filesep obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile];
                            
                            if ~(exist(fullEssFilePath, 'file') || exist(nextToXMLFilePath, 'file'))
                                issue(end+1).description = [sprintf('Event Instance file specified for data recording %d of session number %s does not exist, \r         i.e. cannot find either %s or %s', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath)  '.'];
                                issue(end).issueType = 'missing file';
                                try
                                    obj = obj.recreateEventInstanceFiles(false, i);
                                    issue(end).howItWasFixed = 'Event instance file created.';
                                catch e
                                end;
                            end;
                        end;
                        
                        % check startDateTime to be in ISO 8601 format
                        dateTime = strtrim(obj.sessionTaskInfo(i).dataRecording(j).startDateTime);
                        if isempty(dateTime) || (level1Study.isAvailable(dateTime) && isempty(datenum8601(dateTime)))
                            issue(end+1).description =  sprintf('startDateTime specified in data recording %d of session number %s does not have a valid ISO 8601 Date String.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            
                            dateTimeIso8601 = [];
                            try
                                dateNumber = datenum(dateTime);
                                dateTimeIso8601 = datestr(dateNumber);
                            catch e %#ok<NASGU>
                            end;
                            
                            if ~isempty(dateTimeIso8601)
                                issue(end).howItWasFixed = [dateTime ' changed to ' dateTimeIso8601];
                            end;
                            
                        end;
                        
                        % make sure a valid recordingParameterSetLabel is assigned
                        % for each recording
                        if ~level1Study.isAvailable(obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel)
                            issue(end+1).description =  sprintf('Data recording %d of session number %s does not have a ''recording parameter set'' Label.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        else % file has to be found according to ESS convention
                            % check to see if the label matches any of the
                            % labels in recordingParameterSet
                            matchFound = false;
                            for k=1:length(obj.recordingParameterSet)
                                if strcmpi(obj.recordingParameterSet(k).recordingParameterSetLabel, obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel)
                                    matchFound = true;
                                    break;
                                end;
                            end;
                            
                            if ~matchFound
                                issue(end+1).description = sprintf('Recording parameter set label ''%s'' defined in Data recording %d of session number %s does not match any labels in recordingParameterSet', obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel, j, obj.sessionTaskInfo(i).sessionNumber );
                            end;
                            
                        end;
                        
                    end;
                end;
                
                
                % validate the task label in the session
                if numberOfTasks > 1 && ~level1Study.isAvailable(obj.sessionTaskInfo(i).taskLabel)
                    issue(end+1).description = sprintf('The study has more than one task but the task label is not available for session number %d', i);
                else
                    if ~ismember(obj.sessionTaskInfo(i).taskLabel, taskLabels)
                        issue(end+1).description = sprintf('The task label %s in session number %d does not match defined tasks.', obj.sessionTaskInfo(i).taskLabel, i);
                    end;
                end;
                
            end;
            
            % check to see if session numbers are from 1:N (no missing
            % numbers)
            missingSessionNumber = setdiff(1:max(sessionNumbers), unique(sessionNumbers));
            if ~isempty(missingSessionNumber)
                issue(end+1).description = sprintf('Some session numbers are missing. These numbers have to be from 1 up to the number of sessions.\n Here are the missing numbers: %s.', num2str(missingSessionNumber));
            end;
            
            if ~level1Study.isAvailable(obj.eventSpecificationMethod) || ~ismember(strtrim(lower(obj.eventSpecificationMethod)), {'codes', 'tags'})
                issue(end+1).description = sprintf('eventSpecificationMethod node is empty or invalid. It has to be either ''Codes'' or ''Tags''.');
            end;
            
            if ~level1Study.isAvailable(obj.isInEssContainer) || ~ismember(strtrim(lower(obj.isInEssContainer)), {'yes', 'no'})
                issue(end+1).description = sprintf('isInEssContainer node is empty or invalid. It has to be either ''Yes'' or ''No''.');
            end;
            
            % only check the validity of event codes when they are the
            % primary source of event information.
            if strcmpi(strtrim(obj.eventSpecificationMethod), 'codes')
                
                if isempty(obj.eventCodesInfo)
                    issue(end+1).description = sprintf('No event code information is provided.');
                else
                    for i=1:length(obj.eventCodesInfo)
                        if ~level1Study.isAvailable(obj.eventCodesInfo(i).code)
                            issue(end+1).description = sprintf('Event code for record %d is missing.', i);
                        end;
                        
                        % conformity with tasks
                        if numberOfTasks > 1 && ~level1Study.isAvailable(obj.eventCodesInfo(i).taskLabel)
                            issue(end+1).description = sprintf('The study has more than one task but there is no task label defined for event code %s in record %d.', obj.eventCodesInfo(i).code, i);
                        end;
                        
                        if numberOfTasks == 1 && ~level1Study.isAvailable(obj.eventCodesInfo(i).taskLabel)
                            issue(end+1).description = sprintf('Event code %s in record %d has an empty task.', obj.eventCodesInfo(i).code, i);
                            if isempty(obj.tasksInfo(1).taskLabel)
                                obj.tasksInfo(1).taskLabel = 'main';
                            end;
                            obj.eventCodesInfo(i).taskLabel = obj.tasksInfo(1).taskLabel;
                            issue(end).howItWasFixed = sprintf('Event code task was assigned to the only task available (''%s'').', obj.tasksInfo(1).taskLabel);
                        end;
                        
                        if level1Study.isAvailable(obj.eventCodesInfo(i).taskLabel) && ~ismember(lower(obj.eventCodesInfo(i).taskLabel), lower(taskLabels))
                            issue(end+1).description = sprintf('Task label %s defined for event code ''%s'' in record %d does not have any corresponding task definition.', obj.eventCodesInfo(i).taskLabel, obj.eventCodesInfo(i).code, i);
                        end;
                        
                        % event instance count missing
                        if ~level1Study.isAvailable(obj.eventCodesInfo(i).numberOfInstances)
                            issue(end+1).description = sprintf('Number of event instances for Task label ''%s'', Event ''%s'' was missing.', obj.eventCodesInfo(i).taskLabel, obj.eventCodesInfo(i).code);
                            obj = obj.updateEventNumberOfInstances;
                            issue(end).howItWasFixed = sprintf('All event instance counts recomputed.');
                        end;
                        
                        if isempty(obj.eventCodesInfo(i).condition)
                            issue(end+1).description = sprintf('Condition information is missing for event code ''%s'' in record %d.', obj.eventCodesInfo(i).code, i);
                        else
                            for j=1:length(obj.eventCodesInfo(i).condition)
                                if ~(level1Study.isAvailable(obj.eventCodesInfo(i).condition(j).label) || level1Study.isAvailable(obj.eventCodesInfo(i).condition(j).description) || level1Study.isAvailable(obj.eventCodesInfo(i).condition(j).tag))
                                    issue(end+1).description = sprintf('Condition information is missing for condition %d of event code %s in record %d.', obj.eventCodesInfo(i).code, j, i);
                                end;
                            end;
                        end;
                        
                    end;
                    
                    if ~level1Study.isAvailable(obj.summaryInfo.allSubjectsHealthyAndNormal)
                        issue(end+1).description = sprintf('You need to specify whether all subjects are healthy and normal in the Summary Information');
                    else
                        if ~ismember(lower(obj.summaryInfo.allSubjectsHealthyAndNormal), {'yes', 'no'})
                            issue(end+1).description = sprintf('The value of allSubjectsHealthyAndNormal has to be either ''Yes'' or ''No''.');
                            if fixIssues && ismember(lower(obj.summaryInfo.allSubjectsHealthyAndNormal), {'y', 'n', 'true', 'false', 't', 'f'})
                                originalValue = obj.summaryInfo.allSubjectsHealthyAndNormal;
                                switch lower(obj.summaryInfo.allSubjectsHealthyAndNormal)
                                    case {'y', 'true', 't'}
                                        obj.summaryInfo.allSubjectsHealthyAndNormal = 'Yes';
                                    case {'n', 'false', 'f'}
                                        obj.summaryInfo.allSubjectsHealthyAndNormal = 'No';
                                end;
                                
                                issue(end).howItWasFixed = [originalValue ' interpreted as ' obj.summaryInfo.allSubjectsHealthyAndNormal ' and placed in the field.'];
                            end;
                        end;
                    end;
                    
                    if strcmpi(obj.isInEssContainer, 'Yes') && (~level1Study.isAvailable(obj.summaryInfo.totalSize) || ~isProperNumber(obj.summaryInfo.totalSize, false, 0, {'Mb' 'GB' 'Gbytes' 'giga bytes' 'gbs' 'bytes' 'KB' 'kilo bytes' 'kilo byte' 'byte' 'kbs'}))
                        issue(end+1).description = sprintf('Total Size value specified in Summary Information is missing or not valid.');
                    end;
                    
                end;
            end;
            
            if strcmpi(obj.isInEssContainer, 'Yes')
                essPath = fileparts(obj.essFilePath);
                if ~exist([essPath filesep 'manifest.js'], 'file')
                    issue(end+1).description = 'manifest.js file was missing.';
                    if fixIssues                        
                        obj.copyJSONReportAssets(fileparts(obj.essFilePath));
                        obj.writeJSONP(fileparts(obj.essFilePath));
                        issue(end).howItWasFixed = 'manifest.js file created.';
                    end;
                end;
            end
            
            % validate event HED tags
            w = which('validateCellTags.m');
            if isempty(w)
                fprintf('Unable to validate HED tags since HEDTools cannot be found. \n Please add it to the path. It can be downloaded from https://github.com/VisLab/HEDTools \n');
            else
                
                
                for i=1:length(obj.eventCodesInfo)
                    try
                        errors = validatecell({obj.eventCodesInfo(i).condition.tag});
                    catch err
                        fprintf('Encountered error \n%s\n while trying to validate the HED tag %s.\n', err.message, obj.eventCodesInfo(i).condition.tag);
                    end;
                    if ~isempty(errors)
                        errors{1} = strrep(errors{1}, 'Errors in cell 1:', '');
                        issue(end+1).description = [sprintf('HED tag error in event code "%s" of task "%s" (record %d): ', obj.eventCodesInfo(i).code, obj.eventCodesInfo(i).taskLabel, i) errors{1}];
                    end;
                end;
            end;
            
            % end of validation test, now showing the potential issues.
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
        
        function obj = sortDataRecordingsByStartTime(obj)
            % sort data recordings according to their startDateTime
            for i = 1:length(obj.sessionTaskInfo)
                serialDateNumber = [];
                for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                    serialDateNumberForRecording = datenum8601(obj.sessionTaskInfo(i).dataRecording(j).startDateTime);
                    if isempty(serialDateNumberForRecording)
                        serialDateNumberForRecording = 0; % assume it is the earliest
                    end;
                    serialDateNumber(j) = serialDateNumberForRecording;
                end;
                
                [dummy, ord] = sort(serialDateNumber, 'ascend'); %#ok<ASGLU>
                obj.sessionTaskInfo(i).dataRecording = obj.sessionTaskInfo(i).dataRecording(ord);
            end;
        end;
        
        function obj = writeEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber, filePath, outputFileName, overwriteFile)
            % obj = writeEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber, filePath, fileName, overwriteFile)
            
            if nargin < 6
                overwriteFile = false;
            end;
            
            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, obj.sessionTaskInfo(sessionTaskNumber).sessionNumber); %#ok<ASGLU>
            
            if nargin < 4 || isempty(filePath) % use the ESS convention folder location if none is provided.
                filePath = fullEssFolder;
                
                if ~exist(fullEssFolder, 'dir')
                    mkdir(fullEssFolder);
                end;
            end;
            
            if nargin < 5 % use ESS convention event instance file if no filename is provided.
                % form subjectInSessionNumber
                id = strcmpi(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).recordingParameterSetLabel, {obj.recordingParameterSet.recordingParameterSetLabel});
                subjectInSessionNumberCell = setdiff(unique({obj.recordingParameterSet(id).modality.subjectInSessionNumber}), {'', '-', 'NA'});
                subjectInSessionNumber = strjoin_adjoiner_first('_', subjectInSessionNumberCell);
                
                % toDo: make this work correctly for two subjects.
                outputFileName = obj.essConventionFileName('event', obj.studyTitle, obj.sessionTaskInfo(sessionTaskNumber).sessionNumber,...
                    subjectInSessionNumber, obj.sessionTaskInfo(sessionTaskNumber).taskLabel, dataRecordingNumber, getSubjectLabbIdForDataRecording(obj, sessionTaskNumber, dataRecordingNumber), length(obj.sessionTaskInfo(sessionTaskNumber).subject));
            end;
            
            fullFilePath = [filePath filesep outputFileName];
            fileFound = false;
            if exist(fullFilePath, 'file') && ~overwriteFile
                fprintf('Skipped writing event instance file %s since it already exists.\n'); %#ok<CTPCT>
            else
                
                EEG = [];
                for i=1:length(allSearchFolders)
                    if isempty(EEG)
                        try
                            % only read a single channel since we only care
                            % about events at this point.
                            combinedPathAndName = [allSearchFolders{i} filesep obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).filename];
                            fileFound = fileFound | exist(combinedPathAndName, 'file');
                            EEG = exp_eval(io_loadset(combinedPathAndName));
                        catch
                            
                            if fileFound && strcmpi(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).filename((end-3):end), '.set')
                                try
                                    EEG = pop_loadset(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).filename, allSearchFolders{i});
                                catch
                                end;
                            end;
                        end;
                    end;
                end;
                
                
                
                if ~fileFound
                    error('EEG file for data recording %d of session task %d cannot be found.', dataRecordingNumber, sessionTaskNumber);
                end;
                
                if fileFound && isempty(EEG)
                    error('EEG file for data recording %d of session task %d was found but could not be read. \nYou might be missing the required EEGLAB plugin.', dataRecordingNumber, sessionTaskNumber);
                end;
                
                % we do not need the data, so lets free up its memory
                EEG.data = [];
                
                studyEventCode = {obj.eventCodesInfo.code};
                studyEventCodeTaskLabel = {obj.eventCodesInfo.taskLabel};
                
                
                studyEventCodeHedString = {};
                for i = 1:length(obj.eventCodesInfo)
                    studyEventCodeHedString{i} = obj.eventCodesInfo(i).condition.tag;
                    
                    % add tags for label and description if they do not already exist
                    hedTags = strtrim(strsplit(studyEventCodeHedString{i}, ','));
                    labelTagExists = strfind(lower(hedTags), 'event/label/');
                    descriptionTagExists = strfind(lower(hedTags), 'event/description/');
                    
                    if all(cellfun(@isempty, labelTagExists))
                        studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Label/' obj.eventCodesInfo(i).condition.label];
                    end;
                    
                    if all(cellfun(@isempty, descriptionTagExists))
                        studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Description/' obj.eventCodesInfo(i).condition.description];
                    end;
                    
                end;
                
                currentTask = obj.sessionTaskInfo(sessionTaskNumber).taskLabel;
                currentTaskMask = strcmp(currentTask, studyEventCodeTaskLabel);
                
                
                eventType = {};
                eventInstanceHedTags = {};
                for i=1:length(EEG.event)
                    type = EEG.event(i).type;
                    if isnumeric(type)
                        type = num2str(type);
                    end;
                    eventType{i} = type;
                    eventLatency(i) = (EEG.event(i).latency - 1)/ EEG.srate; % -1 since time starts from 0
                    
                    % extract per-instance HED tags if they exist
                    if isfield(EEG.event(i), 'hedtags')
                        eventInstanceHedTags{i} = EEG.event(i).hedtags;
                    else
                        eventInstanceHedTags{i} = '';
                    end;
                    
                    eventUsertags = '';
                    
                    if isfield(EEG.event, 'usertags')
                        eventUsertags = EEG.event(i).usertags;
                        if iscell(eventUsertags)
                            eventUsertags = strtrim(strjoin_adjoiner_first(', ', eventUsertags));
                        end;
                    end;
                    
                    id = currentTaskMask & strcmp(eventType{i}, studyEventCode);
                    if any(id)
                        eventHedString{i} = studyEventCodeHedString{id};
                    else
                        eventHedString{i} = '';
                    end;
                    
                    % if tags cannot be deduced from the XML, use usertags.
                    if isempty(strtrim(eventHedString{i}))
                        eventHedString{i} = eventUsertags;
                    end;
                    
                    % add per-instance hed tags in .hedtags field to eventHedString
                    if ~isempty(eventInstanceHedTags{i})
                        if isempty(eventHedString{i})
                            eventHedString{i} = eventInstanceHedTags{i};
                        else
                            eventHedString{i} = [eventHedString{i} ', ' eventInstanceHedTags{i}];
                        end;
                    end;
                end;
                
                % remove events with nan latency
                eventType = eventType(~isnan(eventLatency));
                eventHedString = eventHedString(~isnan(eventLatency));
                eventLatency = eventLatency(~isnan(eventLatency));
                
                fid = fopen(fullFilePath, 'w');
                for i=1:length(eventType)
                    fprintf(fid, '%s\t%s\t%s', eventType{i}, num2str(eventLatency(i)), eventHedString{i});
                    
                    if i<length(eventType)
                        fprintf(fid, '\n');
                    end;
                end;
                
                fclose(fid);
            end;
            
            [pathstr,name,ext]  = fileparts(fullFilePath); %#ok<ASGLU>
            obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile = [name ext];
        end;
        
        function [eventCode, eventLatency, eventHEDString] = readEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber)
            % [eventCode eventLatency eventHEDString] = readEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber)
            
            allSearchFolders = obj.getSessionFileSearchFolders(obj.sessionTaskInfo(sessionTaskNumber).sessionNumber);
            
            for i=1:length(allSearchFolders)
                for performSanitization = 0:1
                    
                    if performSanitization
                        eventFilename = strrep(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile, ':', '%3A');
                    else
                        eventFilename = obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile;
                    end;
                    
                    eventFilePath = [allSearchFolders{i} filesep eventFilename];
                    
                    if exist(eventFilePath, 'file')
                        break;
                    end;
                end;
                
                if exist(eventFilePath, 'file')
                    break;
                end;
            end;
            
            fid=fopen(eventFilePath);
            eventCode = {};
            eventLatency = [];
            eventHEDString = {};
            while 1
                tline = fgetl(fid);
                if ~ischar(tline), break, end
                parts = strsplit(tline, sprintf('\t'));
                eventCode(end+1) = parts(1);
                eventLatency(end+1) = str2double(parts{2});
                eventHEDString(end+1) = parts(3);
            end
            fclose(fid);
        end;
        
        function [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber)
            % look both next to the ESS file and in the ESS
            % convention location for data recoording and event instance
            % files.
            
            if isnumeric(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            essFileFolder = fileparts(obj.essFilePath);
            
            if isempty(obj.rootURI)
                rootFolder = essFileFolder;
            elseif obj.rootURI(1) == '.'
                rootFolder = [essFileFolder filesep obj.rootURI(2:end)];
            else % the path is not relative, i.e. does not start with .,  but is absolute
                rootFolder = obj.rootURI;
            end;
            
            % look both next to the ESS file and in the ESS
            % convention location for data recoording
            % files.
            nextToXMLFolder = rootFolder;
            fullEssFolder = [rootFolder filesep 'session' filesep sessionNumber];
            
            allSearchFolders = {nextToXMLFolder fullEssFolder};
        end;
        
        function obj = createEssContainerFolder(obj, essFolder, stopOnIssues, overwriteFiles)
            
            if nargin < 3
                stopOnIssues = true;
            end;
            
            if nargin < 4
                overwriteFiles = true;
            end;
            
            [obj, issue]= obj.validate; % fix solvable issues, like missing UUIDs;.
            
            % stop and generate an error here if there are outstanding
            % issues.
            if stopOnIssues
                for i =1:length(issue)
                    if isempty(issue(i).howItWasFixed)
                        error('There are still oustanding issues. You must fix them before placing the study in an ESS container');
                    end;
                end;
            end;
            
            mkdir(essFolder);
            mkdir([essFolder filesep 'session']);
            mkdir([essFolder filesep 'additional_documentation']);
            
            % find the number of session from number of sessionTasks
            sessionNumber = {obj.sessionTaskInfo.sessionNumber};
            uniqueSessionNumber = unique(sessionNumber);
            for i=1:length(uniqueSessionNumber)
                mkdir([essFolder filesep 'session' filesep uniqueSessionNumber{i}]);
            end;
            
            % copy and rename the data recording files
            essFileFolder = fileparts(obj.essFilePath);
            
            if isempty(obj.rootURI)
                rootFolder = essFileFolder;
            elseif obj.rootURI(1) == '.'
                rootFolder = [essFileFolder filesep obj.rootURI(2:end)];
            else % if the path is absolute and does not have an . in the beginnning
                rootFolder = obj.rootURI;
            end;
            
            obj = sortDataRecordingsByStartTime(obj);
            
            for i = 1:length(obj.sessionTaskInfo)
                fprintf('\nCopying files for session-task %d of %d (%d percent done).\n',i, length(obj.sessionTaskInfo), round(100*i/length(obj.sessionTaskInfo)));
                
                for j=1:length(obj.sessionTaskInfo(i).subject)
                    fileNameFromObj = obj.sessionTaskInfo(i).subject(j).channelLocations;
                    if ~(strcmpi(fileNameFromObj, 'na') || isempty(fileNameFromObj))
                        
                        nextToXMLFilePath = [rootFolder filesep fileNameFromObj];
                        fullEssFilePath = [rootFolder filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObj];
                        
                        if ~isempty(fileNameFromObj) && exist(fullEssFilePath, 'file')
                            fileFinalPath = fullEssFilePath;
                        elseif ~isempty(fileNameFromObj) && exist(nextToXMLFilePath, 'file')
                            fileFinalPath = nextToXMLFilePath;
                        else % the file cannot be found
                            fileFinalPath = [];
                            fprintf('Channel location file for for subject %d of session number %s cannot be found.\n', j, obj.sessionTaskInfo(i).sessionNumber);
                        end;
                        
                        if ~isempty(fileFinalPath)
                            
                            essConventionfolder = ['session' filesep obj.sessionTaskInfo(i).sessionNumber];
                            [dummy1, dummy2, extension] = fileparts(fileFinalPath); %#ok<ASGLU>
                            subjectInSessionNumber = obj.sessionTaskInfo(i).subject(j).inSessionNumber;
                            
                            % include original filename
                            fileForFreePart = obj.sessionTaskInfo(i).dataRecording(j).filename;
                            [path, name, ext] = fileparts(fileForFreePart);
                            
                            itMatches = level1Study.fileNameMatchesEssConvention([name ext], 'channel_locations', obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject));
                            
                            if itMatches
                                filenameInEss = [name ext];
                            else
                                filenameInEss = obj.essConventionFileName('channel_locations', obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject), name, extension);
                            end;
                            
                            if exist(fileFinalPath, 'file')
                                destinationFile = [essFolder filesep essConventionfolder filesep filenameInEss];
                                copyfile(fileFinalPath, destinationFile)
                                obj.sessionTaskInfo(i).subject(j).channelLocations = filenameInEss;
                            else
                                fprintf('Copy failed: file %s does not exist.\n', fileFinalPath);
                            end;
                            
                        end;
                        
                    end;
                end;
                
                
                for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                % use 
                    % find out what modalities are in the data recording
                    [dataRecordingModalities, dataRecordingModalityString]= obj.getModalitiesForDataRecording(i, j);
                    
                    if ismember('eeg', dataRecordingModalities)
                        typeOfFile = {'event' 'recording'};
                    else
                        typeOfFile = {'recording'};
                    end;
                    
                    for k =1:length(typeOfFile)
                        
                        switch typeOfFile{k}
                            case 'recording'
                                fileNameFromObj = obj.sessionTaskInfo(i).dataRecording(j).filename;
                                namePrefixString = dataRecordingModalityString;
                            case 'event'
                                fileNameFromObj = obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile;
                                namePrefixString = 'event';
                        end;
                        
                        nextToXMLFilePath = [rootFolder filesep fileNameFromObj];
                        fullEssFilePath = [rootFolder filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObj];
                        fileNameFromObjisEmpty = isempty(fileNameFromObj) || isempty(strtrim(fileNameFromObj));
                        if ~fileNameFromObjisEmpty && exist(fullEssFilePath, 'file')
                            fileFinalPath = fullEssFilePath;
                        elseif ~fileNameFromObjisEmpty && exist(nextToXMLFilePath, 'file')
                            fileFinalPath = nextToXMLFilePath;
                        elseif ~fileNameFromObjisEmpty
                            fileFinalPath = [];
                            fprintf('File specified for data recording %d of session number %s does not exist, \r         i.e. cannot find either %s or %s.\n', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath);
                            fprintf('You might want to run validate() routine.\n');
                        else % the file was empty
                            fileFinalPath = [];
                            if strcmpi(typeOfFile{k}, 'recording')
                                fprintf('You have not specified any file for data recording %d of session number %s\n', j, obj.sessionTaskInfo(i).sessionNumber);
                                fprintf('You might want to run validate() routine.\n');
                            else
                                fprintf('Event Instance file for for data recording %d of session number %s is not specified.\n', j, obj.sessionTaskInfo(i).sessionNumber);
                                fprintf('Will attempt to create it from the data recording file.\n');
                            end;
                        end;
                        
                        % either the eeg file should exist or an empty
                        % event instance file is specified and needs to be
                        % created from a data recording file.
                        if ~isempty(fileFinalPath) || ( (isempty(fileNameFromObj) || isempty(strtrim(fileNameFromObj))) && strcmpi(typeOfFile{k}, 'event'))
                            essConventionfolder = ['session' filesep obj.sessionTaskInfo(i).sessionNumber];
                            
                            switch typeOfFile{k}
                                case 'recording'
                                    [dummy1, dummy2, extension] = fileparts(fileFinalPath); %#ok<ASGLU>
                                case 'event'
                                    extension = '.tsv';
                            end;
                            
                            % form subjectInSessionNumber
                            subjectInSessionNumber = obj.getInSessionNumberForDataRecording(obj.sessionTaskInfo(i).dataRecording(j));
                            
                            % copy the data recording file
                            
                            % extract data recording filename and see if it
                            % should be used as the 'free (optional) part'
                            % in ESS naming comnvention.
                            
                            % when the event instance file name is empty,
                            % use the file name of the eeg as the free part
                            if strcmpi(typeOfFile{k}, 'event') && isempty(fileFinalPath)
                                fileForFreePart = obj.sessionTaskInfo(i).dataRecording(j).filename;
                            else
                                fileForFreePart = fileFinalPath;
                            end;
                            
                            if ~isempty(fileForFreePart) && strcmpi(typeOfFile{k}, 'recording')
                                [path, name, ext] = fileparts(fileForFreePart);
                                % see if the file name is already in ESS
                                % format, hence no name change is necessary
                                itMatches = level1Study.fileNameMatchesEssConvention([name ext], namePrefixString, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject));
                            else
                                itMatches = [];
                                name = [];
                            end;
                            % only change the file name during copy if it
                            % does not match ESS convention
                            if itMatches
                                filenameInEss = [name ext];
                            else
                                filenameInEss = obj.essConventionFileName(namePrefixString, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject), name, extension);
                            end;
                            
                            if exist(fileFinalPath, 'file')
                                
                                destinationFile = [essFolder filesep essConventionfolder filesep filenameInEss];
                                if overwriteFiles || ~exist(destinationFile, 'file')
                                    if copyfile(fileFinalPath, destinationFile)
                                        fprintf('File %s copied successfully to %s.\n', fileFinalPath, destinationFile);
                                    end;
                                else
                                    fprintf('Skipped copying file %s to %s as it already exists.\n', fileFinalPath, destinationFile);
                                end;
                                
                                if strcmp(typeOfFile{k}, 'recording')
                                    obj.sessionTaskInfo(i).dataRecording(j).filename = filenameInEss;
                                    if length(fileFinalPath) > length(rootFolder) && strcmp(fileFinalPath(1:length(rootFolder)), rootFolder)
                                        originalFileNameForXML = fileFinalPath((length(rootFolder)+1):end);
                                    else
                                        originalFileNameForXML = fileFinalPath;
                                    end;
                                    
                                    obj.sessionTaskInfo(i).dataRecording(j).originalFileNameAndPath = originalFileNameForXML;
                                elseif strcmp(typeOfFile{k}, 'event')
                                    obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile = filenameInEss;
                                end;
                            else % the file does not exist in the original directory.
                                switch typeOfFile{k}
                                    case 'recording'
                                        fprintf('Copy failed: file %s does not exist.\n', fileFinalPath);
                                    case 'event'
                                        obj = writeEventInstanceFile(obj, i, j, [essFolder filesep essConventionfolder], filenameInEss, overwriteFiles);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            
            obj = obj.updateEventNumberOfInstances;
            
            % copy static files (assets)
            thisClassFilenameAndPath = mfilename('fullpath');
            essDocumentPathStr = fileparts(thisClassFilenameAndPath);
            
            copyfile([essDocumentPathStr filesep 'asset' filesep 'xml_style.xsl'], [essFolder filesep 'xml_style.xsl']);
            copyfile([essDocumentPathStr filesep 'asset' filesep 'Readme.txt'], [essFolder filesep 'Readme.txt']);
            
            % JSON-based report assets
            obj.copyJSONReportAssets(essFolder);
            
            % if license if CC0, copy the license file into the folder.
            if strcmpi(obj.summaryInfo.license.type, 'cc0')
                copyfile([essDocumentPathStr filesep 'asset' filesep 'cc0_license.txt'], [essFolder filesep 'License.txt']);
            end;
            
            % update total study size
            [dummy, obj.summaryInfo.totalSize]= dirsize(essFolder); %#ok<ASGLU>
            
            obj.rootURI = '.'; % the ess convention folder is the root
            
            obj.isInEssContainer = 'Yes';
             
            % write the XML file
            obj = obj.write([essFolder filesep 'study_description.xml']);
            
        end;
        
        function [filename, dataRecordingUuid, taskLabel, sessionNumber, dataRecordingNumber, subjectInfo, sessionTaskNumber, originalFileNameAndPath] = getFilename(obj, varargin)
            % [filename, dataRecordingUuid, taskLabel, sessionNumber, dataRecordingNumber, subjectInfo, sessionTaskNumber originalFileNameAndPath] = getFilename(obj, varargin)
            % obtain file names based on a selection criteria, such as task
            % label(s).
            % The output sessionNumber is of type Integer.
            % key,value pairs:
            %
            % taskLabel:       a cell array with label(s) for session tasks. Only
            %                  these files will be returned.
            %
            % includeFolder:   true or false. Whether to return full file
            %                  path.
            %
            % filetype:        one of {'eeg' , 'event'}
            
            inputOptions = arg_define(varargin, ...
                arg('taskLabel', {},[],'Label(s) for session tasks. A cell array containing task labels.', 'type', 'cellstr'), ...
                arg('includeFolder', true, [],'Add folder to returned filename.', 'type', 'logical'),...
                arg('filetype', 'eeg',{'eeg' 'EEG', 'event', 'Event'},'Return EEG or event files.', 'type', 'char')...
                );
            
            filename = {};
            dataRecordingUuid = {};
            taskLabel = {};
            sessionTaskNumber = [];
            dataRecordingNumber = [];
            subjectInfo = {};
            sessionNumber = {};
            originalFileNameAndPath = {};
            for i=1:length(obj.sessionTaskInfo)
                if isempty(inputOptions.taskLabel) || ismember(obj.sessionTaskInfo(i).taskLabel, inputOptions.taskLabel)
                    for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                        if strcmpi(inputOptions.filetype, 'eeg')
                            basefilename = obj.sessionTaskInfo(i).dataRecording(j).filename;
                        else
                            basefilename = obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile;
                        end;
                        
                        if inputOptions.includeFolder
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = obj.getSessionFileSearchFolders(obj.sessionTaskInfo(i).sessionNumber); %#ok<ASGLU>
                            if exist([nextToXMLFolder filesep basefilename], 'file')
                                filename{end+1} = [nextToXMLFolder filesep basefilename];
                            elseif exist([fullEssFolder filesep basefilename], 'file')
                                filename{end+1} = [fullEssFolder filesep basefilename];
                            else
                                warning('File %s of session %d, data recording %d cannot be found.', basefilename, i, j);
                            end;
                        else
                            filename{end+1} = basefilename;
                        end;
                        
                        dataRecordingUuid{end+1} = obj.sessionTaskInfo(i).dataRecording(j).dataRecordingUuid;
                        taskLabel{end+1} = obj.sessionTaskInfo(i).taskLabel;
                        sessionTaskNumber(end+1) = i;
                        sessionNumber{end+1} = obj.sessionTaskInfo(i).sessionNumber;
                        dataRecordingNumber(end+1) = j;
                        originalFileNameAndPath{end+1} = obj.sessionTaskInfo(i).dataRecording(j).originalFileNameAndPath;
                        if isempty(subjectInfo)
                            subjectInfo{1} = obj.sessionTaskInfo(i).subject;
                        else
                            subjectInfo{end+1} = obj.sessionTaskInfo(i).subject;
                        end;
                        
                    end;
                end;
            end;
        end
        
        function [filename, outputDataRecordingUuid, taskLabel, sessionTaskNumber, moreInfo] = infoFromDataRecordingUuid(obj, inputDataRecordingUuid, varargin)
            % [filename, outputDataRecordingUuid, taskLabel, sessionTaskNumber, moreInfo] = infoFromDataRecordingUuid(obj, inputDataRecordingUuid, varargin)
            % Returns information about valid data recording UUIDs. For
            % example Level 1 EEG or event files.
            % key, value pairs:
            %
            % includeFolder:   true ot false. Whether to return full file
            % path.
            %
            % filetype:       one of {'eeg' 'event'}
            
            inputOptions = arg_define(varargin, ...
                arg('includeFolder', true, [],'Add folder to returned filename.', 'type', 'logical'),...
                arg('filetype', 'eeg',{'eeg' 'EEG', 'event', 'Event'},'Return EEG or event files.', 'type', 'char')...
                );
            
            if ischar(inputDataRecordingUuid)
                inputDataRecordingUuid = {inputDataRecordingUuid};
            end;
            
            moreInfo = struct;
            moreInfo.sessionNumber = {};
            moreInfo.dataRecordingNumber = [];
            taskLabel = {};
            filename = {};
            sessionTaskNumber = [];
            outputDataRecordingUuid = {};
            for j=1:length(inputDataRecordingUuid)
                for i=1:length(obj.sessionTaskInfo)
                    for k=1:length(obj.sessionTaskInfo(i).dataRecording)
                        if strcmp(inputDataRecordingUuid{j}, obj.sessionTaskInfo(i).dataRecording(k).dataRecordingUuid)
                            
                            taskLabel{end+1} = obj.sessionTaskInfo(i).taskLabel;
                            sessionTaskNumber(end+1) = i;
                            outputDataRecordingUuid{end+1} = obj.sessionTaskInfo(i).dataRecording(k).dataRecordingUuid;
                            moreInfo.sessionNumber{end+1} = obj.sessionTaskInfo(i).sessionNumber;
                            moreInfo.dataRecordingNumber(end+1) = j;
                            
                            if strcmpi(inputOptions.filetype, 'eeg')
                                basefilename = obj.sessionTaskInfo(i).dataRecording(k).filename;
                            else
                                basefilename = obj.sessionTaskInfo(i).dataRecording(k).eventInstanceFile;
                            end;
                            
                            if inputOptions.includeFolder
                                [allSearchFolders, nextToXMLFolder, fullEssFolder] = obj.getSessionFileSearchFolders(obj.sessionTaskInfo(i).sessionNumber); %#ok<ASGLU>
                                if exist([nextToXMLFolder filesep basefilename], 'file')
                                    filename{end+1} = [nextToXMLFolder filesep basefilename];
                                elseif exist([fullEssFolder filesep basefilename], 'file')
                                    filename{end+1} = [fullEssFolder filesep basefilename];
                                else
                                    error('File %s of session %d, data recording %d cannot be found.', basefilename, i, j);
                                end;
                            else
                                filename{end+1} = basefilename;
                            end;
                            
                        end;
                    end
                end;
                
            end;
        end;
        
        function subjectInSessionNumber = getInSessionNumberForDataRecording(obj, dataRecording)
            % subjectInSessionNumber = getInSessionNumberForDataRecording(dataRecording)
            % Returns a string. If multiple subjects are present, they are
            % joined by _
            subjectInSessionNumber = {};
            for i=1:length(obj.recordingParameterSet)
                if strcmp(obj.recordingParameterSet(i).recordingParameterSetLabel, dataRecording.recordingParameterSetLabel)
                    for j=1:length(obj.recordingParameterSet(i).modality)
                        subjectInSessionNumber{end+1} = obj.recordingParameterSet(i).modality(j).subjectInSessionNumber;
                    end;
                end;
            end;
            
            subjectInSessionNumber = unique(subjectInSessionNumber);
            subjectInSessionNumber = setdiff(unique(subjectInSessionNumber), {'', '-', 'NA'});
            
            % join different number by _
            subjectInSessionNumber = strjoin_adjoiner_first('_', subjectInSessionNumber);
            
        end;
        
        function [dataRecordingModalities, dataRecordingModalityString]= getModalitiesForDataRecording(obj, sessionTaskNumber, dataRecordingNumber)
            % [dataRecordingModalities dataRecordingModalityString]= getModalitiesForDataRecording(sessionTaskNumber, dataRecordingNumber)
            % returns the list of modalities in the data recording
            % output:
            % dataRecordingModalities       : cell array with modalities in
            %                                 the data recording (all lower case)
            % dataRecordingModalityString   : string to be used in the
            %                                 beginning of ESS convention
            %                                 file name. made from
            %                                 concatenation of lower case modalities. except if EEG is one of the modalities, then this string will inly be 'eeg'
            
            setLabels = {obj.recordingParameterSet.recordingParameterSetLabel};
            setId = strcmp(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).recordingParameterSetLabel, setLabels);
            dataRecordingModalities = lower({obj.recordingParameterSet(setId).modality.type});
            
            if ismember('eeg', dataRecordingModalities)
                dataRecordingModalityString = 'eeg';
            else
                dataRecordingModalityString = lower(strjoin_adjoiner_first('_', dataRecordingModalities));
            end;
            
        end
        
        function subjectLabId = getSubjectLabIdForDataRecording(obj, sessionTaskNumber, dataRecordingNumber)
            subjectInSessionNumber = getInSessionNumberForDataRecording(obj, obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber));
            
            if strfind(subjectInSessionNumber, '_') % there is more than one subject in the recording
                subjectIds = str2double(strsplit(subjectInSessionNumber, '_'));
                
                subjectLabIdCell = {};
                for i=1:length(subjectIds)
                    subjectLabIdCell{i} = obj.sessionTaskInfo(sessionTaskNumber).subject(subjectIds(i));
                end;
                subjectLabId = strjoin_adjoiner_first('_', subjectLabIdCell);
                
            else % only one subject is in the recording
                if length(obj.sessionTaskInfo(sessionTaskNumber).subject) == 1 || strcmp(subjectInSessionNumber, '1')
                    subjectLabId = obj.sessionTaskInfo(sessionTaskNumber).subject(1).labId;
                else
                    subjectLabId = obj.sessionTaskInfo(sessionTaskNumber).subject(uint8(str2double(subjectInSessionNumber))).labId;
                end;
            end;
        end;
        
        function obj = renameLegacyFileNamesInANewContainerobj(obj, newContainerFolder)
            % creates a new level 1 container with legacy file names
            % converted to new names.
            if strcmpi(obj.isInEssContainer, 'no')
                error('This functiononly works for a data in an ESS container');
            end
            
            % first copy everything, then rename files
            mkdir(newContainerFolder);
            essFolder = fileparts(obj.essFilePath);
            copyfile([essFolder filesep '*'], newContainerFolder);
            
            newObj = level1Study(newContainerFolder);
            
            % fields of obj.sessionTaskInfo.dataRecording that require
            % name change
            fieldName = {'filename', 'eventInstanceFile'};
            
            % go over study sessions and rename files
            for i=1:length(newObj.sessionTaskInfo)
                for j=1:length(newObj.sessionTaskInfo(i).dataRecording)
                    for k = 1:length(fieldName)
                        currentFilePath = [essFolder filesep 'session' filesep num2str(i) filesep newObj.sessionTaskInfo(i).dataRecording(j).(fieldName{k})];
                        
                        % find the first _ and infer modality string from it
                        namePrefixString = newObj.sessionTaskInfo(i).dataRecording(j).(fieldName{k})(1:find(newObj.sessionTaskInfo(i).dataRecording(j).(fieldName{k}) == '_', 1)-1);
                        
                        subjectInSessionNumber = getInSessionNumberForDataRecording(newObj, newObj.sessionTaskInfo(i).dataRecording(j));
                        [path, name, extension] = fileparts(newObj.sessionTaskInfo(i).dataRecording(j).originalFileNameAndPath);
                        
                        if strcmpi(fieldName, 'eventInstanceFile')
                            extension = '.tsv';
                        end;
                        
                        filenameInEss = obj.essConventionFileName(namePrefixString, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                            subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject), name, extension);
                        
                        movefile([newContainerFolder filesep 'session' filesep num2str(i) filesep obj.sessionTaskInfo(i).dataRecording(j).(fieldName{k})], [newContainerFolder filesep 'session' filesep num2str(i) filesep filenameInEss]);
                        
                        newObj.sessionTaskInfo(i).dataRecording(j).(fieldName{k}) = filenameInEss;
                    end;
                end;
                
                if level1Study.isAvailable(newObj.sessionTaskInfo(i).subject.channelLocations)
                    for j=1:length(newObj.sessionTaskInfo(i).subject)
                        currentFilePath = [essFolder filesep 'session' filesep num2str(i) filesep newObj.sessionTaskInfo(i).subject(j).channelLocations];
                        
                        
                        namePrefixString = 'channel_locations';
                        
                        subjectInSessionNumber = getInSessionNumberForDataRecording(newObj, newObj.sessionTaskInfo(i).dataRecording(j));
                        [path, name, dummy] = fileparts(newObj.sessionTaskInfo(i).dataRecording(j).originalFileNameAndPath);
                        [path, dummy, extension] = fileparts(newObj.sessionTaskInfo(i).subject(j).channelLocations);
                        
                        filenameInEss = obj.essConventionFileName(namePrefixString, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                            subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, getSubjectLabIdForDataRecording(obj, i, j), length(obj.sessionTaskInfo(i).subject), name, extension);
                        
                        movefile([newContainerFolder filesep 'session' filesep num2str(i) filesep obj.sessionTaskInfo(i).subject(j).channelLocations], [newContainerFolder filesep 'session' filesep num2str(i) filesep filenameInEss]);
                        
                        newObj.sessionTaskInfo(i).subject(j).channelLocations = filenameInEss;
                    end;
                end;
            end;
            
            obj = newObj;
            obj.essVersion = '2.1';
            obj.write;
            
        end;
        
        function obj = recreateEventInstanceFiles(obj, forceCreate, sessionTaskNumbers)
            % obj = recreateEventInstanceFiles(obj, forceCreate, sessionTaskNumbers)
            %
            % re-create event instance files. Only works if the object is
            % already a proper ESS container unless forceCreate is set to
            % true.
            % sessionTaskNumber   an array of sessionTaskNumbers for which
            %                     event instance file are to be created. 
            %                     Default (or []) leads to recreating all
            %                     of them.
            
            if nargin < 2
                forceCreate = false;
            end;
            
            if nargin < 3 || isempty(sessionTaskNumbers)
                sessionTaskNumbers = 1:length(obj.sessionTaskInfo);
            end;
            
            if strcmpi(obj.isInEssContainer, 'No') && ~forceCreate
                error('To use this function, the object must already be a proper ESS container.');
            else
                for sessionTaskNumber = sessionTaskNumbers
                    for dataRecordingNumber=1:length(obj.sessionTaskInfo(sessionTaskNumber).dataRecording)
                        filePath = [];
                        outputFileName = obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile;
                        overwriteFile = true;
                        obj = writeEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber, filePath, outputFileName, overwriteFile);
                    end;
                end;
            end;
        end;
        
        function [json, xmlAsStructure] = getAsJSON(obj)
            % [json, jsonAsStructure] = getAsJSON(obj)
            % get the ESS study as a JSON object.
                        
            tmpFile = [tempname '.xml'];
            obj.write(tmpFile, false);
            
            Pref.Str2Num = false;
            Pref.PreserveSpace = true; % keep spaces
            xmlAsStructure = xml_read(tmpFile, Pref);
            delete(tmpFile);
                      
            % add fields that do not exist in XML yet, shoul be here on top to make the JSON
            % elements to show on topobj.ge
            xmlAsStructure.DOI = 'NA';
            xmlAsStructure.type = 'ess:StudyLevel1';
            xmlAsStructure.dateCreated = datestr8601(now,'*ymdHMS');
            xmlAsStructure.dateModified = xmlAsStructure.dateCreated;
            xmlAsStructure.id = obj.studyUuid;
            xmlAsStructure = rmfield(xmlAsStructure, 'uuid'); 
            
            
            for i=1:length(xmlAsStructure.project.funding)
                xmlAsStructure.projectFunding(i).organization = xmlAsStructure.project.funding(i).organization;
                xmlAsStructure.projectFunding(i).grantId = xmlAsStructure.project.funding(i).grantId;
            end;
               xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'projectFunding');

            xmlAsStructure = rmfield(xmlAsStructure, 'project');
            
            clear recordingParameterSets;
            for i=1:length(xmlAsStructure.recordingParameterSets.recordingParameterSet)
                recordingParameterSets(i).recordingParameterSetLabel = xmlAsStructure.recordingParameterSets.recordingParameterSet(i).recordingParameterSetLabel;
                clear modality;
                for j=1:length(xmlAsStructure.recordingParameterSets.recordingParameterSet(i).channelType.modality)
                    modality{j} = xmlAsStructure.recordingParameterSets.recordingParameterSet(i).channelType.modality(j);
                    modality{j}.startChannel = str2double(modality{j}.startChannel);
                    modality{j}.endChannel = str2double(modality{j}.endChannel);
                    modality{j}.samplingRate = str2double(modality{j}.samplingRate);
                    modality{j} = renameField(modality{j}, 'channelLabel','channelLabels');
                    modality{j} = renameField(modality{j}, 'nonScalpChannelLabel','nonScalpChannelLabels');
                    
                    if isempty(modality{j}.channelLabels)
                        modality{j}.channelLabels = {'NA'};
                    else
                        modality{j}.channelLabels = strtrim(strsplit(modality{j}.channelLabels, ','));
                    end;
                    
                    if isempty(modality{j}.nonScalpChannelLabels)
                        modality{j}.nonScalpChannelLabels = {'NA'};
                    else
                        modality{j}.nonScalpChannelLabels = strtrim(strsplit(modality{j}.nonScalpChannelLabels, ','));
                    end;
                end;
                
                for j=1:length(modality)
                    recordingParameterSets(i).modality(j) = modality{j};
                end;
               
            end;
            recordingParameterSets = renameField(recordingParameterSets, 'modality', 'modalities');
            recordingParameterSets = rename_field_to_force_array(recordingParameterSets, 'modalities');
            xmlAsStructure.recordingParameterSets = recordingParameterSets;
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'recordingParameterSets');

            
            clear sessions
            for i=1:length(xmlAsStructure.sessions.session)
                clear dataRecordings
                for j=1:length(xmlAsStructure.sessions.session(i).dataRecordings.dataRecording)
                    tempVar = xmlAsStructure.sessions.session(i).dataRecordings.dataRecording(j);
                    tempVar.dataRecordingId = ['ess:recording/' xmlAsStructure.sessions.session(i).dataRecordings.dataRecording(j).dataRecordingUuid];
                    if j>1 
                        tempVar = orderfields(tempVar, dataRecordings(1));
                    end;
                    dataRecordings(j) = tempVar;
                end;
                
                dataRecordings = rmfield(dataRecordings, 'dataRecordingUuid');
                for j=1:length(dataRecordings)
                    dataRecordings(j).taskLabels = {xmlAsStructure.sessions.session(i).taskLabel}; % make cell array so it always becomes a JSON array.
                end;
                
                sessions{i} = xmlAsStructure.sessions.session(i);
                sessions{i}.dataRecordings = dataRecordings;
               
                % convert subject age, height and weight to numbers
                clear subjects
                for j=1:length(xmlAsStructure.sessions.session(i).subject)
                    subjects{j} = xmlAsStructure.sessions.session(i).subject(j);
                    %         subjects{j}.age = str2double(xmlAsStructure.sessions.session(i).subject(j).age);
                    %         subjects{j}.height = str2double(xmlAsStructure.sessions.session(i).subject(j).height);
                    %         subjects{j}.weight = str2double(xmlAsStructure.sessions.session(i).subject(j).weight);
                    subjects{j} = renameField(subjects{j}, 'channelLocations', 'channelLocationFile');
                end;
                
                for j=1:length(subjects)
                    sessions{i}.subjects(j) = subjects{j};
                end;
                sessions{i} = rename_field_to_force_array(sessions{i}, 'subjects');
                
                sessions{i} = rmfield(sessions{i}, 'subject');                
            end;
            
            
            % convert the sessions variable from being interpreted as
            % the (XML-style) sessiontask into the new (JSON-style)
            % session concepts with each data recording having its own task label.
            sessionCombinedAcrossTasks = {};
            alreadyCombinedSessionNumber = {};
            for i=1:length(sessions)
                sessions{i} = rmfield(sessions{i}, 'taskLabel'); % this interepatron of session now can have data recordngs of multiple tasks.
                if ~ismember(sessions{i}.number, alreadyCombinedSessionNumber)
                    currentSessionNumber = sessions{i}.number;
                    if isempty(alreadyCombinedSessionNumber)
                        alreadyCombinedSessionNumber{1} = currentSessionNumber;
                    else
                        alreadyCombinedSessionNumber{end+1} = currentSessionNumber;
                    end;
                    currentSessionI = length(alreadyCombinedSessionNumber);
                    sessionCombinedAcrossTasks{currentSessionI} = {};
                    for j=1:length(sessions)
                        if strcmp(sessions{j}.number, currentSessionNumber)                            
                            if isempty(sessionCombinedAcrossTasks{currentSessionI})
                                sessionCombinedAcrossTasks{currentSessionI} = sessions{j};
                            else
                                sessionCombinedAcrossTasks{currentSessionI}.dataRecordings = cat(2, sessionCombinedAcrossTasks{currentSessionI}.dataRecordings, sessions{j}.dataRecordings);
                            end;
                        end;
                    end;
                end;
            end
            
            
            xmlAsStructure = rmfield(xmlAsStructure, 'sessions');
            
            for i=1:length(sessionCombinedAcrossTasks)
                sessionCombinedAcrossTasks{i} = rename_field_to_force_array(sessionCombinedAcrossTasks{i}, 'dataRecordings');
                xmlAsStructure.sessions(i) = sessionCombinedAcrossTasks{i};
            end;
            
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'sessions');

            
            % tasks
            clear tasks;
            for i=1:length(xmlAsStructure.tasks.task)
                tasks{i} = xmlAsStructure.tasks.task(i);
            end;
            xmlAsStructure = rmfield(xmlAsStructure, 'tasks');
            for i=1:length(tasks)
                xmlAsStructure.tasks(i) = tasks{i};
            end;
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'tasks');

            
            % publications
            clear publications;
            for i=1:length(xmlAsStructure.publications.publication)
                publications{i} = xmlAsStructure.publications.publication(i);
            end;
            xmlAsStructure = rmfield(xmlAsStructure, 'publications');
            for i=1:length(publications)
                xmlAsStructure.publications(i) = publications{i};
            end;
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'publications');

                        
            % experimenters
            clear experimenters;
            for i=1:length(xmlAsStructure.experimenters.experimenter)
                experimenters{i} = xmlAsStructure.experimenters.experimenter(i);
                [experimenters{i}.givenName, experimenters{i}.familyName, experimenters{i}.additionalName] = splitName(experimenters{i}.name);
                experimenters{i} = rmfield(experimenters{i}, 'name');
            end;
            xmlAsStructure = rmfield(xmlAsStructure, 'experimenters');
            for i=1:length(experimenters)
                xmlAsStructure.experimenters(i) = experimenters{i};
            end;
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'experimenters');
            
            [xmlAsStructure.contact.givenName, xmlAsStructure.contact.familyName, xmlAsStructure.contact.additionalName] = splitName(xmlAsStructure.contact.name);
            xmlAsStructure.contact = rmfield(xmlAsStructure.contact, 'name');
            
            % event codes
            clear eventCodes;
            for i=1:length(xmlAsStructure.eventCodes.eventCode)
                eventCodes(i).code = xmlAsStructure.eventCodes.eventCode(i).code;
                eventCodes(i).taskLabel = xmlAsStructure.eventCodes.eventCode(i).taskLabel;
                eventCodes(i).label = xmlAsStructure.eventCodes.eventCode(i).condition.label;
                eventCodes(i).description = xmlAsStructure.eventCodes.eventCode(i).condition.description;
                eventCodes(i).tag = xmlAsStructure.eventCodes.eventCode(i).condition.tag;
                
                if isempty(xmlAsStructure.eventCodes.eventCode(i).numberOfInstances)
                    eventCodes(i).numberOfInstances = -1;
                else
                    try
                        eventCodes(i).numberOfInstances = str2double(xmlAsStructure.eventCodes.eventCode(i).numberOfInstances);
                    catch e
                        eventCodes(i).numberOfInstances = -1;
                    end;
                end;
            end;
            xmlAsStructure.eventCodes = eventCodes;
            xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'eventCodes');
            
            xmlAsStructure = renameField(xmlAsStructure, 'organization', 'organizations');
          xmlAsStructure = rename_field_to_force_array(xmlAsStructure, 'organizations');

            
            if isempty(xmlAsStructure.copyright)
                xmlAsStructure.copyright = 'NA';
            end;
            
            
            % sort field names so important ones, e.g type and id end up on the top
            fieldNames = fieldnames(xmlAsStructure);
            topFields = {'title', 'type', 'essVersion', 'shortDescription', 'dateCreated', ...
                'dateModified', 'id', 'DOI', 'contact', 'description', 'rootURI','summary', 'projectFunding___Array___',...
                'tasks___Array___', 'publications___Array___', 'experimenters___Array___'};
            
            xmlAsStructure = orderfields(xmlAsStructure, [topFields setdiff(fieldNames, topFields, 'stable')']);
            
            opt.ForceRootName = false;
            opt.SingletCell = true;  % even single cells are saved as JSON arrays.
            opt.SingletArray = false; % single numerical arrays are NOT saved as JSON arrays.
            opt.emptyString = '"NA"';
            json = savejson_for_ess('', xmlAsStructure, opt);
        end;        
        
%         function writeJSONP(obj, essFolder)
%             % writeJSONP(obj, essFolder)
%             % write ESS container manifest data as a JSONP (JSON with a function wrapper) in manifest.js file.
%             if nargin < 2
%                 essFolder = fileparts(obj.essFilePath);
%             end;
%             
%             if ~exist(essFolder, 'dir')
%                 mkdir(essFolder);
%             end;
%             
%             json = getAsJSON(obj);
%             
%             fid= fopen([essFolder filesep 'manifest.js'], 'w');
%             fprintf(fid, '%s', ['receiveEssDocument(' json ');']);
%             fclose(fid);
%         end;
%         
%         function copyJSONReportAssets(obj, essFolder)
%             if nargin < 2
%                 essFolder = fileparts(obj.essFilePath);
%             end;
%             
%             thisClassFilenameAndPath = mfilename('fullpath');
%             essDocumentPathStr = fileparts(thisClassFilenameAndPath);
%             % copy index.html
%             copyfile([essDocumentPathStr filesep 'asset' filesep 'index.html'], [essFolder filesep 'index.html']);
%             
%             % copy javascript and CSS used in index.html
%             copyfile([essDocumentPathStr filesep 'asset' filesep 'web_resources' filesep '*'], [essFolder filesep 'web_resources']);
%         end;
        
        function obj = updateEventNumberOfInstances(obj)
            % obj = updateEventNumberOfInstances(obj)
            % calculates the number of instances for each event code, for each task and 
            % places it in obj.eventCodesInfo( ).numberOfInstances field.
            eventCodeCountMap = containers.Map;
            for sessionTaskNumber = 1:length(obj.sessionTaskInfo)
                for dataRecordingNumber=1:length(obj.sessionTaskInfo(sessionTaskNumber).dataRecording)
                    [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, obj.sessionTaskInfo(sessionTaskNumber).sessionNumber);
                    outputFileName = obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile;
                    taskLabel = obj.sessionTaskInfo(sessionTaskNumber).taskLabel;
                    
                    filename = [fullEssFolder filesep outputFileName];
                    delimiter = '\t';
                    formatSpec = '%s%s%s%[^\n\r]';
                    
                    % get out of this function if an event instance file is missing 
                    if ~exist(filename, 'file')
                        fprintf('Event instance file %s (session task %d, recording number %d) is missing, aborting the calculation of event number of instances.', filename, sessionTaskNumber, dataRecordingNumber);
                        return ;
                    end;
                    
                    fileID = fopen(filename,'r');
                    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
                    fclose(fileID);
                    
                    eventCodes = dataArray{1};
                    [uniqueEventCode, tmp, id]= unique(eventCodes);
                    eventCodeCount = [];
                    for i=1:length(uniqueEventCode)
                        eventCodeCount = sum(id == i);
                        keyString = ['task: '  taskLabel  ', eventCode: '  uniqueEventCode{i}] ; % combine task and event codes to make a single key
                        if eventCodeCountMap.isKey(keyString)
                            eventCodeCountMap(keyString) = eventCodeCountMap(keyString) + eventCodeCount;
                        else
                            eventCodeCountMap(keyString) = eventCodeCount;
                        end;
                    end;
                end;
            end;
            
            
            for i=1:length(obj.eventCodesInfo)
                keyString = ['task: '  obj.eventCodesInfo(i).taskLabel  ', eventCode: '  obj.eventCodesInfo(i).code];
                if eventCodeCountMap.isKey(keyString)
                obj.eventCodesInfo(i).numberOfInstances = num2str(eventCodeCountMap(keyString));
                else
                    warning('Event % in task %s does not have any instances and should probably be removed from the list of events for this task.', obj.eventCodesInfo(i).code, obj.eventCodesInfo(i).taskLabel);
                    obj.eventCodesInfo(i).numberOfInstances = '0';
                end;
            end;
            
        end;
    end;
    
    methods (Static)
        
        function stringForFileName = removeForbiddenWindowsFilenameCharacters(inString)
            % remove forbidden Windows OS filename characeters, plus comma (makes it harder for csv
            % files)
            forbiddenCharacters = '\/:*?"<>\,';
            stringForFileName  = inString;
            stringForFileName(ismember(stringForFileName, forbiddenCharacters)) = [];
        end;
        
        function [name, part1, part2]= essConventionFileName(fileTypeIdentifier, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, subjectLabId, numberOfSubjectsInSession, freePart, extension)
            % [name, part1, part2]= essConventionFileName(eegOrEvent, studyTitle, sessionNumber,...
            %    subjectInSessionNumber, taskLabel, recordingNumber, freePart, extension)
            
            % create a hash string to prevent (make very unlikely) name
            % clashes in case of string truncation
            needHashString = false;
            hashString = DataHash([studyTitle taskLabel freePart], struct('Method', 'SHA-512', 'Format',  'base64'));
            hashString(hashString == '/') = [];
            hashString(hashString == '+') = [];
            hashString = hashString(1:3);
            
            % if it is a cell, e.g. has two numbers, join them by _, like
            % 1_2
            if iscell(subjectInSessionNumber)
                subjectInSessionNumber = strjoin_adjoiner_first('_', subjectInSessionNumber);
            end;
            
            if ~ischar(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            if iscell(subjectLabId)
                subjectLabId = strjoin_adjoiner_first('_', subjectLabId);
            end;
            
            % remove forbidden Windows OS filename characeters
            studyTitle = level1Study.removeForbiddenWindowsFilenameCharacters(studyTitle);
            taskLabel = level1Study.removeForbiddenWindowsFilenameCharacters(taskLabel);
            freePart = level1Study.removeForbiddenWindowsFilenameCharacters(freePart);
            subjectLabId = level1Study.removeForbiddenWindowsFilenameCharacters(subjectLabId);
            
            % make sure study title, freePart and task label are less than a certain length
            maxleLength = 22;
            if length(studyTitle) > maxleLength
                studyTitle = studyTitle(1:maxleLength);
                studyTitle = strtrim(studyTitle);
                needHashString = true;
            end;
            
            if length(taskLabel) > maxleLength
                numberToCutFromCenter = length(taskLabel) - maxleLength - 1;
                taskLabel = [taskLabel(1:floor(numberToCutFromCenter/2)) '_' taskLabel((end-floor(numberToCutFromCenter/2)):end)];
                taskLabel = strtrim(taskLabel);
                needHashString = true;
            end;
            
            if length(freePart) > maxleLength
                numberToCutFromCenter = length(freePart) - maxleLength - 1;
                freePart = [freePart(1:floor(numberToCutFromCenter/2)) '_' freePart((end-floor(numberToCutFromCenter/2)):end)];
                freePart = strtrim(freePart);
                needHashString = true;
            end;
            
            if length(subjectLabId) > maxleLength
                numberToCutFromCenter = length(subjectLabId) - maxleLength - 1;
                subjectLabId = [subjectLabId(1:floor(numberToCutFromCenter/2)) '_' subjectLabId((end-floor(numberToCutFromCenter/2)):end)];
                subjectLabId = strtrim(subjectLabId);
                needHashString = true;
            end;
            
            if needHashString
                if isempty(freePart)
                    freePart = hashString;
                else
                    freePart = [freePart '_' hashString];
                end;
            end;
            
            % replace spaces in study title, freePart and task label with underlines
            studyTitle(studyTitle == ' ') = '_';
            taskLabel(taskLabel == ' ') = '_';
            freePart(freePart == ' ') = '_';
            subjectLabId(subjectLabId == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            % always use tsv extension for event file
            fileTypeIdentifier = lower(fileTypeIdentifier);
            if strcmp(fileTypeIdentifier, 'event');
                extension = 'tsv';
            end;
            
            if extension(1) == '.'
                extension = extension(2:end);
            end;
            
            % only include subject inSession numbers if they are more than
            % one subejcts in the study.
            if numberOfSubjectsInSession == 1
                if isempty(subjectLabId) % skip subject lab id if itis not provided (is empty)
                    part1 = [fileTypeIdentifier '_' studyTitle '_session_' sessionNumber '_task_' taskLabel];
                else
                    part1 = [fileTypeIdentifier '_' studyTitle '_session_' sessionNumber '_task_' taskLabel '_subjectLabId_' subjectLabId];
                end;
            else % there are 2 of more subejcts in the session, we need to include inSession numbers
                if isempty(subjectLabId) % skip subject lab id if itis not provided (is empty)
                    part1 = [fileTypeIdentifier '_' studyTitle '_session_' sessionNumber '_task_' taskLabel '_subjectNumber_' subjectInSessionNumber];
                else
                    part1 = [fileTypeIdentifier '_' studyTitle '_session_' sessionNumber '_task_' taskLabel '_subjectLabId_' subjectLabId '_subjectNumber_' subjectInSessionNumber];
                end;
            end;
            
            part2 = ['_recording_' recordingNumber '.' extension];
            
            if nargin > 6 && ~isempty(freePart) % freePart exists
                name = [part1  '_' freePart part2];
            else
                name = [part1 part2];
            end;
        end;
        
        function [name, part1, part2]= essConventionFileName_legacy(fileTypeIdentifier, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, freePart, extension)
            % [name, part1, part2]= essConventionFileName(eegOrEvent, studyTitle, sessionNumber,...
            %    subjectInSessionNumber, taskLabel, recordingNumber, freePart, extension)
            
            % create a hash string to prevent (make very unlikely) name
            % clashes in case of string truncation
            needHashString = false;
            hashString = DataHash([studyTitle taskLabel freePart], struct('Method', 'SHA-512', 'Format',  'base64'));
            hashString(hashString == '/') = [];
            hashString(hashString == '+') = [];
            hashString = hashString(1:3);
            
            
            % remove forbidden Windows OS filename characeters
            studyTitle = level1Study.removeForbiddenWindowsFilenameCharacters(studyTitle);
            taskLabel = level1Study.removeForbiddenWindowsFilenameCharacters(taskLabel);
            freePart = level1Study.removeForbiddenWindowsFilenameCharacters(freePart);
            
            % make sure study title, freePart and task label are less than a certain length
            maxleLength = 22;
            if length(studyTitle) > maxleLength
                studyTitle = studyTitle(1:maxleLength);
                studyTitle = strtrim(studyTitle);
                needHashString = true;
            end;
            
            if length(taskLabel) > maxleLength
                numberToCutFromCenter = length(taskLabel) - maxleLength - 1;
                taskLabel = [taskLabel(1:floor(numberToCutFromCenter/2)) '_' taskLabel((end-floor(numberToCutFromCenter/2)):end)];
                taskLabel = strtrim(taskLabel);
                needHashString = true;
            end;
            
            if length(freePart) > maxleLength
                numberToCutFromCenter = length(freePart) - maxleLength - 1;
                freePart = [freePart(1:floor(numberToCutFromCenter/2)) '_' freePart((end-floor(numberToCutFromCenter/2)):end)];
                freePart = strtrim(freePart);
                needHashString = true;
            end;
            
            if needHashString
                freePart = [freePart '_' hashString];
            end;
            
            
            % replace spaces in study title, freePart and task label with underlines
            studyTitle(studyTitle == ' ') = '_';
            taskLabel(taskLabel == ' ') = '_';
            freePart(freePart == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            % if it is a cell, e.g. has two numbers, join them by _, like
            % 1_2
            if iscell(subjectInSessionNumber)
                subjectInSessionNumber = strjoin_adjoiner_first('_', subjectInSessionNumber);
            end;
            
            if ~ischar(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            % always use tsv extension for event file
            fileTypeIdentifier = lower(fileTypeIdentifier);
            if strcmp(fileTypeIdentifier, 'event');
                extension = 'tsv';
            end;
            
            if extension(1) == '.'
                extension = extension(2:end);
            end;
            
            part1 = [fileTypeIdentifier '_' studyTitle '_session_' sessionNumber '_subject_' subjectInSessionNumber '_task_' taskLabel];
            part2 = ['_recording_' recordingNumber '.' extension];
            
            if nargin > 6 && ~isempty(freePart) % freePart exists
                name = [part1  '_' freePart part2];
            else
                name = [part1 part2];
            end;
        end;
        
        function itMatches = fileNameMatchesEssConvention(name, eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, subjectLabId, numberOfSubjectsInSession)
            
            % replace spaces in study title with underlines
            studyTitle(studyTitle == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            if isnumeric(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            extension = name(end-2:end);
            if strcmpi(eegOrEvent, 'event') && ~strcmpi(extension, 'tsv')
                itMatches = false;
                fprintf('The only accepted extension of Event Instance file is .tsv.\n');
                keyboard;
                return;
            end;
            
            [dummyName, part1, part2]= level1Study.essConventionFileName(eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, subjectLabId, numberOfSubjectsInSession, '', extension);
            
            part1 = strrep(part1, '__', '_');
            if part1(end) == '_'
                part1(end) = [];
            end;
            
            if length(name)>=length(dummyName)
                part1FromName = strrep(name(1:length(part1)), '__', '_');
                if part1FromName(end) == '_'
                    part1FromName(end) = [];
                end;
            end;
            
            itMatches = length(name)>=length(dummyName) && strcmp(part1FromName, part1) && strcmp(name((end - length(part2)+1):end), part2);
            
            % make backward compatible with the old naming scheme.
            itMatches = itMatches || level1Study.fileNameMatchesEssConvention_legacy(name, eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber);
        end;
        
        function itMatches = fileNameMatchesEssConvention_legacy(name, eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber)
            
            % replace spaces in study title with underlines
            studyTitle(studyTitle == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            if isnumeric(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            extension = name(end-2:end);
            if strcmpi(eegOrEvent, 'event') && ~strcmpi(extension, 'tsv')
                itMatches = false;
                fprintf('The only accepted extension of Event Instance file is .tsv.\n');
                keyboard;
                return;
            end;
            
            [dummyName, part1, part2]= level1Study.essConventionFileName_legacy(eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, '', extension);
            
            part1 = strrep(part1, '__', '_');
            if part1(end) == '_'
                part1(end) = [];
            end;
            
            if length(name)>=length(dummyName)
                part1FromName = strrep(name(1:length(part1)), '__', '_');
                if part1FromName(end) == '_'
                    part1FromName(end) = [];
                end;
            end;
            
            itMatches = length(name)>=length(dummyName) && strcmp(part1FromName, part1) && strcmp(name((end - length(part2)+1):end), part2);
        end;
        
        function itIs = isAvailable(inputString) % the inut string has actual content (not just an empty space, - , or NA for not available/applicable)
            if isempty(inputString)
                itIs = false;
            else
                inputString = strtrim(inputString);
                itIs = ~isempty(inputString) && ~strcmpi(inputString, 'NA') && ~strcmp(inputString, '-');
            end;
        end
        
        function modalityArray = modalityArrayFromChannelType(channelType, channelLabel, samplingRate, externalChannelList, eegDeviceName, eegReferenceLabel, eegReferenceLocation)
            % modalityArray = modalityArrayFromChannelType(channelType, channelLabel, samplingRate, externalChannelList, eegDeviceName, eegReferenceLabel, eegReferenceLocation)
            %
            % Creates a modality array, used as part of level 1 RecordingParameterSet from channel
            % types, labels, etc.
            
            
            % for each data recording, create modalities (EEG, Temperature, etc.)
            [uniqueChannelType ia typeId] = unique(channelType, 'stable');
            for k=1:length(uniqueChannelType) % each modality, could still have multiple blocks with the same modality so need to search for blocks
                id = typeId == k;
                if id(1)
                    currentBlockNumber = 1;
                    beforeWasInsideBlock = true;
                else
                    currentBlockNumber = 0;
                    beforeWasInsideBlock = false;
                end;
                
                blockNumber = zeros(length(id), 1);
                for m = 1:length(id)
                    if beforeWasInsideBlock && id(m)
                        blockNumber(m) = currentBlockNumber;
                    elseif ~beforeWasInsideBlock && id(m)
                        currentBlockNumber = currentBlockNumber + 1;
                        blockNumber(m) = currentBlockNumber;
                    end;
                    
                    beforeWasInsideBlock = id(m);
                end;
                
                
                numberOfBlocks = max(blockNumber);
                for q = 1:numberOfBlocks
                    blockId = blockNumber == q;
                    labelsAsCell = strtrim(strsplit(channelLabel, ','));
                    modalityChannelLabelCell = labelsAsCell(blockId);
                    if strcmpi(uniqueChannelType{k}, 'EEG')
                        nonScalpChannelLabel = strjoin_adjoiner_first(', ', intersect(modalityChannelLabelCell, externalChannelList, 'stable'));
                        
                        if isempty(nonScalpChannelLabel)
                            nonScalpChannelLabel = 'NA'; % NA =Not Available. Empty woudl mean that it is missing.
                        end;
                        
                        channelLocationType = 'Custom';
                        referenceLabel = eegReferenceLabel;
                        referenceLocation = eegReferenceLocation;
                        name = eegDeviceName;
                    else
                        nonScalpChannelLabel = 'NA';
                        channelLocationType = 'NA';
                        referenceLabel = 'NA';
                        referenceLocation = 'NA';
                        name = 'NA';
                    end;
                    
                    newModality = struct('type', strtrim(uniqueChannelType{k}), 'samplingRate', num2str(samplingRate), 'name', name, ...
                        'nonScalpChannelLabel' ,  nonScalpChannelLabel,...
                        'channelLabel', strjoin_adjoiner_first(', ', modalityChannelLabelCell) , 'channelLocationType', channelLocationType, 'startChannel', num2str(find(blockId, 1, 'first')), ...
                        'endChannel', num2str(find(blockId, 1, 'last')), 'subjectInSessionNumber', {'1'}, 'referenceLabel', referenceLabel, 'referenceLocation', referenceLocation);
                    
                    if ~exist('modalityArray')
                        modalityArray = newModality;
                    else
                        modalityArray(end+1) = newModality;
                    end;
                end;
            end;
        end;                
    end;
end
