classdef standardLevel1Study
    % Allow reading, writing and manipulatoion of information contained in ESS-formatted Standard Level 1 XML files.
    % EEG Studdy Schema (ESS) Level 1 contains EEG study meta-data information (subject information, sessions file
    % associations...). On read data are loaded in the object properties, you can change this data
    % (e.g. add a ne session) and then save using the write() method into a =new ESS XML file.
    %
    % Written by Nima Bigdely-Shamlo and Jessica Hsi.
    % Copyright 2014 Syntrogi, Inc.
    % Copyright 2013-2014 University of California San Diego.
    % Released under BSD License.
    
    properties
        % Version of ESS schema used.
        essVersion = ' ';
        
        % The title of the study.
        studyTitle = ' ';
        
        % a short (less than 120 characters)  description of the study (e.g. explanation of study
        % goals, experimental procedures  utilized, etc.)
        studyShortDescription = ' ';
        
        % Long description the study (e.g. explanation of study goals,
        % experimental procedures utilized, etc.).
        studyDescription = ' ';
        
        % Unique identifier (uuid) with 32 random  alphanumeric characters and four hyphens). It is used to uniquely identify each ESS document.
        studyUuid = ' ';
        
        % the URI pointing to the root folder of associated ESS folder. If the ESS file is located
        % in the default root folder, this should be ?.? (current directory). If for example the data files
        % and the root folder are placed on a remote FTP location, <rootURI> should be set to
        % ?ftp://domain.com/study?. The concatenation or <rootURI> and <filename> for each file
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
        sessionTaskInfo = struct('sessionNumber', ' ', 'taskLabel', ' ', 'purpose', ' ', 'labId', ' ',...
            'dataRecording', struct('filename', ' ', 'startDateTime', ' ', 'recordingParameterSetLabel', ' ', 'eventInstanceFile', ' '),...
            'note', ' ', 'linkName', ' ', 'link', ' ', 'subject', struct('labId', ' ',...
            'inSessionNumber', ' ', 'group', ' ', 'gender', ' ', 'YOB', ' ', 'age', ' ', 'hand', ' ', 'vision', ' ', ...
            'hearing', ' ', 'height', ' ', 'weight', ' ', 'channelLocations', ' ', ...
            'medication', struct('caffeine', ' ', 'alcohol', ' ')));
        
        % information different tasks in each session of the study.
        tasksInfo = struct('taskLabel', ' ', 'tag', ' ', 'description', ' ');
        
        % Information about event codes (i.e. triggers, event numbers).
        eventCodesInfo = struct('code', ' ', 'taskLabel', ' ', 'condition', struct(...
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
        
        % Iinformation regarding the organization that conducted the
        % research study or experiment.
        organizationInfo = struct('name', ' ', 'logoLink', ' ');
        
        % Copyright information.
        copyrightInfo = ' ';
        
        % IRB (Institutional Review Board or equivalent) information, including IRB number study was conducted under.
        irbInfo = ' ';
        
        % Filename (including path) of the ESS XML file associated with the
        % object.
        essFilePath        % the file (including folder) associated with the document (e.g. the file the document was last saved to , or originally read from)
    end;
    
    methods
        
        function obj = standardLevel1Study(varargin)
            % obj = standardLevel1Study(essFilePath)
            % create a instance of the object. If essFilePath is provided (optimal) it also read the
            % file.
            
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            inputOptions = arg_define(1,varargin, ...
                arg('essFilePath', '','','ESS Standard Level 1 XML Filename. Name of the ESS XML file associated with the studyLevel1Study. It should include path and if it does not exist a new file with (mostly) empty fields in created.  It is highly Urecommended to use the name study_description.xml to comply with ESS folder convention.', 'type', 'char'), ...
                arg('numberOfSessions', uint32(1),[1 Inf],'Number of study sessions. A session is best described as a single application of EEG cap for subjects, for data to be recorded under a single study. Multiple (and potentially quite different) tasks may be recorded during each session but they should all belong to the same study.'), ...
                arg('numberOfSubjectsPerSession', uint32(1),[1 Inf],'Number of subjects per session. Most studies only have one session per subject but some may have two or more subejcts interacting in a single study sesion.'), ...
                arg('numberOfRecordingsPerSessionTask', uint32(1),[1 Inf],'Number of EEG recordings per task. Sometimes data for each task in a session is recorded in multiple files.'), ...
                arg('taskLabels', {'main'},[],'Labels for session tasks. A cell array containing task labels. Optional if study only has a single task. Each study may contain multiple tasks. For example a baseline ?eyes closed? task, followed by a ?target detection? task and a ?mind wandering?, eyes open, task. Each task contains a single paradigm and in combination they allow answering scientific questions investigated in the study. ESS allows for event codes to have different meanings in each task, although such event encoding is discouraged due to potential for experimenter confusion.', 'type', 'cellstr'), ...
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr'), ...
                arg('recordingParameterSet', unassigned,[],'Common data recording parameter set. If assigned indicates that all data recording have the exact same recording parameter set (same number of channels, sampling frequency, modalities and their orders...).') ...
                );
            
            % read the ESS File that is provided.
            if ~isempty(inputOptions.essFilePath)
                obj.essFilePath = inputOptions.essFilePath;
                
                if exist(obj.essFilePath, 'file') && ~inputOptions.createNewFile % read the ESS information from the file
                    obj = obj.read(obj.essFilePath);
                    if nargin > 1
                        fprintf('An ESS file already exists at the specified location. Loading the file and ignoring other input parameters.\n');
                    end;
                else
                    % input file did not exist. Create an ESS file at that located
                    % and populate it with empty fields according to input
                    % values.
                    
                    % prepare the object based on input values.
                    % assigns a random UUID.
                    obj.essVersion = '2.0';
                    obj.studyUuid = char(java.util.UUID.randomUUID);
                    
                    % if data recodring parameter set if assigned, use it
                    % for all the recordings.
                    typicalDataRecording = obj.sessionTaskInfo(1).dataRecording;
                    recordingParameterSetIsConstant = isfield(inputOptions, 'recordingParameterSet') && ~isempty(inputOptions.recordingParameterSet);
                    if recordingParameterSetIsConstant
                        obj.recordingParameterSet = inputOptions.recordingParameterSet;
                        typicalDataRecording.recordingParameterSetLabel = inputOptions.recordingParameterSet.recordingParameterSetLabel;
                    end;
                    
                    % create number of sessions x number of task records in
                    % sessionTaskInfo an fill them with provided session numbers and
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
            % Reads the information contained an ESS-formatted XML file and placed it into object properties.
            
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
            
            xmlDocument = xmlread(essFilePath);
            potentialStudyNodeArray = xmlDocument.getElementsByTagName('study');
            
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
                        singleTaskNode = currentNode;
                        
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
                    % go over all recording paramer sets
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
                        
                        
                        potentialPurposeNodeArray = currentNode.getElementsByTagName('purpose');
                        if potentialPurposeNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).purpose = readStringFromNode(potentialPurposeNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).purpose= '';
                        end;
                        
                        potentialLabIdNodeArray = currentNode.getElementsByTagName('labId');
                        if potentialLabIdNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).labId = readStringFromNode(potentialLabIdNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).labId= '';
                        end;
                        
                        
                        potentialChannelNodeArray = currentNode.getElementsByTagName('channels');
                        if potentialChannelNodeArray.getLength > 0
                            obj.sessionTaskInfo(sessionCounter+1).channels = readStringFromNode(potentialChannelNodeArray.item(0));
                        else
                            obj.sessionTaskInfo(sessionCounter+1).channels= '';
                        end;
                        
                        if str2num(obj.essVersion) <= 1 % for ESS 1.0
                            potentialEegSamplingRateNodeArray = currentNode.getElementsByTagName('eegSamplingRate');
                            if potentialEegSamplingRateNodeArray.getLength > 0
                                % for now we asume all had the same
                                % samling, a better way is to check all
                                % samplig rates and create different
                                % recodingParameter sets.
                                obj.recordingParameterSet(1).modality(1).samplingRate = readStringFromNode(potentialEegSamplingRateNodeArray.item(0));
                            end;
                        end;
                        
                        if str2num(obj.essVersion) <= 1 % for ESS 1.0
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
                        
                        potentialCodeConditionNodeArray = singleEventCodeNode.getElementsByTagName('condition');
                        if potentialCodeConditionNodeArray.getLength > 0
                            for codeConditionCounter = 0:(potentialCodeConditionNodeArray.getLength-1)
                                currentNode = potentialCodeConditionNodeArray.item(codeConditionCounter); % select a session and make it the current node.
                                singleCodeNode = currentNode;
                                
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
                        singlePublicationNode = currentNode;
                        
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
                        singleExperimenterNode = currentNode;
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
            % says the organization that has funded the projects, e.g. NIH or NSF and then there is
            % the organization node that is under the study node and contain name and logoLink info.
            % here we need to find the one that is under the study node.
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
        
        function obj = write(obj, essFilePath)
            % obj = write(essFilePath)
            %
            % Writes the information into an ESS-formatted XML file.
            
            if nargin < 2 && isempty(obj.essFilePath)
                error('Please provide the name of the output file in the first input argument');
            end;
            
            if nargin >=2
                obj.essFilePath = essFilePath;
            end;
            
            docNode = com.mathworks.xml.XMLUtils.createDocument('study');
            docRootNode = docNode.getDocumentElement;
            
            essVersionElement = docNode.createElement('essVersion');
            essVersionElement.appendChild(docNode.createTextNode(obj.essVersion));
            docRootNode.appendChild(essVersionElement);
            
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
                
                purposeElement = docNode.createElement('purpose');
                purposeElement.appendChild(docNode.createTextNode(obj.sessionTaskInfo(i).purpose));
                sessionRootNode.appendChild(purposeElement);
                
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
            
            function itIs = isAvailable(inputString) % the inut string has actual content (not just an empty space, - , or NA for not available/applicable)
                inputString = strtrim(inputString);
                itIs = ~isempty(inputString) && ~strcmpi(inputString, 'NA') && ~strcmp(inputString, '-');
            end
            
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
                
                % sort based on lenth so match firt by the longest
                [dummy ord] = sort(allowedUnitsLenght, 'descend');
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
            
            if ~isAvailable(obj.studyTitle)
                issue(end+1).description = 'Study title is not available. This value is required.';
            end;
            
            if ~isAvailable(obj.studyShortDescription)
                issue(end+1).description = 'Study Short Description is not available. This value is required.';
            end;
            
            if ~isAvailable(obj.studyDescription)
                issue(end+1).description = 'Study Description is not available. This value is required.';
            end;
            
            if length(obj.studyUuid) < 10 % uuid shoudllbe at least 10 random characters
                issue(end+1).description = 'UUID is empty or less than 10 (random) characeters.';
                if fixIssues
                    obj.studyUuid = char(java.util.UUID.randomUUID);
                    issue(end).howItWasFixed = 'A new UUID set.';
                end;
            end;
            
            
            if ~isAvailable(obj.rootURI) % rootURI shoudl be . or some other URI
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
            
            % validate task information and find out how many tasks are present
            numberOfTasks = max(1, length(obj.tasksInfo));
            taskLabels = {};
            for i=1:length(obj.tasksInfo)
                taskLabels{end+1} = obj.tasksInfo(i).taskLabel;
                
                if ~isAvailable(obj.tasksInfo(i).taskLabel)
                    issue(end+1).description = sprintf('Task label is not available for task %d.', i);
                end;
                
                if ~isAvailable(obj.tasksInfo(i).description)
                    issue(end+1).description = sprintf('Task description is not available for task %d.', i);
                end;
            end;
            
            
            % validating recordingParameterSet
            listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation = {};
            if isempty(obj.recordingParameterSet)
                issue(end+1).description = sprintf('There is no recording parameter set defined. You need to at least have on ene of these to hold number of EEG channels, etc.');
            else
                for i=1:length(obj.recordingParameterSet)
                    if ~isAvailable(obj.recordingParameterSet(i).recordingParameterSetLabel)
                        issue(end+1).description = sprintf('The label of recording parameter set %d is empty.', i);
                    end;
                    
                    if isempty(obj.recordingParameterSet(i).modality)
                        issue(end+1).description = sprintf('There are no modalities defined for recording parameter set %d (labeled ''%s'')', i, obj.recordingParameterSet(i).recordingParameterSetLabel);
                    else
                        for j=1:length(obj.recordingParameterSet(i).modality)
                            if ~isAvailable(obj.recordingParameterSet(i).modality(j).type)
                                issue(end+1).description = sprintf('The type of modality %d of recording parameter set %d is empty.', j, i);
                            end;
                            
                            % we need sampling rate at least for EEG
                            if strcmpi(obj.recordingParameterSet(i).modality(j).type, 'EEG')
                                if ~isProperNumber(obj.recordingParameterSet(i).modality(j).samplingRate, false, 0, {'Hz' 'hz' 'HZ'})
                                    issue(end+1).description = sprintf('Sampling rate value of EEG (modality %d) in recording parameter set %d is empty or invalid (it is ''%s'').', j, i, obj.recordingParameterSet(i).modality(j).samplingRate);
                                end;
                                
                                % Reference location is needed for EEG
                                if ~isAvailable(obj.recordingParameterSet(i).modality(j).referenceLocation)
                                    issue(end+1).description = sprintf('Refernce location of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                                
                                % Channel Location Type is needed for EEG
                                if ~isAvailable(obj.recordingParameterSet(i).modality(j).channelLocationType)
                                    issue(end+1).description = sprintf('Channel location type of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                else
                                    if ~ismember(lower(obj.recordingParameterSet(i).modality(j).channelLocationType), {'10-20', '10-10', '10-5', 'EGI', 'Custom'})
                                        issue(end+1).description = sprintf('Invalid channel location type (%s) is specified for EEG (modality %d) in recording parameter set %d.\r Valid type are 10-20, 10-10, 10-5, EGI and Custom.', obj.recordingParameterSet(i).modality(j).channelLocationType, j, i);
                                    end;
                                    
                                    if strcmpi('custom', obj.recordingParameterSet(i).modality(j).channelLocationType)
                                        listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation(end+1) = obj.recordingParameterSet(i).recordingParameterSetLabel;
                                    end;
                                end;
                                                                
                                % Channel labels are needed for EEG
                                if ~isAvailable(obj.recordingParameterSet(i).modality(j).channelLabel)
                                    issue(end+1).description = sprintf('Channel labels of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                                
                                % Non-scalp channel labels are needed for
                                % EEG
                                if ~isAvailable(obj.recordingParameterSet(i).modality(j).nonScalpChannelLabel)
                                    issue(end+1).description = sprintf('Non-scalp channel labels of EEG (modality %d) in recording parameter set %d is empty.', j, i);
                                end;
                            end;
                            
                            % start channel
                            if ~isAvailable(obj.recordingParameterSet(i).modality(j).startChannel)
                                issue(end+1).description = sprintf('Start channel of modality %d of recording parameter set %d is empty.', j, i);
                            end;
                            
                            % end channel
                            if ~isAvailable(obj.recordingParameterSet(i).modality(j).endChannel)
                                issue(end+1).description = sprintf('End channel of modality %d of recording parameter set %d is empty.', j, i);
                            end;
                            
                            % we need a description when data type is not any of
                            % EEG, Mocap, or Gaze
                            
                            if ~ismember(lower(obj.recordingParameterSet(i).modality(j).type), {'eeg', 'mocap', 'gaze'}) ...
                                    && ~isAvailable(obj.recordingParameterSet(i).modality(j).description)
                                issue(end+1).description = sprintf('Description is missing for type %s in modality %d of recording parameter set %d. \n     A description is required for any type other than EEG, Mocap and Gaze.', obj.recordingParameterSet(i).modality(j).type, j, i);
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
                    issue(end+1).description = sprintf('Sesion number in sessionTaskInfo(%d).sessionNumber is not a positive integer.', i); %#ok<AGROW>
                    if fixIssues
                        obj.sessionTaskInfo(i).sessionNumber = num2str(i);
                        issue(end).howItWasFixed = sprintf('Session Number of ''%d'' assigned to the item.', i);
                        numberOfFixedIssues = numberOfFixedIssues + 1;
                    end;
                else
                    sessionNumbers = [sessionNumbers sessionNumber];
                end;
                
                % if channel location type is specified as Custom (versus e.g. 10-20) 
                % for a recording, each subject has to have a channel
                % location file.
                eegChannelLocationFileIsNeeded = false;
                for rcordingCounter=1:length(obj.sessionTaskInfo(i).dataRecording)
                    if ismember(obj.sessionTaskInfo(i).dataRecording(rcordingCounter).recordingParameterSetLabel, listOfRecordingParameterSetLabelsWithCustomEEGChannelLocation)
                        eegChannelLocationFileIsNeeded = true;
                    end;
                end;
                
                % validate subject existence
                if isempty(obj.sessionTaskInfo(i).subject)
                    issue(end+1).description = sprintf('Sesion %s does not have any subjects.', obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                else % check if inSessionNumber is set for all subejcts in the session
                    for j=1:length(obj.sessionTaskInfo(i).subject)
                        
                        if ~isAvailable(obj.sessionTaskInfo(i).subject(j).inSessionNumber)
                            issue(end+1).description =  sprintf('Subject %d of sesion %s does not an inSessionNumber.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            
                            if fixIssues && length(obj.sessionTaskInfo(i).subject) == 1
                                issue(end).howItWasFixed = 'inSessionNumber was assigned to 1';
                            end;
                        end;
                        
                        % check the existence of referred channel locations
                        % and make sure they are specified if channel
                        % location type is specified as Custom (versus e.g. 10-20).                                                                        
                        if eegChannelLocationFileIsNeeded && (isempty(obj.sessionTaskInfo(i).subject(j).channelLocations)...
                                 || strcmpi('NA', obj.sessionTaskInfo(i).subject(j).channelLocations))
                             issue(end+1).description =  sprintf('Subject %d of sesion %s does not have a channelLocations while \r its channelLocationType is defined as ''custom''.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        end;
                       
                        % check if the channel location file actually
                        % exists.
                        if isAvailable(obj.sessionTaskInfo(i).subject(j).channelLocations)
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber);
                            
                            fileFound = false;
                            searchFullPath = {};
                            for z = 1:length(allSearchFolders)
                                searchFullPath{z} = [allSearchFolders{z} filesep obj.sessionTaskInfo(i).subject(j).channelLocations];
                                if exist(searchFullPath{z}, 'file')
                                   fileFound = true;
                                end;
                            end;
                            
                            if ~fileFound
                                issue(end+1).description =  sprintf('Channel location file recoding of subject %d of sesion number %s cannot be found \r at any of these locations: %s .', j, obj.sessionTaskInfo(i).sessionNumber, strjoin_adjoiner_first(', ', searchFullPath)); %#ok<AGROW>
                                issue(end).issueType = 'missing file';
                            end;
                            
                        end;
                        
                    end;                 
                end;
                
                % validate th existence of valid data recordings for the session
                if isempty(obj.sessionTaskInfo(i).dataRecording)
                    issue(end+1).description = sprintf('Sesion %s does not have any data recording.', obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                else
                    for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                        
                        % check filename
                        if ~isAvailable(obj.sessionTaskInfo(i).dataRecording(j).filename)
                            issue(end+1).description =  sprintf('Data recoding %d of sesion number %s does not have a filename.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        else % file has to be found according to ESS convention
                            
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber);
                            
                            nextToXMLFilePath = [nextToXMLFolder filesep obj.sessionTaskInfo(i).dataRecording(j).filename];
                            fullEssFilePath = [fullEssFolder filesep obj.sessionTaskInfo(i).dataRecording(j).filename];
                            
                            if ~(exist(fullEssFilePath, 'file') || exist(nextToXMLFilePath, 'file'))
                                issue(end+1).description = [sprintf('File specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath)  '.'];
                                issue(end).issueType = 'missing file';
                            end;
                        end;
                        
                        % check eventInstanceFile
                        if ~isAvailable(obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile)
                            issue(end+1).description =  sprintf('Data recoding %d of sesion number %s does not have an event instance file.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                        else % file has to be found according to ESS convention
                            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, sessionNumber);
                            
                            nextToXMLFilePath = [nextToXMLFolder filesep obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile];
                            fullEssFilePath = [fullEssFolder filesep obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile];
                            
                            if ~(exist(fullEssFilePath, 'file') || exist(nextToXMLFilePath, 'file'))
                                issue(end+1).description = [sprintf('Event Instance file specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath)  '.'];
                                issue(end).issueType = 'missing file';
                            end;                           
                        end;
                        
                        % check startDateTime to be in ISO 8601 format
                        dateTime = strtrim(obj.sessionTaskInfo(i).dataRecording(j).startDateTime);
                        if isempty(datenum8601(dateTime))
                            issue(end+1).description =  sprintf('startDateTime specified in data recoding %d of sesion number %s does not have a valid ISO 8601 Date String.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
                            
                            dateTimeIso8601 = [];
                            try
                                dateNumber = datenum(dateTime);
                                dateTimeIso8601 = datestr(dateNumber);
                            catch e
                            end;
                            
                            if ~isempty(dateTimeIso8601)
                                issue(end).howItWasFixed = [dateTime ' changed to ' dateTimeIso8601];
                            end;
                            
                        end;
                        
                        % make sure a valid recordingParameterSetLabel is assigned
                        % for each recording
                        if ~isAvailable(obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel)
                            issue(end+1).description =  sprintf('Data recoding %d of sesion number %s does not have a Recording Parameterset Label.', j, obj.sessionTaskInfo(i).sessionNumber); %#ok<AGROW>
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
                                issue(end+1).description = sprintf('Recording parameter set label ''%s'' defined in Data recoding %d of sesion number %s does not match any labels in recordingParameterSet', obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel, j, obj.sessionTaskInfo(i).sessionNumber );
                            end;
                            
                        end;
                        
                    end;
                end;
                
                
                % validate the task label in the session
                if numberOfTasks > 1 && ~isAvailable(obj.sessionTaskInfo(i).taskLabel)
                    issue(end+1).description = sprintf('The study has more than one task but the task label is not available for sesion number %d', i);
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
                issue(end+1).description = sprintf('Some session numbers are missing. These numbers have to be from 1 up to the number of sesssions.\n Here are the missing numbers: %s.', num2str(missingSessionNumber));
            end;            
            
            if isempty(obj.eventCodesInfo)
                issue(end+1).description = sprintf('No event code information is provided.');
            else
                for i=1:length(obj.eventCodesInfo)
                    if ~isAvailable(obj.eventCodesInfo(i).code)
                        issue(end+1).description = sprintf('Event code for record %d is missing.', i);
                    end;
                    
                    % confirmity with tasks
                    if numberOfTasks > 1 && ~isAvailable(obj.eventCodesInfo(i).taskLabel)
                        issue(end+1).description = sprintf('The study has more than one task but there is no task label defined for event code %s in record %d.', obj.eventCodesInfo(i).code, i);
                    end;
                    
                    if isAvailable(obj.eventCodesInfo(i).taskLabel) && ~ismember(lower(obj.eventCodesInfo(i).taskLabel), lower(taskLabels))
                        issue(end+1).description = sprintf('Task label %s defined for event code %s in record %d does not have any corresponding task definition.', obj.eventCodesInfo(i).taskLabel, obj.eventCodesInfo(i).code, i);
                    end;
                    
                    if isempty(obj.eventCodesInfo(i).condition)
                        issue(end+1).description = sprintf('Condition information is missing for event code %s in record %d.', obj.eventCodesInfo(i).code, i);
                    else
                        for j=1:length(obj.eventCodesInfo(i).condition)
                            if ~(isAvailable(obj.eventCodesInfo(i).condition(j).label) || isAvailable(obj.eventCodesInfo(i).condition(j).description) || isAvailable(obj.eventCodesInfo(i).condition(j).tag))
                                issue(end+1).description = sprintf('Condition information is missing for condition %d of event code %s in record %d.', obj.eventCodesInfo(i).code, j, i);
                            end;
                        end;
                    end;
                    
                end;
                
                if ~isAvailable(obj.summaryInfo.allSubjectsHealthyAndNormal)
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
                
                if ~isAvailable(obj.summaryInfo.totalSize) || ~isProperNumber(obj.summaryInfo.totalSize, false, 0, {'Mb' 'GB' 'Gbytes' 'giga bytes' 'gbs' 'bytes' 'KB' 'kilo bytes' 'kilo byte' 'byte' 'kbs'})
                    issue(end+1).description = sprintf('Total Size value specified in Summary Information is missing or not valid.');
                end;
                
            end;
            
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
                
                fprintf('Fixed issues:');
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
                
                for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                    serialDateNumberForRecording = datenum8601(obj.sessionTaskInfo(i).dataRecording(j).startDateTime);
                    if isempty(serialDateNumberForRecording)
                        serialDateNumberForRecording = 0; % assume it is the earliest
                    end;
                    serialDateNumber(j) = serialDateNumberForRecording;
                end;
                
                [dummy ord] = sort(serialDateNumber, 'ascend');
                obj.sessionTaskInfo(i).dataRecording = obj.sessionTaskInfo(i).dataRecording(ord);
            end;
        end;
        
        function obj = writeEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber, filePath, fileName)
            % obj = writeEventInstanceFile(obj, sessionTaskNumber, dataRecordingNumber, filePath, fileName)
            
            [allSearchFolders, nextToXMLFolder, fullEssFolder] = getSessionFileSearchFolders(obj, obj.sessionTaskInfo(sessionTaskNumber).sessionNumber);
            
            if nargin < 4 % use the ESS convention folder location if none is provided.
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
                
                
                fileName = obj.essConventionFileName('event', obj.studyTitle, obj.sessionTaskInfo(sessionTaskNumber).sessionNumber,...
                    subjectInSessionNumber, obj.sessionTaskInfo(sessionTaskNumber).taskLabel, dataRecordingNumber);
            end;
            
            fullFilePath = [filePath filesep fileName];
            
            EEG = [];
            for i=1:length(allSearchFolders)
                if isempty(EEG)
                    try
                        % ToDo: use io_loadset here to load any file type and not just
                        % .set
                        EEG = pop_loadset(obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).filename, allSearchFolders{i});
                    catch
                    end;
                end;
            end;
            
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
            
            for i=1:length(EEG.event)
                type = EEG.event(i).type;
                if isnumeric(type)
                    type = num2str(type);
                end;
                eventType{i} = type;
                eventLatency(i) = EEG.event(i).latency / EEG.srate;
                
                id = currentTaskMask & strcmp(eventType{i}, studyEventCode);
                if any(id)
                    eventHedString{i} = studyEventCodeHedString{id};
                else
                    eventHedString{i} = '';
                end;
            end;
            
            fid = fopen(fullFilePath, 'w');
            for i=1:length(eventType)
                fprintf(fid, '%s\t%s\t%s', eventType{i}, num2str(eventLatency(i)), eventHedString{i});
                
                if i<length(eventType)
                    fprintf(fid, '\n');
                end;
            end;
            
            fclose(fid);
            
            [pathstr,name,ext]  = fileparts(fullFilePath);
            obj.sessionTaskInfo(sessionTaskNumber).dataRecording(dataRecordingNumber).eventInstanceFile = [name ext];
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
            end;
            
            % look both next to the ESS file and in the ESS
            % convention location for data recoording
            % files.
            nextToXMLFolder = rootFolder;
            fullEssFolder = [rootFolder filesep 'session' filesep sessionNumber];
            
            allSearchFolders = {nextToXMLFolder fullEssFolder};
        end;
        
        function obj = createEssConventionFolder(obj, essFolder)
            mkdir(essFolder);
            mkdir([essFolder filesep 'session']);
            mkdir([essFolder filesep 'publications']);
            
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
            end;
            
            obj = sortDataRecordingsByStartTime(obj);
            
            progress('init', 'Copying data recording and event instance files.');
            typeOfFile = {'event' 'eeg'};
            for i = 1:length(obj.sessionTaskInfo)
                progress(i/length(obj.sessionTaskInfo), sprintf('Copying files for session-task %d of %d',i, length(obj.sessionTaskInfo)));
                
                for j=1:length(obj.sessionTaskInfo(i).subject)
                    fileNameFromObj = obj.sessionTaskInfo(i).subject(j).channelLocations;
                    if ~(strcmpi(fileNameFromObj, 'na') || isempty(fileNameFromObj))
                        
                        nextToXMLFilePath = [rootFolder filesep fileNameFromObj];
                        fullEssFilePath = [rootFolder filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObj];
                        
                        fileFinalPath = [];
                        if ~isempty(fileNameFromObj) && exist(fullEssFilePath, 'file')
                            fileFinalPath = fullEssFilePath;
                        elseif ~isempty(fileNameFromObj) && exist(nextToXMLFilePath, 'file')
                            fileFinalPath = nextToXMLFilePath;
                        else % the file cannot be found
                            fileFinalPath = [];
                            fprintf('Channel location file for for subject %d of sesion number %s cannot be found.\n', j, obj.sessionTaskInfo(i).sessionNumber);
                        end;
                        
                        if ~isempty(fileFinalPath)
                            
                            essConventionfolder = [filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber];
                            [dummy1 dummy2 extension] = fileparts(fileFinalPath);
                            subjectInSessionNumber = obj.sessionTaskInfo(i).subject(j).inSessionNumber;
                            
                            % include original filename
                            fileForFreePart = obj.sessionTaskInfo(i).dataRecording(j).filename;
                            [path name ext] = fileparts(fileForFreePart);
                            
                            itMatches = standardLevel1Study.fileNameMatchesEssConvention([name ext], 'channel_locations', obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j);
                            
                            if itMatches
                                filenameInEss = [name ext];
                            else
                                filenameInEss = obj.essConventionFileName('channel_locations', obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, name, extension);
                            end;
                            
                            if exist(fileFinalPath, 'file')
                                copyfile(fileFinalPath, [essFolder filesep essConventionfolder filesep filenameInEss]);
                                obj.sessionTaskInfo(i).subject(j).channelLocations = filenameInEss;
                            else
                                fprintf('Copy failed: file %s does not exist.\n', fileFinalPath);
                            end;
                            
                        end;
                        
                    end;
                end;
                
                
                for j=1:length(obj.sessionTaskInfo(i).dataRecording)
                    
                    for k =1:length(typeOfFile)
                        
                        switch typeOfFile{k}
                            case 'eeg'
                                fileNameFromObj = obj.sessionTaskInfo(i).dataRecording(j).filename;
                            case 'event'
                                fileNameFromObj = obj.sessionTaskInfo(i).dataRecording(j).eventInstanceFile;
                        end;
                        
                        
                        nextToXMLFilePath = [rootFolder filesep fileNameFromObj];
                        fullEssFilePath = [rootFolder filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObj];
                        
                        if ~isempty(fileNameFromObj) && exist(fullEssFilePath, 'file')
                            fileFinalPath = fullEssFilePath;
                        elseif ~isempty(fileNameFromObj) && exist(nextToXMLFilePath, 'file')
                            fileFinalPath = nextToXMLFilePath;
                        elseif ~isempty(fileNameFromObj)
                            fileFinalPath = [];
                            fprintf('File specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s.\n', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath);
                            fprintf('You might want to run validate() routine.\n');
                        else % the file was empty
                            fileFinalPath = [];
                            if strcmpi(typeOfFile{k}, 'eeg')
                                fprintf('File specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s.\n', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath);
                                fprintf('You might want to run validate() routine.\n');
                            else % event
                                fprintf('Event Instance file for for data recoding %d of sesion number %s is not specified.\n', j, obj.sessionTaskInfo(i).sessionNumber);
                                fprintf('Will attempt to create it from the data recording file.\n');
                            end;
                        end;
                        
                        % either the eeg file should exist or an empty
                        % event instance file is specified and needs to be
                        % created from a data recording file.
                        if ~isempty(fileFinalPath) || (isempty(fileNameFromObj) && strcmpi(typeOfFile{k}, 'event'))
                            essConventionfolder = [filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber];
                            
                            switch typeOfFile{k}
                                case 'eeg'
                                    [dummy1 dummy2 extension] = fileparts(fileFinalPath);
                                case 'event'
                                    extension = '.tsv';
                            end;
                            
                            % form subjectInSessionNumber
                            id = strcmpi(obj.sessionTaskInfo(i).dataRecording(j).recordingParameterSetLabel, {obj.recordingParameterSet.recordingParameterSetLabel});
                            subjectInSessionNumberCell = setdiff(unique({obj.recordingParameterSet(id).modality.subjectInSessionNumber}), {'', '-', 'NA'});
                            subjectInSessionNumber = strjoin_adjoiner_first('_', subjectInSessionNumberCell);
                            
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
                            
                            if ~isempty(fileForFreePart) 
                            [path name ext] = fileparts(fileForFreePart);
                            % see if the file name is already in ESS
                            % format, hence no name change is necessary
                            itMatches = standardLevel1Study.fileNameMatchesEssConvention([name ext], typeOfFile{k}, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j);
                            else
                                itMatches = [];
                                name = [];
                            end;
                            % only change the file name during copy if it
                            % does not match ESS convention
                            if itMatches
                                filenameInEss = [name ext];
                            else
                                filenameInEss = obj.essConventionFileName(typeOfFile{k}, obj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                                    subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, name, extension);
                            end;
                            
                            if exist(fileFinalPath, 'file')
                                copyfile(fileFinalPath, [essFolder filesep essConventionfolder filesep filenameInEss]);
                                obj.sessionTaskInfo(i).dataRecording(j).filename = filenameInEss;
                            else                               
                                switch typeOfFile{k}
                                    case 'eeg'
                                        fprintf('Copy failed: file %s does not exist.\n', fileFinalPath);
                                    case 'event'
                                        obj = writeEventInstanceFile(obj, i, j, [essFolder filesep essConventionfolder], filenameInEss);
                                end;                                                                
                            end;
                        end;
                    end;
                end;
            end;
                       
            % copy static files (assets)
            thisClassFilenameAndPath = mfilename('fullpath');
            essDocumentPathStr = fileparts(thisClassFilenameAndPath);
            
            copyfile([essDocumentPathStr filesep 'asset' filesep 'xml_style.xsl'], [essFolder filesep 'xml_style.xsl']);
            copyfile([essDocumentPathStr filesep 'asset' filesep 'Readme.txt'], [essFolder filesep 'Readme.txt']);
            
            % if license if CC0, copy the license file into the folder.
            if strcmpi(obj.summaryInfo.license.type, 'cc0')
                copyfile([essDocumentPathStr filesep 'asset' filesep 'cc0_license.txt'], [essFolder filesep 'License.txt']);
            end;
            
            % update total study size
            [dummy, obj.summaryInfo.totalSize]= dirsize(path);
            
            % write the XML file
            obj.write([essFolder filesep 'study_description.xml']);
            
        end;
        
    end;
    methods (Static)
        function [name, part1, part2]= essConventionFileName(eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, freePart, extension)
            
            if ~ismember(lower(eegOrEvent), {'eeg', 'event' 'channel_locations'})
                error('eegOrEvent (first) input variable has to be either ''eeg'', ''event'' or ''channel_locations.');
            end;
            
            % replace spaces in study title with underlines
            studyTitle(studyTitle == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            if ~ischar(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            % always use tsv extension for event file
            eegOrEvent = lower(eegOrEvent);
            if strcmp(eegOrEvent, 'event');
                extension = 'tsv';
            end;
            
            if extension(1) == '.'
                extension = extension(2:end);
            end;
            
            part1 = [eegOrEvent '_' studyTitle '_session_' sessionNumber '_subject_' subjectInSessionNumber '_task_' taskLabel];
            part2 = ['_recording_' recordingNumber '.' extension];
            
            if nargin > 6 && ~isempty(freePart) % freePart exists
                name = [part1  '_' freePart part2];
            else
                name = [part1 part2];
            end;
        end;
        
        function itMatches = fileNameMatchesEssConvention(name, eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber)
            
            % replace spaces in study title with underlines
            studyTitle(studyTitle == ' ') = '_';
            
            if ~ischar(sessionNumber)
                sessionNumber = num2str(sessionNumber);
            end;
            
            if ~ischar(subjectInSessionNumber)
                subjectInSessionNumber = num2str(subjectInSessionNumber);
            end;
            
            if ~ischar(recordingNumber)
                recordingNumber = num2str(recordingNumber);
            end;
            
            extension = name(end-2:end);
            if strcmpi(eegOrEvent, 'event') && ~strcmpi(extension, 'tsv')
                itMatches = false;
                fprintf('The only accepted extension of Event Instance file is .tsv.\n');
                return;
            end;
            
            [dummyName, part1, part2]= standardLevel1Study.essConventionFileName(eegOrEvent, studyTitle, sessionNumber,...
                subjectInSessionNumber, taskLabel, recordingNumber, '', extension);
            
            itMatches = length(name)>=length(dummyName) && strcmp(name(1:length(part1)), part1) && strcmp(name((end - length(part2)+1):end), part2);
        end;
    end;
end